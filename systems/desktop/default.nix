inputs: {
  system = "x86_64-linux";
  nixpkgs = inputs.nixpkgs-unstable;
  allowLocalDeployment = true;
  withHomeManager = true;
}
