# Oracle Cloud Infrastructure VPS

This system is host using the Free Plan from Oracle Cloud Infractruture (OCI). 

Capabilities:
- ARM (Ampere)
- 4 OCPUS (Virtual Core)
- 24 GB of RAM
- 200 GB disk

>! This systems should be relliied on since Oracle could stop the Free Plan and remove access to this VM. 

Thus this system is only used as a bridge and an easly accessible server. Where no critical data is store for more than a days on it. An other server should be used if this one goes down.

# Lore

Represent the lore of the Titan that live in Mount Othrys. 
The only Titan living on this host is gaia.

https://en.wikipedia.org/wiki/Titans

> TODO This host should also be used as a builder for Olympus system


# Deployments 


## Installation / Instance creation

```sh
# TODO use terraform
```

## Update

```sh 
colmena apply --on othrys --impure --verbose
```
