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
  stateVersion = "25.11";
  homeStateVersion = "25.11";
}
