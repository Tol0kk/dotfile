{
  rust = {
    path = ./rust;
    description = "Simple Rust flake";
    welcomeText = ''
      # Initialize Project
      ```sh
      mkdir "<PROGRAM>"
      cd "<PROGRAM>"
      nix flake init template rust
      direnv allow
      ```
      ## File to check
      - flake.nix (for package instruction and dependencies)
      - rust-toolchain.toml (for target)
      - Cargo.toml 
    '';
  };
  python = {
    path = ./python;
    description = "TODO Simple Python flake";
  };
  java = {
    path = ./java;
    description = "TODO Simple Java flake";
  };
}
