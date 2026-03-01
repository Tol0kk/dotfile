{
  targetSystem = "x86_64-linux";
  withHomeManager = false;
  isUnstable = true;
  hasUnstable = true;
  isPure = true;
  remote = {
    targetHost = "desktop.tolok.org";
    targetUser = "titouan";
  };
  withOCI = true;
  allowUnfree = true;

  stateVersion = "25.11";
}
