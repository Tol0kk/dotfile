# TODO: create ollama services
{
  flake.nixosModules.ollama =
    {
      pkgs-stable,
      lib,
      config,
      pkgs,
      libCustom,
      ...
    }:
    with lib;
    with libCustom;
    let
      pref = config.preferences;

      public = {
        web = "ollama-web.${pref.topDomain}";
        ollama = "ollama.${pref.topDomain}";
      };
      local = {
        web = "ollama-web.local.${pref.topDomain}";
        ollama = "ollama.local.${pref.topDomain}";
      };
      ports = {
        web = 11111;
        ollama = 11434;
      };
    in
    {
      config = {
        # ── Topology / service catalogue ────────────────────────────────────────
        topology.self.services = {
          open-webui = {
            name = mkForce "Ollama Web UI";
            info = mkForce "Web interface for ollama";
            details.Public.text = mkForce "${public.web}";
            details.Local.text = mkForce "${local.web} (localhost:${toString ports.web})";
          };
          ollama = {
            name = "Ollama";
            info = mkForce "API for ollama";
            details.Public.text = mkForce "${public.ollama}";
            details.Local.text = mkForce "${local.ollama} (localhost:${toString ports.ollama})";
          };
        };

        # ── Ollama Web UI ────────────────────────────────────────
        services.open-webui = {
          enable = true;
          port = ports.web;
          environment = {
            OLLAMA_API_BASE_URL = "https://${local.ollama}";
          };
        };

        # ── Ollama API ────────────────────────────────────────
        services.ollama = {
          enable = true;
          port = ports.ollama;
          package = if config.hardware.nvidia.enabled then pkgs.ollama-vulkan else pkgs.ollama-cpu;
          # acceleration = mkIf config.hardware.nvidia.enabled "cuda";
        };
      };
    };
}
