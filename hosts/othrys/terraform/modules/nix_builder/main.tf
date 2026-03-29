variable "flake_attr" {
  description = "The flake attribute to build (e.g., .#oci-nixos)"
  type        = string
}

# This executes the script during the 'plan' phase
data "external" "nixos_build" {
  program = ["bash", "${path.module}/build_nixos.sh"]

  # Pass arguments to the script via stdin
  query = {
    flake_attr = var.flake_attr
  }
}

output "image_path" {
  # This extracts the path from the script's JSON output
  value = data.external.nixos_build.result.image_path
}

output "image_digest" {
  # Since the path is in /nix/store, the path ITSELF is the unique ID.
  # We can use the path string as a trigger for updates.
  value = data.external.nixos_build.result.image_path
}
