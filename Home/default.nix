{ self, stable, ... } @inputs:
{
  "titouan@laptop" = self.lib.mkHome inputs "titouan" inputs.stable "x86_64-linux" "23.05";
}
