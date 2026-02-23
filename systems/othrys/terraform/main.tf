terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

locals {
  common_tags = {
    ManagedBy = "Terraform"
    Project   = "Othrys VPS"
  }
}

# ---------------------------------------------------------------------------
# NETWORKING
# ---------------------------------------------------------------------------

resource "oci_core_vcn" "main_vcn" {
  compartment_id = var.compartment_ocid
  cidr_block     = "10.0.0.0/16"
  display_name   = "Main VCN"
  dns_label      = "mainvcn"
  freeform_tags  = local.common_tags
}

resource "oci_core_subnet" "main_subnet" {
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.main_vcn.id
  cidr_block        = "10.0.1.0/24"
  display_name      = "Main Subnet"
  dns_label         = "mainsubnet"  # <-- ADD THIS LINE
  security_list_ids = [oci_core_security_list.main_security_list.id]
  route_table_id    = oci_core_route_table.public_route_table.id
  freeform_tags     = local.common_tags
}

resource "oci_core_internet_gateway" "main_gateway" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main_vcn.id
  display_name   = "Internet Gateway"
  freeform_tags  = local.common_tags
}

resource "oci_core_route_table" "public_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main_vcn.id
  display_name   = "Public Route Table"
  freeform_tags  = local.common_tags

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.main_gateway.id
  }
}

resource "oci_core_security_list" "main_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main_vcn.id
  display_name   = "Main Security List"
  freeform_tags  = local.common_tags

  # Egress: Allow all
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  # Ingress: SSH (22), HTTP (80), HTTPS (443)
  ingress_security_rules {
    source      = "0.0.0.0/0"
    protocol    = "6" # TCP
    description = "SSH"
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    source      = "0.0.0.0/0"
    protocol    = "6" # TCP
    description = "HTTP"
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    source      = "0.0.0.0/0"
    protocol    = "6" # TCP
    description = "HTTPS"
    tcp_options {
      min = 443
      max = 443
    }
  }
  ingress_security_rules {
     source      = "0.0.0.0/0"
     protocol    = "6" # TCP
     tcp_options {
       min = 25565
       max = 25565
     }
   }
}

resource "oci_core_network_security_group" "minecraft_nsg" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main_vcn.id
  display_name   = "Minecraft Server NSG"
}

resource "oci_core_network_security_group_security_rule" "minecraft_tcp" {
  network_security_group_id = oci_core_network_security_group.minecraft_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "0.0.0.0/0"
  tcp_options {
    destination_port_range {
      min = 25565
      max = 25565
    }
  }
}

resource "oci_core_network_security_group_security_rule" "minecraft_udp" {
  network_security_group_id = oci_core_network_security_group.minecraft_nsg.id
  direction                 = "INGRESS"
  protocol                  = "17" # UDP
  source                    = "0.0.0.0/0"
  udp_options {
    destination_port_range {
      min = 25565
      max = 25565
    }
  }
}

resource "oci_core_network_security_group_security_rule" "minecraft_egress" {
  network_security_group_id = oci_core_network_security_group.minecraft_nsg.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
}

# ---------------------------------------------------------------------------
# STORAGE & IMAGE MANAGEMENT
# ---------------------------------------------------------------------------

module "nixos_image" {
  source     = "./modules/nix_builder"
  flake_attr = var.nix_flake_attr
}

resource "oci_objectstorage_bucket" "nixos_bucket" {
  compartment_id = var.compartment_ocid
  namespace      = var.namespace
  name           = "nixos-image-bucket"
  access_type    = "NoPublicAccess"
  freeform_tags  = local.common_tags
}

resource "oci_objectstorage_object" "nixos_image" {
  namespace = var.namespace
  bucket    = oci_objectstorage_bucket.nixos_bucket.name
  object    = "nixos-aarch64.qcow2"
  source    = module.nixos_image.image_path
}

resource "oci_core_image" "nixos" {
  compartment_id = var.compartment_ocid
  display_name   = "NixOS ARM64"
  launch_mode    = "PARAVIRTUALIZED"
  freeform_tags  = local.common_tags

  image_source_details {
    source_type    = "objectStorageTuple"
    namespace_name = var.namespace
    bucket_name    = oci_objectstorage_bucket.nixos_bucket.name
    object_name    = oci_objectstorage_object.nixos_image.object
  }

  timeouts {
    create = "60m"
  }
}

# ---------------------------------------------------------------------------
# IMAGE CAPABILITIES (FIXED)
# ---------------------------------------------------------------------------

resource "oci_core_shape_management" "nixos_a1_compat" {
  compartment_id = var.compartment_ocid
  image_id       = oci_core_image.nixos.id
  shape_name     = "VM.Standard.A1.Flex"
  depends_on     = [oci_core_image.nixos]
}

// Boiler plate to find schema version
data "oci_core_compute_global_image_capability_schemas" "global_schemas" {
  compartment_id = var.compartment_ocid
}
data "oci_core_compute_global_image_capability_schemas_versions" "compute_global_image_capability_schemas_versions" {
  compute_global_image_capability_schema_id = data.oci_core_compute_global_image_capability_schema.compute_global_image_capability_schema.id
}
data "oci_core_compute_global_image_capability_schema" "compute_global_image_capability_schema" {
  compute_global_image_capability_schema_id = data.oci_core_compute_global_image_capability_schemas.compute_global_image_capability_schemas.compute_global_image_capability_schemas[0].id
}
data "oci_core_compute_global_image_capability_schemas" "compute_global_image_capability_schemas" {}

resource "oci_core_compute_image_capability_schema" "nixos_caps" {
  compartment_id                                      = var.compartment_ocid
  image_id                                            = oci_core_image.nixos.id
    compute_global_image_capability_schema_version_name = data.oci_core_compute_global_image_capability_schemas_versions.compute_global_image_capability_schemas_versions.compute_global_image_capability_schema_versions[0].name

  schema_data = {
    "Compute.Firmware" = jsonencode({
      descriptorType = "enumstring"
      source         = "IMAGE"
      defaultValue   = "UEFI_64"
      values         = ["UEFI_64"]
    })

    "Compute.LaunchMode" = jsonencode({
      descriptorType = "enumstring"
      source         = "IMAGE"
      defaultValue   = "PARAVIRTUALIZED"
      values         = ["PARAVIRTUALIZED"]
    })

    "Storage.BootVolumeType" = jsonencode({
      descriptorType = "enumstring"
      source         = "IMAGE"
      defaultValue   = "PARAVIRTUALIZED"
      values         = ["PARAVIRTUALIZED"]
    })

    "Network.AttachmentType" = jsonencode({
      descriptorType = "enumstring"
      source         = "IMAGE"
      defaultValue   = "PARAVIRTUALIZED"
      values         = ["PARAVIRTUALIZED"]
    })
  }
}

# ---------------------------------------------------------------------------
# COMPUTE
# ---------------------------------------------------------------------------

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

resource "oci_core_instance" "othrys_nixos" {
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  display_name        = "Othrys Nixos Instance"
  shape               = "VM.Standard.A1.Flex"
  freeform_tags       = local.common_tags

  shape_config {
    memory_in_gbs = 24
    ocpus         = 4
  }

  source_details {
    source_type             = "image"
    source_id               = oci_core_image.nixos.id
    boot_volume_vpus_per_gb = 10
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.main_subnet.id
    assign_public_ip = true
    hostname_label   = "othrys"
  }

  depends_on = [
    oci_core_shape_management.nixos_a1_compat,
    oci_core_compute_image_capability_schema.nixos_caps
  ]
}

# ---------------------------------------------------------------------------
# BLOCK STORAGE
# ---------------------------------------------------------------------------

resource "oci_core_volume" "nixos_data_volume" {
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  display_name        = "Othrys Persistant Data 200g"
  size_in_gbs         = 200
  freeform_tags       = local.common_tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "oci_core_volume_attachment" "othrys_data_attachment" {
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.othrys_nixos.id
  volume_id       = oci_core_volume.nixos_data_volume.id
  display_name    = "Othrys Data Attachement"
}

# ---------------------------------------------------------------------------
# DNS (CLOUDFLARE)
# ---------------------------------------------------------------------------

resource "cloudflare_record" "root" {
  zone_id = var.cloudflare_zone_id
  name    = "oci"
  content = oci_core_instance.othrys_nixos.public_ip
  type    = "A"
  ttl     = 3600
  comment = "Managed by Terraform - Othrys Instance"
  proxied = false
}
