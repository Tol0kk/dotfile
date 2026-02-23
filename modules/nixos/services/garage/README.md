# Garage S3 — NixOS Module Setup & Usage Guide

## What is Garage?

Garage is a lightweight, self-hosted, S3-compatible object storage service.
It's simpler and more resource-efficient than MinIO, supports geo-distribution,
and runs well even on ARM devices or small VPS instances.

---

## Architecture

```
                      Internet
                         │
                    ┌────┴─────┐
                    │ Traefik  │  :443 TLS
                    └────┬─────┘
          ┌──────────────┼──────────────┐
          │              │              │
   s3.example.com   *.s3.example.com   *.web.s3.example.com
   (path-style)     (vhost-style)      (static websites)
          │              │              │
          ▼              ▼              ▼
     ┌──────────────────────────────────────┐
     │            Garage daemon             │
     │                                      │
     │  S3 API   :3900  ← bucket ops       │
     │  RPC      :3901  ← inter-node sync  │
     │  Web      :3902  ← static sites     │
     │  Admin    :3903  ← management        │
     └──────────────────────────────────────┘
          │                    │
     /var/lib/garage/     /var/lib/garage/
         meta/               data/
       (SSD ideal)        (HDD is fine)
```

---

## Step 1 — Generate secrets

On your server, create the RPC secret. This is a 32-byte hex string shared
across all nodes in the cluster:

```bash
mkdir -p /run/secrets
openssl rand -hex 32 > /run/secrets/garage-rpc-secret
chmod 600 /run/secrets/garage-rpc-secret
```

The file content must be in the format:
```
GARAGE_RPC_SECRET=<hex_string>
```

So write it like this:
```bash
echo "GARAGE_RPC_SECRET=$(openssl rand -hex 32)" > /run/secrets/garage-rpc-secret
chmod 600 /run/secrets/garage-rpc-secret
```

Optionally, generate an admin token:
```bash
openssl rand -hex 32 > /run/secrets/garage-admin-token
chmod 600 /run/secrets/garage-admin-token
```

> **Production tip:** use `agenix` or `sops-nix` to manage secrets declaratively.

---

## Step 2 — Single-node configuration (simplest)

```nix
# In your host configuration:
{
  imports = [ ./garage.nix ];

  modules.services.garage = {
    enable = true;

    # Domain (must have DNS A record → your server IP)
    domain = "s3.example.com";

    # Single-node: no replication
    replicationMode = "none";

    # Storage paths
    dataDir = "/var/lib/garage/data";
    metaDir = "/var/lib/garage/meta";

    # Secret file (env format: GARAGE_RPC_SECRET=xxx)
    rpcSecretFile = "/run/secrets/garage-rpc-secret";

    # Admin API token (inline for dev, use file for prod)
    adminToken = "my-super-secret-admin-token";

    # Prometheus metrics token (optional)
    # metricsToken = "my-metrics-token";

    # Traefik integration (needs your traefik module)
    useTraefik = true;
  };
}
```

---

## Step 3 — Deploy and initialize the cluster

```bash
# Deploy
sudo nixos-rebuild switch

# Check that garage is running
systemctl status garage

# View the node ID
garage status
```

You should see output like:
```
==== HEALTHY NODES ====
ID                  Hostname  Address          Tag  Zone  Capacity
abcdef1234567890    myhost    127.0.0.1:3901               NO ROLE ASSIGNED
```

### Assign a role to the node

```bash
# Assign the node to zone "dc1" with 10GB capacity
garage layout assign -z dc1 -c 10G <NODE_ID>

# Preview the layout
garage layout show

# Apply the layout
garage layout apply --version 1
```

> For subsequent layout changes, increment the `--version` number.

---

## Step 4 — Create a bucket and access key

```bash
# Create a bucket
garage bucket create my-bucket

# Create an access key
garage key create my-app-key

# Grant read+write to the bucket
garage bucket allow my-bucket --read --write --key my-app-key

# Show key details (you'll need the Access Key ID and Secret Key)
garage key info my-app-key
```

Output will look like:
```
Key name: my-app-key
Key ID: GKxxxxxxxxxxxxxxxxxx
Secret key: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

---

## Step 5 — Use from clients

### DNS setup

Create the following DNS records:

| Record | Type | Value |
|--------|------|-------|
| `s3.example.com` | A | `<your-server-ip>` |
| `*.s3.example.com` | A | `<your-server-ip>` (for vhost-style) |
| `*.web.s3.example.com` | A | `<your-server-ip>` (for static sites) |

### AWS CLI

```bash
# Configure
aws configure
# → Access Key ID:     GKxxxxxxxxxxxxxxxxxx
# → Secret Access Key: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
# → Region:            garage
# → Output format:     json

# Upload a file
aws --endpoint-url https://s3.example.com s3 cp myfile.txt s3://my-bucket/

# List bucket contents
aws --endpoint-url https://s3.example.com s3 ls s3://my-bucket/

# Download
aws --endpoint-url https://s3.example.com s3 cp s3://my-bucket/myfile.txt ./downloaded.txt
```

### rclone

```bash
# Configure (~/.config/rclone/rclone.conf)
rclone config
# → New remote → name: garage
# → Storage type: s3
# → Provider: Other
# → access_key_id: GKxxxxxxxxxxxxxxxxxx
# → secret_access_key: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
# → region: garage
# → endpoint: https://s3.example.com
# → Leave everything else default

# Usage
rclone ls garage:my-bucket
rclone copy ./local-dir garage:my-bucket/remote-dir
rclone sync ./local-dir garage:my-bucket/backup
```

### s3cmd

```bash
cat > ~/.s3cfg << 'EOF'
[default]
access_key = GKxxxxxxxxxxxxxxxxxx
secret_key = xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
host_base = s3.example.com
host_bucket = %(bucket)s.s3.example.com
use_https = True
signature_v2 = False
EOF

s3cmd ls s3://my-bucket/
s3cmd put myfile.txt s3://my-bucket/
```

### In NixOS (as a Nix binary cache)

```nix
{
  nix.settings = {
    substituters = [ "s3://nix-cache?endpoint=https://s3.example.com&region=garage" ];
    trusted-public-keys = [ "my-cache-key:xxxx" ];
  };
}
```

---

## Step 6 — Static website hosting (optional)

```bash
# Create and configure a website bucket
garage bucket create my-website
garage bucket website my-website --allow

# Create an access key and grant permissions
garage key create website-deployer
garage bucket allow my-website --read --write --key website-deployer

# Upload your static site
aws --endpoint-url https://s3.example.com \
  s3 sync ./my-site/ s3://my-website/
```

The site is then available at: `https://my-website.web.s3.example.com`

---

## Multi-node cluster setup

For production, run Garage on multiple nodes with `replicationMode = "3"`.

### On each node

```nix
modules.services.garage = {
  enable = true;
  domain = "s3.example.com";
  replicationMode = "3";              # ← 3 replicas
  rpcSecretFile = "/run/secrets/garage-rpc-secret";  # same secret on all nodes!

  # RPC public addr must be reachable by other nodes
  rpcPublicAddr = "10.0.0.X:3901";   # ← this node's LAN/VPN IP

  useTraefik = true;  # or false if only one node faces the internet
};
```

### Connect the nodes

On any node, connect to each other node:

```bash
garage node connect <NODE_ID>@10.0.0.2:3901
garage node connect <NODE_ID>@10.0.0.3:3901
```

### Assign layout with zones

```bash
garage layout assign -z dc1 -c 50G <NODE_1_ID>
garage layout assign -z dc2 -c 50G <NODE_2_ID>
garage layout assign -z dc3 -c 50G <NODE_3_ID>
garage layout apply --version 1
```

With `replicationMode = "3"`, each object is stored on 3 different nodes
(ideally in 3 different zones), providing full redundancy.

---

## Useful commands

| Command | Description |
|---------|-------------|
| `garage status` | Show cluster node status |
| `garage layout show` | Current storage layout |
| `garage bucket list` | List all buckets |
| `garage bucket create NAME` | Create a bucket |
| `garage bucket info NAME` | Bucket details & aliases |
| `garage bucket website NAME --allow` | Enable static website for bucket |
| `garage key list` | List access keys |
| `garage key create NAME` | Create access key |
| `garage key info NAME` | Show key ID + secret |
| `garage bucket allow BUCKET --read --write --key KEY` | Grant permissions |
| `garage bucket deny BUCKET --read --key KEY` | Revoke permissions |
| `garage repair -a --yes blocks` | Repair block references |
| `garage stats` | Storage statistics |

---

## Troubleshooting

**Garage won't start:** Check `journalctl -u garage -f`. Most common issue is
a malformed `rpcSecretFile` — it must contain `GARAGE_RPC_SECRET=<64-char-hex>`.

**S3 client gets "AuthorizationHeaderMalformed":** Your client is targeting the
wrong region. Set region to `garage` (or whatever you configured in `region`).

**Vhost-style not working:** Ensure you have wildcard DNS (`*.s3.example.com`)
and a wildcard TLS certificate. Path-style always works without wildcard DNS.

**Admin API not responding:** The admin API binds to `127.0.0.1` only by
default. Use `garage` CLI locally, or SSH tunnel for remote access.

**Node not appearing in cluster:** Ensure the RPC port (3901) is open between
all nodes, and that `rpcPublicAddr` is set to a reachable IP:port.
