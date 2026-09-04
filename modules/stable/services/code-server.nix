{
  flake.nixosModules.code-server =
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
        optionalAttrs
        ;
      pref = config.preferences;
      cfg = config.modules.services.code-server;

      local = "code.local.${pref.topDomain}";
      public = "code.${pref.topDomain}";

      port = 5049;

      # Every host code-server answers on. Each one needs its own /oauth2/
      # passthrough router AND its own redirect URL registered in Kanidm.
      hosts = [ local ] ++ lib.optional cfg.public public;
      hostRule = lib.concatMapStringsSep " || " (h: "Host(`${h}`)") hosts;
    in
    {
      # ── Modules Settings ────────────────────────────────────────
      options.modules.services.code-server = {
        public = mkOption {
          default = pref.public;
          type = types.bool;
        };

        user = mkOption {
          type = types.str;
          default = "code";
          description = ''
            User code-server runs as. Everything typed into the web terminal runs
            with this user's privileges, so give it its own account rather than
            reusing a login user.
          '';
        };

        stateDir = mkOption {
          type = types.str;
          default = "/var/lib/code-server";
          description = "Home of the code-server user: workspaces, extensions, settings.";
        };

        extraPackages = mkOption {
          type = types.listOf types.package;
          default = with pkgs; [
            git
            gnumake
            ripgrep
            fd
            nixd
            nixfmt-rfc-style
          ];
          description = "Toolchain available on code-server's PATH and in its terminal.";
        };

        enableNixLd = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Enable programs.nix-ld system-wide. Required for extensions that ship
            prebuilt dynamically-linked binaries (rust-analyzer, Pylance, most
            debug adapters) — without it they fail to start with no useful error.
          '';
        };

        proxyPorts = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Expose dev servers through code-server's port proxy. Path-based
            (/proxy/3000/) is covered by the same auth middleware. Setting
            proxyDomain additionally enables *.code.<domain>, which needs a
            wildcard cert and its own router — see the commented block below.
          '';
        };

        sessionHours = mkOption {
          type = types.int;
          default = 12;
          description = ''
            Informational: oauth2-proxy's cookie lifetime should be at least this
            long. When the SSO session expires, VS Code's WebSocket reconnect gets
            a 302 it cannot follow and the tab hangs on "reconnecting" forever.
          '';
        };
      };

      config = {
        # ── State dir owned by the service user ─────────────────────────────────
        users.users.${cfg.user} = {
          isSystemUser = true;
          group = cfg.user;
          home = cfg.stateDir;
          createHome = true;
          shell = pkgs.bashInteractive;
        };
        users.groups.${cfg.user} = { };

        systemd.tmpfiles.rules = [
          "d ${cfg.stateDir} 0750 ${cfg.user} ${cfg.user} - -"
          "d ${cfg.stateDir}/workspace 0750 ${cfg.user} ${cfg.user} - -"
        ];

        # ── code-server itself ──────────────────────────────────────────────────
        # auth = "none" is only safe because host is loopback and Traefik gates it.
        services.code-server = {
          enable = true;
          inherit (cfg) user extraPackages;
          group = cfg.user;
          host = "127.0.0.1";
          inherit port;
          auth = "none";

          userDataDir = "${cfg.stateDir}/data";
          extensionsDir = "${cfg.stateDir}/extensions";

          disableTelemetry = true;
          disableUpdateCheck = true;
          disableWorkspaceTrust = true;
          disableGettingStartedOverride = true;

          extraArguments = [ "--app-name=code.${pref.topDomain}" ];
        }
        // optionalAttrs cfg.proxyPorts {
          proxyDomain = if cfg.public then public else local;
        };

        # Extensions ship non-NixOS binaries; nix-ld makes them runnable.
        programs.nix-ld.enable = mkIf cfg.enableNixLd true;

        # ── Topology / service catalogue ────────────────────────────────────────
        topology.self.services = {
          code-server = {
            name = "code-server";
            info = mkForce "Browser VS Code (SSO via oauth2-proxy + Kanidm)";
            details = {
              "Local".text = mkForce "${local} (localhost:${toString port})";
            }
            // lib.optionalAttrs cfg.public {
              "Public".text = mkForce "${public}";
            };
          };
        };

        # ── Glance Services ─────────────────────────────────────────────────────
        modules.services.glance.server_service = [
          {
            title = "code-server";
            url = if cfg.public then "https://${public}" else "https://${local}";
            check-url = "https://${local}/healthz";
            icon = "si:visualstudiocode";
          }
        ];

        # ── Traefik Configuration ───────────────────────────────────────────────
        # code-server has no OIDC support, so the whole app sits behind
        # kanidm-auth. Unlike TINO, there is no unauthenticated surface at all.
        services.traefik.dynamicConfigOptions = {
          http = {
            services.code-server.loadBalancer = {
              servers = [
                { url = "http://127.0.0.1:${toString port}"; }
              ];
              # Health checks hit the backend directly, bypassing middlewares,
              # so /healthz stays reachable without a session.
              healthCheck = {
                path = "/healthz";
                interval = "15s";
                timeout = "3s";
              };
              # Keeps the terminal from feeling laggy on streamed output.
              responseForwarding.flushInterval = "10ms";
            };

            routers.code-server = {
              entryPoints = [ "websecure" ];
              rule = hostRule;
              priority = 10;
              service = "code-server";
              tls.certResolver = "letsencrypt";
              middlewares = [ "kanidm-auth" ];
            };

            # OAuth2 login/callback — must outrank the catch-all and must NOT
            # carry the auth middleware, or you get a redirect loop.
            routers.code-server-oauth2 = {
              entryPoints = [ "websecure" ];
              rule = "(${hostRule}) && PathPrefix(`/oauth2/`)";
              priority = 200;
              service = "oauth2-proxy";
              tls.certResolver = "letsencrypt";
            };

            # ── Optional: subdomain port proxying ───────────────────────────────
            # code-server maps *.code.<domain> to forwarded ports. Needs a
            # wildcard cert (DNS-01) on the resolver before enabling.
            #
            # routers.code-server-ports = {
            #   entryPoints = [ "websecure" ];
            #   rule = "HostRegexp(`^[a-z0-9-]+\\.${builtins.replaceStrings ["."] ["\\."] public}$`)";
            #   priority = 5;
            #   service = "code-server";
            #   tls = {
            #     certResolver = "letsencrypt";
            #     domains = [ { main = public; sans = [ "*.${public}" ]; } ];
            #   };
            #   middlewares = [ "kanidm-auth" ];
            # };
          };
        };
      };
    };
}
