{
  flake.nixosModules.jellyfin =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      inherit (lib)
        types
        mkOption
        mkForce
        mkIf
        optionals
        optionalString
        concatMapStrings
        concatMapStringsSep
        ;
      pref = config.preferences;
      cfg = config.modules.services.jellyfin;

      public = {
        web = "jellyfin.${pref.topDomain}";
      };
      local = {
        web = "jellyfin.local.${pref.topDomain}";
      };
      ports = {
        web = 8096;
      };

      externalHost = if cfg.public then public.web else local.web;

      # Jellyfin's own state layout. Plugins are directories named
      # "<Name>_<version>" under <dataDir>/plugins; per-plugin settings live in
      # <dataDir>/plugins/configurations/<Name>.xml.
      jfUser = config.services.jellyfin.user;
      jfGroup = config.services.jellyfin.group;
      dataDir = config.services.jellyfin.dataDir;
      pluginDir = "${dataDir}/plugins";
      pluginConfigDir = "${pluginDir}/configurations";

      kanidmUrl = if pref.sso == null then "https://auth.${pref.topDomain}" else "https://${pref.sso}";
      ssoClientId = "jellyfin";

      # Provider key inside the SSO plugin. It shows up in the URLs, e.g.
      #   https://<host>/sso/OID/start/kanidm
      #   https://<host>/sso/OID/redirect/kanidm   <- Kanidm redirect URL
      ssoName = "kanidm";

      # Kanidm issues a per-client issuer; the plugin appends
      # /.well-known/openid-configuration itself, so hand it the bare issuer.
      ssoIssuer = "${kanidmUrl}/oauth2/openid/${ssoClientId}";

      # The plugin always prepends "openid profile", so only list extras here.
      # 'groups' is requested only when RBAC is actually used — Kanidm rejects
      # token requests for scopes that aren't in the client's scope map.
      ssoRbac = cfg.ssoUserGroups != [ ] || cfg.ssoAdminGroups != [ ];
      ssoScopes = [ "email" ] ++ optionals ssoRbac [ "groups" ];

      # ── Plugin packaging ────────────────────────────────────────────────────
      # Jellyfin plugins ship as zips of loose DLLs. Fetch them by file hash and
      # unpack into the store; a setup unit copies them into place at boot.
      mkJellyfinPlugin =
        {
          pname,
          version,
          url,
          hash,
          metaJson ? null,
        }:
        pkgs.runCommand "jellyfin-plugin-${pname}-${version}"
          {
            src = pkgs.fetchurl { inherit url hash; };
            nativeBuildInputs = [ pkgs.unzip ];
            passthru = {
              pluginName = pname;
              inherit version;
            };
          }
          ''
            mkdir -p "$out"
            unzip -q "$src" -d "$out"
            ${optionalString (metaJson != null) ''cp ${metaJson} "$out/meta.json"''}
          '';

      ssoPluginVersion = "4.0.0.4";
      ssoPlugin = mkJellyfinPlugin {
        pname = "SSO-Auth";
        version = ssoPluginVersion;
        url = "https://github.com/9p4/jellyfin-plugin-sso/releases/download/v${ssoPluginVersion}/sso-authentication_${ssoPluginVersion}.zip";
        hash = "sha256-wJ8WujEFmkNN3X+BHk+WCNS0xFFMyApb8cozvuYeEQc=";
        # Ships its own meta.json.
      };

      jellymixVersion = "1.0.3";
      # The JellyMix release zip is a bare DLL with no meta.json, so synthesise
      # one. The GUID is the plugin's own id, taken from the assembly.
      jellymixMeta = pkgs.writeText "jellymix-meta.json" (
        builtins.toJSON {
          category = "General";
          guid = "a5b6c7d8-e9f0-1234-5678-9abcdef01234";
          name = "JellyMix";
          overview = "Segmented playlist generator with genre weighting.";
          description = "Builds block-based music playlists where each block has its own genre mix.";
          owner = "steveshannon";
          targetAbi = "10.11.0.0";
          version = jellymixVersion;
          timestamp = "2026-01-01T22:42:00Z";
          changelog = "";
          imageUrl = "";
        }
      );
      jellymixPlugin = mkJellyfinPlugin {
        pname = "JellyMix";
        version = jellymixVersion;
        url = "https://github.com/steveshannon/jellyfin-plugin-jellymix/releases/download/v${jellymixVersion}/jellymix-v${jellymixVersion}.zip";
        hash = "sha256-MhGSUEPUMybNyA8Uu78P9a3ZzsN25IU5wjgn6yU9b5I=";
        metaJson = jellymixMeta;
      };

      # Every plugin this module knows about, so stale copies can be swept even
      # after an option is flipped off.
      knownPlugins = [
        ssoPlugin
        jellymixPlugin
      ];
      enabledPlugins = optionals cfg.sso [ ssoPlugin ] ++ optionals cfg.jellymix [ jellymixPlugin ];

      # ── SSO plugin configuration ────────────────────────────────────────────
      xmlStringList =
        tag: xs:
        if xs == [ ] then
          "<${tag} />"
        else
          "<${tag}>${concatMapStrings (x: "<string>${x}</string>") xs}</${tag}>";

      # Element order follows the C# property order; XmlSerializer is happier
      # that way. OidSecret is a placeholder — the setup script substitutes the
      # real value so it never lands in the Nix store.
      ssoConfigTemplate = pkgs.writeText "SSO-Auth.xml" ''
        <?xml version="1.0" encoding="utf-8"?>
        <PluginConfiguration xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
          <SamlConfigs />
          <OidConfigs>
            <item>
              <key>
                <string>${ssoName}</string>
              </key>
              <value>
                <PluginConfiguration>
                  <OidEndpoint>${ssoIssuer}</OidEndpoint>
                  <OidClientId>${ssoClientId}</OidClientId>
                  <OidSecret>PLACEHOLDER</OidSecret>
                  <Enabled>true</Enabled>
                  <EnableAuthorization>${if ssoRbac then "true" else "false"}</EnableAuthorization>
                  <EnableAllFolders>true</EnableAllFolders>
                  <EnabledFolders />
                  ${xmlStringList "AdminRoles" cfg.ssoAdminGroups}
                  ${xmlStringList "Roles" cfg.ssoUserGroups}
                  <EnableFolderRoles>false</EnableFolderRoles>
                  <EnableLiveTvRoles>false</EnableLiveTvRoles>
                  <EnableLiveTv>false</EnableLiveTv>
                  <EnableLiveTvManagement>false</EnableLiveTvManagement>
                  <LiveTvRoles />
                  <LiveTvManagementRoles />
                  <FolderRoleMappings />
                  <RoleClaim>groups</RoleClaim>
                  ${xmlStringList "OidScopes" ssoScopes}
                  <DefaultProvider />
                  <SchemeOverride>https</SchemeOverride>
                  <PortOverride>443</PortOverride>
                  <NewPath>true</NewPath>
                  <CanonicalLinks />
                  <DefaultUsernameClaim>preferred_username</DefaultUsernameClaim>
                  <AvatarUrlFormat />
                  <DisableHttps>false</DisableHttps>
                  <DisablePushedAuthorization>false</DisablePushedAuthorization>
                  <DoNotValidateEndpoints>false</DoNotValidateEndpoints>
                  <DoNotValidateIssuerName>false</DoNotValidateIssuerName>
                  <DoNotLoadProfile>false</DoNotLoadProfile>
                </PluginConfiguration>
              </value>
            </item>
          </OidConfigs>
        </PluginConfiguration>
      '';

      # The plugin stores OIDC-subject -> Jellyfin-user links in this same file
      # (<CanonicalLinks>). Rendering the template blindly would drop them on
      # every boot, so carry that one element across.
      ssoConfigRender = pkgs.writeText "jellyfin-sso-render.py" ''
        import os, sys
        import xml.etree.ElementTree as ET

        template, secret_file, target = sys.argv[1:4]

        with open(secret_file) as fh:
            secret = fh.read().strip()

        tree = ET.parse(template)
        root = tree.getroot()

        # Preserve links established by users on previous runs.
        preserved = {}
        if os.path.exists(target):
            try:
                for item in ET.parse(target).getroot().findall("./OidConfigs/item"):
                    name = item.findtext("./key/string")
                    links = item.find("./value/PluginConfiguration/CanonicalLinks")
                    if name is not None and links is not None and len(links):
                        preserved[name] = links
            except ET.ParseError:
                pass

        for item in root.findall("./OidConfigs/item"):
            name = item.findtext("./key/string")
            conf = item.find("./value/PluginConfiguration")
            if conf is None:
                continue
            conf.find("OidSecret").text = secret
            old = conf.find("CanonicalLinks")
            if name in preserved and old is not None:
                index = list(conf).index(old)
                conf.remove(old)
                conf.insert(index, preserved[name])

        tmp = target + ".new"
        tree.write(tmp, encoding="utf-8", xml_declaration=True)
        os.chmod(tmp, 0o600)
        os.replace(tmp, target)
      '';
    in
    {
      # ── Modules Settings ────────────────────────────────────────
      options.modules.services.jellyfin = {
        public = mkOption {
          default = pref.public;
          type = types.bool;
          description = "Whether to expose Jellyfin publicly";
        };

        sso = mkOption {
          default = true;
          type = types.bool;
          description = "Whether to enable Kanidm OIDC single sign-on";
        };

        jellymix = mkOption {
          default = true;
          type = types.bool;
          description = "Whether to install the JellyMix playlist plugin";
        };

        ssoUserGroups = mkOption {
          default = [ "users@auth.othrys.tolok.org" ];
          type = types.listOf types.str;
          example = [ "jellyfin_users@auth.example.com" ];
          description = ''
            Kanidm groups allowed to sign in, matched against the `groups` claim.
            Leaving this empty (and ssoAdminGroups empty) disables the plugin's
            own RBAC, so access is governed purely by Kanidm's scope map.
          '';
        };

        ssoAdminGroups = mkOption {
          default = [ "jellyfin_admins@auth.othrys.tolok.org" ];
          type = types.listOf types.str;
          example = [ "jellyfin_admins@auth.example.com" ];
          description = "Kanidm groups granted Jellyfin administrator rights";
        };
      };

      config = {
        assertions = [
          {
            assertion = lib.versionAtLeast config.services.jellyfin.package.version "10.11";
            message = "The SSO-Auth and JellyMix plugins pinned by this module target Jellyfin 10.11; bump the plugin versions or the Jellyfin package.";
          }
        ];

        # ── Topology / service catalogue ────────────────────────────────────────
        topology.self.services.jellyfin = {
          name = "Jellyfin";
          info = mkForce "Self-hosted media server";
          details = mkForce (
            {
              Local.text = mkForce "${local.web} (localhost:${toString ports.web})";
            }
            // lib.optionalAttrs cfg.public {
              Public.text = mkForce "${public.web}";
            }
          );
        };

        # ── Glance Services ─────────────────────────────────────────────────────
        modules.services.glance.server_service = [
          {
            title = "Jellyfin";
            url = if cfg.public then "https://${public.web}" else "https://${local.web}";
            check-url = "https://${local.web}/health";
            icon = "si:jellyfin";
          }
        ];

        # ── Traefik Configuration ────────────────────────────────────────
        services.traefik.dynamicConfigOptions.http = {
          routers.jellyfin = {
            rule = "Host(`${local.web}`) ${if cfg.public then "|| Host(`${public.web}`)" else ""}";
            entryPoints = [ "websecure" ];
            service = "jellyfin";
            tls.certResolver = "letsencrypt";
          };

          services.jellyfin.loadBalancer = {
            servers = [
              { url = "http://127.0.0.1:${toString ports.web}"; }
            ];
            healthCheck = {
              path = "/health";
              interval = "10s";
              timeout = "3s";
            };
          };
        };

        # ── Jellyfin Configuration ────────────────────────────────────────
        services.jellyfin = {
          enable = true;
          # Reached only through Traefik on loopback; no ports opened here.
          openFirewall = false;
        };

        # State directories have to exist (and be owned by the service user)
        # before the setup units below run as that user.
        systemd.tmpfiles.rules = [
          "Z ${dataDir} 0700 ${jfUser} ${jfGroup} -"
          "d ${dataDir}/config 0700 ${jfUser} ${jfGroup} -"
          "d ${pluginDir} 0700 ${jfUser} ${jfGroup} -"
          "d ${pluginConfigDir} 0700 ${jfUser} ${jfGroup} -"
        ];

        # ── SOPS Secrets ────────────────────────────────────────
        # Plain file containing only the Kanidm basic secret for the
        # 'jellyfin' OAuth2 client.
        sops.secrets."jellyfin/oidc-secret" = mkIf cfg.sso {
          owner = jfUser;
          group = jfGroup;
          mode = "0400";
        };

        # ── Declarative Plugin Installation ────────────────────────────────
        # Jellyfin insists on writable plugin directories, so the store copies
        # are materialised rather than symlinked. Every start re-syncs them,
        # which also removes versions left behind by an earlier generation.
        systemd.services.jellyfin-plugin-setup = {
          description = "Install Jellyfin plugins declaratively";
          before = [ "jellyfin.service" ];
          wantedBy = [ "jellyfin.service" ];

          serviceConfig = {
            Type = "oneshot";
            User = jfUser;
            Group = jfGroup;
            UMask = "0077";
            StateDirectory = "jellyfin";
            StateDirectoryMode = "0700";
          };
          after = [ "systemd-tmpfiles-setup.service" ];
          wants = [ "systemd-tmpfiles-setup.service" ];

          script = ''
            set -euo pipefail

            ${concatMapStringsSep "\n" (p: ''
              rm -rf "${pluginDir}/${p.pluginName}_"*
            '') knownPlugins}

            ${concatMapStringsSep "\n" (p: ''
              target="${pluginDir}/${p.pluginName}_${p.version}"
              mkdir -p "$target"
              cp -rT "${p}" "$target"
              chmod -R u+w "$target"
            '') enabledPlugins}
          '';
        };

        # ── Declarative SSO (Kanidm OIDC) Setup ────────────────────────────
        # The SSO plugin keeps its settings in an XML file rather than in
        # Jellyfin's own config, and only reads it at startup — hence a unit
        # ordered Before= jellyfin.service.
        systemd.services.jellyfin-sso-setup = mkIf cfg.sso {
          description = "Configure Jellyfin Kanidm OIDC authentication source";
          before = [ "jellyfin.service" ];
          wantedBy = [ "jellyfin.service" ];

          serviceConfig = {
            Type = "oneshot";
            User = jfUser;
            Group = jfGroup;
            UMask = "0077";
            StateDirectory = "jellyfin";
            StateDirectoryMode = "0700";
          };
          after = [
            "systemd-tmpfiles-setup.service"
            "jellyfin-plugin-setup.service"
          ];
          wants = [
            "systemd-tmpfiles-setup.service"
            "jellyfin-plugin-setup.service"
          ];

          script = ''
            set -euo pipefail

            mkdir -p "${pluginConfigDir}"
            ${pkgs.python3}/bin/python3 ${ssoConfigRender} \
              "${ssoConfigTemplate}" \
              "${config.sops.secrets."jellyfin/oidc-secret".path}" \
              "${pluginConfigDir}/SSO-Auth.xml"
          '';
        };

        systemd.services.jellyfin-preseed =
          let
            seedSystemXml = pkgs.writeText "system.xmk" ''
              <?xml version="1.0" encoding="utf-8"?>
              <ServerConfiguration xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
                <IsStartupWizardCompleted>true</IsStartupWizardCompleted>
              </ServerConfiguration>
            '';
          in
          {
            before = [ "jellyfin.service" ];
            wantedBy = [ "jellyfin.service" ];
            serviceConfig = {
              Type = "oneshot";
              User = jfUser;
              Group = jfGroup;
              StateDirectory = "jellyfin";
              StateDirectoryMode = "0700";
            };
            after = [ "systemd-tmpfiles-setup.service" ];
            wants = [ "systemd-tmpfiles-setup.service" ];

            script = ''
              # Jellyfin owns this file after first start — seed it, never overwrite.
              if [ ! -e "${dataDir}/config/system.xml" ]; then
                mkdir -p "${dataDir}/config"
                install -m 0600 ${seedSystemXml} "${dataDir}/config/system.xml"
              fi
            '';
          };
      };
    };
}
