{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.services.traefik;

  dump-cert = pkgs.writeShellScriptBin "dump-cert" ''
    ${pkgs.traefik-certs-dumper}/bin/traefik-certs-dumper file --domain-subdir --crt-name public --key-name private --source /var/lib/traefik/acme.json --dest /var/lib/certificates/ --version v2
    ${pkgs.coreutils}/bin/chown kanidm /var/lib/certificates/sso.tolok.org/private.key
    ${pkgs.coreutils}/bin/chown kanidm /var/lib/certificates/sso.tolok.org/public.crt
  '';

  mytraefik = let
    oidc-auth_author = "sevensolutions";
    oidc-auth_name = "traefik-oidc-auth";
    oidc-auth_version = "0.6.1";
  in
    pkgs.traefik.overrideAttrs (oldAttrs: {
      postInstall =
        oldAttrs.postInstall or ''
          mkdir -p $out/bin/plugins-local/src/github.com/${oidc-auth_author}/
          cp -r ${
            pkgs.fetchFromGitHub {
              owner = oidc-auth_author;
              repo = oidc-auth_name;
              rev = "refs/tags/v${oidc-auth_version}";
              sha256 = "sha256-PZbAlxtPXpihKt/Jo3OFVdn8LXslUNIicTNIzacpsBc=";
            }
          } $out/bin/plugins-local/src/github.com/${oidc-auth_author}/${oidc-auth_name}
        '';
    });
in {
  options.modules.services.traefik = {
    enable = mkOption {
      description = "Enable Traefik Reverse Proxy service";
      type = types.bool;
      default = false;
    };
    openFirewall = mkOption {
      description = "Open port in the firewall for Traefik (80,443)";
      type = types.bool;
      default = false;
    };
    domain = mkOption {
      description = "Root domain";
      type = types.str;
      default = "localhost";
    };
    api_env_path = mkOption {
      description = "Secret EnvironmentFile used by trafik to use cloudflare, (CF_API_KEY, CF_API_EMAIL, TRAEFIK_AUTH_CLIENT_SECRETS)";
      type = types.nullOr types.path;
      default = null;
    };
    certResolver = mkOption {
      description = "Certificat resolver, use self sign if null, need api_env_path if not null";
      type = with types;
        nullOr (enum [
          "letsencrypt"
        ]);
      default = null;
    };
    tlsConfig = mkOption {
      type = types.nullOr types.attrs;
      default =
        if cfg.certResolver != null
        then {inherit certResolver;}
        else {};
      visible = false; # Hidden from documentation
    };
  };

  config = mkIf cfg.enable {
    topology.self.services = {
      traefik = {
        name = "Traefik";
        info = lib.mkForce "Reverse Proxy / MiddleWare";
        details = lib.mkForce {};
      };
    };

    networking.hosts = {
      "127.0.0.1" = [
        "media.localhost"
        "home.localhost"
      ];
    };

    # Open Ports
    networking.firewall.allowedTCPPorts = lib.optional cfg.openFirewall [
      80
      443
    ];

    # Traefik Service
    services.traefik = {
      package = mytraefik;
      enable = true;
      staticConfigOptions = {
        serversTransport.insecureSkipVerify = true;
        accessLog = {
          addInternals = true;
        };
        # TODO make conditional Add Prometheus support
        # entryPoints."metrics".address = ":8082";
        # metrics.prometheus = {
        #   entryPoint = "metrics";
        #   addEntryPointsLabels = true;
        #   addRoutersLabels = true;
        # };
        certificatesResolvers = {
          # vpn.tailscale = {};

          letsencrypt = {};

          # lib.optionals (cfg.certResolver == "letsencrypt") {
          #   acme = {
          #     email = "personal@tolok.org";
          #     storage = "/var/lib/traefik/acme.json";
          #     dnsChallenge = {
          #       provider = "cloudflare";
          #     };
          #   };
          # };
        };
        experimental = {
          localPlugins = {
            traefik-oidc-auth = {
              modulename = "github.com/sevensolutions/traefik-oidc-auth";
            };
          };
        };
        entryPoints.web = {
          address = ":80";
          http.redirections.entryPoint = {
            to = "websecure";
            scheme = "https";
            permanent = true;
          };
        };
        entryPoints.websecure = {
          address = ":443";
          # http.tls.domains = [
          #   {
          #     main = cfg.domain;
          #     sans = [ "*.${cfg.domain}" ];
          #   }
          # ];
          http.tls = {};
          # http.tls.certResolver = lib.optionals (cfg.certResolver != null) cfg.certResolver;
        };
      };

      # dynamicConfigOptions.http = {
      #   middlewares = {
      #     oidc-auth = {
      #       plugin.traefik-oidc-auth = {
      #         provider = {
      #           Url = "https://sso.tolok.org/oauth2/openid/traefik-auth";
      #           ClientId = "traefik-auth"; # System ID in Kanidm
      #           ClientSecretEnv = "TRAEFIK_AUTH_CLIENT_SECRETS"; # ClientSecret from Kanidm on the tarfik-auth service
      #           TokenValidation = "IdToken";
      #           UsePkce = true;
      #         };
      #         Scopes = [
      #           "openid"
      #           "profile"
      #         ];
      #       };
      #     };
      #   };
      # };
    };

    systemd.services.traefik.serviceConfig = {
      AmbientCapabilities = ["CAP_NET_BIND_SERVICE"];
      CapabilityBoundingSet = ["CAP_NET_BIND_SERVICE"];
    };

    # Traefik certs dumper
    # systemd.services.traefik-dumper = {
    #   enable = true;
    #   path = [
    #     pkgs.getent
    #     pkgs.traefik-certs-dumper
    #   ];
    #   serviceConfig = {
    #     ExecStart = "${dump-cert}/bin/dump-cert";
    #   };
    #   wantedBy = [ "multi-user.target" ];
    #   partOf = [ "traefik.service" ];
    #   after = [
    #     "traefik.service"
    #   ];
    # };
  };
}
