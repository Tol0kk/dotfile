{ inputs, pkgs, config, ... }:

{
  imports = [
    ./nvidia
    ./virtualisation
    ./fonts
  ];
}
