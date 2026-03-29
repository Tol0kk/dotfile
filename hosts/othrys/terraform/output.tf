output "instance_public_ip" {
  description = "Public IP address of the Olympos instance"
  value       = oci_core_instance.othrys_nixos.public_ip
}
