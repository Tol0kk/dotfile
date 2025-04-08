# Kanidm Documentation


## Generate Admin Password
```sh
kanidmd recover-account idm_admin
kanidmd recover-account admin
```

## Users
```sh
kanidm person create NAME DISPLAY_NAME
```

## Groups

### Create Groups
```sh
kanidm group create guests
kanidm group create users
kanidm group create moderators
```
### Populate Groups
```sh
kanidm group add-members users NAME
kanidm group add-members moderators NAME
```

## Oauth 2 Services

### Create Oauth 2Services
```sh
kanidm system oauth2 create traefik-auth "Traefik Auth Middleware" https://tolok.org
kanidm system oauth2 update-scope-map traefik-auth users opened
```