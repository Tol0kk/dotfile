variable "tenancy_ocid" {
  description = "OCID of the tenancy"
  type        = string
}

variable "user_ocid" {
  description = "OCID of the user calling the API"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint for the API signing key"
  type        = string
}

variable "private_key_path" {
  description = "Path to the API signing private key"
  type        = string
}

variable "region" {
  description = "OCI Region (e.g., us-ashburn-1)"
  type        = string
}

variable "compartment_ocid" {
  description = "The OCID of the compartment where resources will be created"
  type        = string
}

variable "namespace" {
  description = "The Object Storage namespace"
  type        = string
}

variable "cloudflare_api_token" {
  description = "Cloudflare API Token with DNS edit permissions"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "The Zone ID of your domain in Cloudflare"
  type        = string
}

variable "nix_flake_attr" {
  description = "NixosConfiguration to use"
  type        = string
  default     = "../../../.#oci-oci"
}
