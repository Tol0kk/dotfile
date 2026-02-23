{
  libCustom,
  username,
  self,
  config,
  ...
}:
{
  modules = {
    users.titouan.enable = true;
    services = {
      element.enable = false;
      signal.enable = false;
    };
    shell = {
      bash.enable = true;
      fish.enable = true;
      starship.enable = true;
      zellij.enable = true;
      zoxide.enable = true;
    };
  };
  sops.defaultSopsFile = "${self}/home/titouan@laptop/secrets.yaml";
}
