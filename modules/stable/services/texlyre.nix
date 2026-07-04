{
  flake.nixosModules.texlyre =
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
        ;
      pref = config.preferences;
      cfg = config.modules.services.texlyre;
      local = "typst.local.${pref.topDomain}";
      public = "typst.${pref.topDomain}";
      port = 3048;

      # `scripts/setup-assets.cjs` downloads two core assets from GitHub at build
      # time, which the Nix sandbox blocks. We prefetch them here and drop them
      # into public/core/ during postPatch so the script skips the download.
      drawioEmbed = pkgs.fetchFromGitHub {
        owner = "TeXlyre";
        repo = "drawio-embed-mirror";
        rev = "v29.7.9";
        # nix build -> copy the "got:" hash it prints in here.
        hash = "sha256-mj+i+6n14Koo9TYaygrCgFg0OLfBZnnL6rE3PkJGa9w=";
      };
      busytexAssets = pkgs.fetchurl {
        url = "https://github.com/TeXlyre/texlyre-busytex/releases/download/assets-v1.1.1/busytex-assets.tar.gz";
        # nix build -> copy the "got:" hash it prints in here.
        hash = "sha256-CVDSmgjA9gAOVMqCef42X4ATF59ZVjjtPt7vjDDqBWc=";
      };

      # TeXlyre is a static, local-first LaTeX & Typst web editor (React/Vite SPA).
      # All compilation happens client-side via WASM, so there is no backend
      # daemon: we build the static site into a derivation and serve it from a
      # localhost-only nginx, with Traefik as the single TLS/web path in front
      # (mirroring how adguardhome is bound to 127.0.0.1 behind Traefik).
    in
    {
      options.modules.services.texlyre = {
        public = mkOption {
          default = pref.public;
          type = types.bool;
        };

        # Gate access behind Kanidm like the AdGuard dashboard. TeXlyre is
        # local-first (data lives in the browser), so if you want a genuinely
        # open public editor set this to false to drop the auth middleware.
        auth = mkOption {
          default = true;
          type = types.bool;
        };

        package = mkOption {
          type = types.package;
          description = "The built TeXlyre static site (dist output).";
          default = pkgs.buildNpmPackage rec {
            pname = "texlyre";
            version = "0.8.0";

            src = pkgs.fetchFromGitHub {
              owner = "TeXlyre";
              repo = "texlyre";
              rev = "v${version}";
              # nix build once -> copy the "got:" hash it prints in here.
              hash = "sha256-aBGhTJS/UDcWOhzP4HtIQO5ZjNGXTj3oPLje65HIhe4=";
            };

            # nix build once -> copy the correct npm deps hash in here.
            npmDepsHash = "sha256-davqKXgSwjPM0QQ/moo5sjh7e9wVXjH30SrFC4opmuQ=";

            postPatch = ''
              # Serve at the domain root instead of the GitHub-Pages /texlyre/ base.
              substituteInPlace vite.config.ts \
                --replace-fail "const basePath = '/texlyre/';" "const basePath = '/';"
              substituteInPlace texlyre.config.ts \
                --replace-fail "baseUrl: '/texlyre/'," "baseUrl: '/',"

              # buildNpmPackage uses package-lock.json; drop the other lockfiles
              # so the repo's pm.cjs helper also resolves to npm during the build.
              rm -f pnpm-lock.yaml yarn.lock

              # Pre-place the two GitHub-downloaded core assets so setup-assets.cjs
              # finds them already present and skips its (sandboxed-out) network fetch.
              mkdir -p public/core/drawio-embed public/core
              cp -r ${drawioEmbed}/drawio-embed/. public/core/drawio-embed/
              tar -xzf ${busytexAssets} -C public/core
              chmod -R u+w public/core/drawio-embed public/core/busytex
            '';

            # The repo's default `build:prod` also runs eslint/biome/i18n steps
            # that can fail in the sandbox; `build:local` is the minimal build
            # (codegen + tsc + vite build).
            dontNpmBuild = true;
            buildPhase = ''
              runHook preBuild
              npm run build:local
              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall
              cp -r dist $out
              runHook postInstall
            '';

            meta = {
              description = "Local-first LaTeX & Typst web editor";
              homepage = "https://github.com/TeXlyre/texlyre";
              license = lib.licenses.agpl3Only;
            };
          };
        };
      };

      config = {
        # ── Topology / service catalogue ────────────────────────────────────────
        topology.self.services = {
          texlyre = {
            name = "TeXlyre";
            info = lib.mkForce "Local-first LaTeX & Typst editor";
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
            title = "TeXlyre";
            url = if cfg.public then "https://${public}" else "https://${local}";
            check-url = "https://${local}/";
            icon = "si:latex";
          }
        ];

        # ── Traefik Configuration ───────────────────────────────────────────────
        services.traefik.dynamicConfigOptions = {
          http = {
            services.texlyre.loadBalancer = {
              servers = [
                { url = "http://127.0.0.1:${toString port}"; }
              ];
              healthCheck = {
                path = "/";
                interval = "10s";
                timeout = "3s";
              };
            };
            routers.texlyre = {
              entryPoints = [ "websecure" ];
              rule = if cfg.public then "Host(`${local}`) || Host(`${public}`)" else "Host(`${local}`)";
              service = "texlyre";
              tls.certResolver = "letsencrypt";
              middlewares = lib.optionals cfg.auth [ "kanidm-auth" ];
            };
          };
        };

        # ── Static file server (localhost only; Traefik is the web path) ─────────
        services.nginx = {
          enable = true;
          virtualHosts."texlyre" = {
            listen = [
              {
                addr = "127.0.0.1";
                inherit port;
              }
            ];
            root = "${cfg.package}";
            locations = {
              # SPA fallback (TeXlyre also uses #hash routing, but this is harmless).
              "/".tryFiles = "$uri $uri/ /index.html";
              # Ensure WASM is served with the correct MIME type.
              "~ \\.wasm$".extraConfig = "default_type application/wasm;";
            };
          };
        };
      };
    };
}
