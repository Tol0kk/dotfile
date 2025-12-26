inputs: {
  system = "aarch64-linux";
  nixpkgs = inputs.nixpkgs-stable;
  allowLocalDeployment = false;
  targetHost = "servrock.tolok.org";
  targetUser = "odin";
}
