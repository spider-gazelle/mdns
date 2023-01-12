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

## Docker and networking

When running docker desktop on Mac or Windows, docker containers are isolated from multicast traffic as the containers run in a Virtual Machine.
This means `--net=host` does not work as expected.

### Windows

References

* [Reroute mDNS query from WSL subnet to windows host subnet](https://stackoverflow.com/questions/62108116/reroute-mdns-query-from-wsl-subnet-to-windows-host-subnet/62246694#62246694)
* [Hyper-V Network Adapters](https://www.nakivo.com/blog/hyper-v-network-adapters-what-why-and-how/)

1. `wsl --shutdown` before launching Hyper-V Manager
1. Ensure the hyper-v management tools have been added to windows (add/remove windows components)
1. Hit your Windows key and type "Hyper-V Manager"
1. Right-click on the app and choose "Run as administrator"
1. In the manager, find your machine under "Hyper-V Manager" and click on it
1. In the Actions area, click on "Virtual Switch Manager..."
1. Find the WSL switch and click on it
1. Change the connection type to "External network"
1. Click OK

If you run into issues such as internet dropping you can remove the network bridges on the adaptors page after reverting configuration and rebooting.

### MacOS

The only workaround I've found is running containers in VirtualBox which isn't ideal.
