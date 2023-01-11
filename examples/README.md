# mDNS Examples

## query responder

This will respond to mDNS queries for a domain specified via environment variables.

```shell

export DOMAIN_NAMES=myservice.local,altname.local
export IP_ADDRESS=127.0.0.1

crystal ./examples/query_responder.cr

```

then you can resolve those domain names over mDNS, this could be for ssh or browsing etc

```shell

ping myservice.local

```

The dockerfile helps package this so you can run services on your local network, such as a docker-compose to use nice domain names.
