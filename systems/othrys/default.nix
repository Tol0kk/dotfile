inputs: {
  system = "aarch64-linux";
  nixpkgs = inputs.nixpkgs-stable;
  allowLocalDeployment = false;
  targetHost = "oci.tolok.org";
  targetUser = "gaia"; # Gaïa
  withOCI = true;
}
