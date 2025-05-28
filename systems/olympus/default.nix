inputs: {
  system = "aarch64-linux";
  mainUser = "odin";
  nixpkgs = inputs.nixpkgs-stable;
  allowLocalDeployment = false;
  targetHost = "servrock";
}
