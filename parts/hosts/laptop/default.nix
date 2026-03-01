{
  targetSystem = "x86_64-linux";
  withHomeManager = false;
  isUnstable = true;
  isPure = true;
  remote = {
    targetHost = "laptop.tolok.org";
    targetUser = "titouan";
  };
  withOCI = true;
  allowUnfree = true;
  stateVersion = "25.11";
}
