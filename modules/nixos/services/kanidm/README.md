# Kanidm — NixOS Module Setup & Usage Guide

## What is Kanidm?

Kanidm is a modern, Rust-based identity management server. It provides
OIDC/OAuth2 for SSO across your services, optional read-only LDAPS, WebAuthn
support, and a CLI-first approach that makes it perfect for declarative NixOS
management.

---

## Architecture

```
                       Internet
                          │
                     ┌────┴─────┐
                     │ Traefik  │  :443 TLS
                     └────┬─────┘
                          │
                 auth.example.com
                          │
              ┌───────────┴────────────┐
              │     Kanidm daemon      │
              │                        │
              │  Web UI + API  :8443   │  ← HTTPS (self-signed OK behind proxy)
              │  LDAPS         :636    │  ← optional, direct (no proxy)
              │                        │
              │  ┌─ OIDC / OAuth2 ──┐  │
              │  │ /oauth2/openid/* │  │  ← SSO for your apps
              │  └──────────────────┘  │
              └────────────────────────┘
                          │
                  /var/lib/kanidm/
                   kanidm.db (SQLite)
```

---

## Prerequisites

1. **A server** with a domain pointing to it (e.g. `auth.example.com`)
2. **TLS certificates** — Kanidm requires TLS natively, even behind a proxy. Options:
   - ACME (Let's Encrypt) via `security.acme`
   - Self-signed (for internal/dev use)
   - Provided by your secret manager (agenix/sops-nix)
3. **Secret files** for admin passwords (never in the Nix store)

---

## Step 1 — Generate secrets

```bash
mkdir -p /run/secrets

# Admin password (system-level admin)
openssl rand -base64 32 > /run/secrets/kanidm-admin-password
chmod 600 /run/secrets/kanidm-admin-password

# IDM admin password (manages users/groups)
openssl rand -base64 32 > /run/secrets/kanidm-idm-admin-password
chmod 600 /run/secrets/kanidm-idm-admin-password

# Per-app OAuth2 secrets (one per app)
openssl rand -base64 32 > /run/secrets/kanidm-oauth2-myapp
chmod 600 /run/secrets/kanidm-oauth2-myapp
```

> **Production:** use `agenix` or `sops-nix` so these are encrypted in your repo.

---

## Step 2 — TLS certificates

### Option A: ACME (recommended for public servers)

```nix
security.acme = {
  acceptTerms = true;
  defaults.email = "you@example.com";
  certs."auth.example.com" = {
    group = "acme";
  };
};
```

Then use:
```nix
tlsCertFile = "/var/lib/acme/auth.example.com/fullchain.pem";
tlsKeyFile  = "/var/lib/acme/auth.example.com/key.pem";
```

### Option B: Self-signed (dev / internal)

```bash
openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 \
  -sha256 -days 3650 -nodes \
  -keyout /run/secrets/kanidm-tls-key.pem \
  -out /run/secrets/kanidm-tls-cert.pem \
  -subj "/CN=auth.example.com"
```

---

## Step 3 — Server configuration (minimal)

```nix
{ config, ... }:
{
  imports = [ ./kanidm.nix ];

  modules.services.kanidm = {
    enable = true;
    domain = "auth.example.com";

    # TLS (required by Kanidm)
    tlsCertFile = "/var/lib/acme/auth.example.com/fullchain.pem";
    tlsKeyFile  = "/var/lib/acme/auth.example.com/key.pem";

    # Traefik reverse proxy
    useTraefik = true;

    # CLI client on this machine
    enableClient = true;
  };
}
```

### Deploy and bootstrap

```bash
sudo nixos-rebuild switch

# Reset the admin passwords (first time only)
sudo kanidmd recover-account admin
sudo kanidmd recover-account idm_admin
```

Save the output passwords — you'll need them for initial setup.

---

## Step 4 — Full configuration with provisioning

This is the power setup: persons, groups, and OAuth2 apps are all declarative.

```nix
{ config, ... }:
{
  imports = [ ./kanidm.nix ];

  modules.services.kanidm = {
    enable = true;
    domain = "auth.example.com";

    tlsCertFile = "/var/lib/acme/auth.example.com/fullchain.pem";
    tlsKeyFile  = "/var/lib/acme/auth.example.com/key.pem";

    useTraefik = true;
    enableClient = true;

    # ── Provisioning (fully declarative) ────────────────
    enableProvisioning = true;
    adminPasswordFile    = "/run/secrets/kanidm-admin-password";
    idmAdminPasswordFile = "/run/secrets/kanidm-idm-admin-password";

    # ── Groups ──────────────────────────────────────────
    groups = {
      "grafana.admins" = {};
      "grafana.users"  = {};
      "gitea.access"   = {};
      "netbird.access" = {};
    };

    # ── Persons (users) ─────────────────────────────────
    persons = {
      alice = {
        displayName = "Alice";
        mailAddresses = ["alice@example.com"];
        groups = ["grafana.admins" "gitea.access" "netbird.access"];
      };
      bob = {
        displayName = "Bob";
        mailAddresses = ["bob@example.com"];
        groups = ["grafana.users" "gitea.access"];
      };
    };

    # ── OAuth2 / OIDC clients ──────────────────────────
    oauth2Clients = {
      grafana = {
        displayName = "Grafana";
        originUrl     = "https://grafana.example.com/login/generic_oauth";
        originLanding = "https://grafana.example.com/";
        basicSecretFile = "/run/secrets/kanidm-oauth2-grafana";
        scopeMaps = {
          "grafana.admins" = ["openid" "profile" "email"];
          "grafana.users"  = ["openid" "profile" "email"];
        };
      };
      gitea = {
        displayName = "Gitea";
        originUrl     = "https://git.example.com/user/oauth2/kanidm/callback";
        originLanding = "https://git.example.com/";
        basicSecretFile = "/run/secrets/kanidm-oauth2-gitea";
        scopeMaps = {
          "gitea.access" = ["openid" "profile" "email"];
        };
      };
      netbird = {
        displayName = "Netbird";
        originUrl     = "https://netbird.example.com/auth";
        originLanding = "https://netbird.example.com/";
        basicSecretFile = "/run/secrets/kanidm-oauth2-netbird";
        scopeMaps = {
          "netbird.access" = ["openid" "profile" "email"];
        };
      };
    };

    # ── Optional: LDAP ──────────────────────────────────
    # enableLdap = true;
    # ldapPort = 636;
  };
}
```

---

## Step 5 — Connect services to Kanidm

Each service needs these values from Kanidm:

| Value | Where to find it |
|-------|------------------|
| OIDC discovery URL | `https://auth.example.com/oauth2/openid/<client-name>/.well-known/openid-configuration` |
| Client ID | The OAuth2 client name (e.g. `grafana`) |
| Client secret | The content of `basicSecretFile` |
| Scopes | Typically `openid profile email` |

### Example: Grafana

```nix
services.grafana.settings.auth."generic_oauth" = {
  enabled = true;
  name = "Kanidm";
  client_id = "grafana";
  client_secret = "$__file{/run/secrets/kanidm-oauth2-grafana}";
  scopes = "openid profile email";
  auth_url = "https://auth.example.com/ui/oauth2";
  token_url = "https://auth.example.com/oauth2/token";
  api_url = "https://auth.example.com/oauth2/openid/grafana/userinfo";
  use_pkce = true;
  allow_sign_up = true;
  login_attribute_path = "preferred_username";
  name_attribute_path = "name";
};
```

### Example: Netbird

Set these in your Netbird module:
```nix
modules.services.netbird.server = {
  oidcConfigEndpoint = "https://auth.example.com/oauth2/openid/netbird/.well-known/openid-configuration";
  clientId = "netbird";
  idpManagerType = "none";  # Kanidm is not natively listed, use "none"
};
```

---

## Step 6 — First login & user onboarding

After deploying with provisioning enabled:

1. Open `https://auth.example.com` in a browser
2. Log in as `idm_admin` with the generated password
3. Navigate to provisioned persons — they'll have temporary passwords
4. Reset a person's password: `kanidm person credential create-reset-token alice`
5. Send the reset link to the user
6. Users set up their own password + optional WebAuthn (FIDO2) key

---

## CLI commands

```bash
# Authenticate as idm_admin
kanidm login -D idm_admin

# List persons
kanidm person list

# Create a person manually
kanidm person create charlie "Charlie"
kanidm person mail set charlie charlie@example.com

# Add person to group
kanidm group add-members grafana.users charlie

# Reset a person's credentials
kanidm person credential create-reset-token charlie

# List OAuth2 clients
kanidm system oauth2 list

# Show OAuth2 client details
kanidm system oauth2 show grafana

# Enable POSIX attributes (for LDAP/SSH)
kanidm person posix set alice --shell /bin/bash

# Create service account + token (for LDAP binds)
kanidm service-account create ldap-search "LDAP Search" idm_admin
kanidm service-account api-token generate ldap-search "LDAP bind token"

# Status
kanidm self whoami
```

---

## Testing the endpoint

```bash
# Check the server is alive
curl -sk https://auth.example.com/status
# Expect: {"state":"Ok"}

# Check OIDC discovery for an OAuth2 client
curl -sk https://auth.example.com/oauth2/openid/grafana/.well-known/openid-configuration | jq .

# Test LDAP (if enabled)
nix-shell -p openldap -c \
  'ldapsearch -H ldaps://auth.example.com -x -D "dn=token" -W'

# Validate TLS cert
openssl s_client -connect auth.example.com:443 -servername auth.example.com </dev/null 2>/dev/null | openssl x509 -noout -dates
```

---

## Troubleshooting

**"tls_chain or tls_key not found":** Kanidm requires TLS certs even behind a
proxy. Ensure the cert files exist and are readable by the `kanidm` user.
Add `users.users.kanidm.extraGroups = ["acme"];` if using ACME.

**Provisioning fails:** Check `journalctl -u kanidm -f`. Ensure
`adminPasswordFile` and `idmAdminPasswordFile` exist and are readable by the
kanidm user (owned by `kanidm:kanidm`, mode `0600`).

**OAuth2 callback error:** Verify that `originUrl` exactly matches the callback
URL your app sends. Kanidm is strict about URL matching.

**"insecure TLS" in Traefik logs:** Expected — Traefik connects to Kanidm's
self-signed HTTPS. The module sets `insecureSkipVerify = true` on the
serversTransport for this reason.

**Database locked:** Only one Kanidm instance can run per database. Ensure no
stale processes: `systemctl stop kanidm && rm -f /var/lib/kanidm/kanidm.db.klock`.

**Backup location:** Automatic backups go to the configured `backupPath`
(`/var/backup/kanidm/` by default) on the schedule you set.
