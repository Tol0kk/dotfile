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