# myhome-dns

A simple DNS server, based on [CoreDNS](https://coredns.io/), configured with:
* Caching
* Forwarding
* Filtering (blocking)

# How to

## Block a site

Edit the `/etc/coredns/filterschedule/filterschedule.yaml` (more details [here](https://github.com/touchardv/filterschedule)).

## Reload the configuration files

Run `docker exec -it myhome-dns kill -USR1 1`.
