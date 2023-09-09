{ self, ... } @ inputs: {
  laptop = self.lib.mkSystem inputs "laptop" inputs.stable "x86_64-linux";
  desktop = self.lib.mkSystem inputs "desktop" inputs.stable "x86_64-linux";
}
