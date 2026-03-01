{
  flake.nixosModules.docker =
    {
      lib,
      pkgs,
      ...
    }:
    {
      virtualisation.docker.enable = true;
      # hardware.nvidia-container-toolkit.enable = true;
      virtualisation.docker.autoPrune.enable = true;
      virtualisation.docker.daemon.settings = {
        default-ulimits = {
          # Some docker image need larger limits (Java projects... :/)
          nofile = {
            Hard = 524288;
            Name = "nofile";
            Soft = 524288;
          };
        };
      };
      environment.systemPackages = with pkgs; [
        docker-compose
      ];
    };
}
