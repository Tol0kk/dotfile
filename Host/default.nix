inputs: {
  laptop = {
    system = "x86_64-linux";
    mainUser = "titouan";
    nixpkgs = inputs.nixpkgs-unstable;
    allowLocalDeployment = true;
  };
  desktop = {
    system = "x86_64-linux";
    mainUser = "titouan";
    nixpkgs = inputs.nixpkgs-unstable;
    allowLocalDeployment = true;
  };
  servrock = {
    system = "aarch64-linux";
    mainUser = "titouan";
    nixpkgs = inputs.nixpkgs-stable;
    allowLocalDeployment = false;
  };
}
