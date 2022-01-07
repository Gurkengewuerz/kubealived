# Kubealived

## Disclaimer

This repository is highly inspired by [openvnf/kubealived](https://github.com/openvnf/kubealived/) so does this `README.md`. [openvnf](https://github.com/openvnf) described `kuvealived` perfectly. I reworked and updated everything to the newest version. This version is beside of `linux/amd64` now also available for `linux/arm64` and `linux/arm/v7` on [docker.io](https://hub.docker.com/r/gurken2108/kubealived).


## About

A [Docker] image and [Kubernetes] manifests for providing Kubernetes cluster
API high availability with use of [Keepalived]. The solution assigns a
Kubernetes master node a specified IP address, and if the node is down the
address automatically moves to another master node.

## Usage

A Keepalived process should run on all the **master** nodes of a Kubernetes cluster
thefore [DaemonSet] is used. Keepalived assigns a specified IP address to a
specified network interface. You should set a password `AUTH_PASS` for internal usage, however it is not required. 

The default config compiled in the container is using multicast. If you are using i.e. Hetzner Cloud you must set a custom config even if you have a private network attached. This is because Hetzner Cloud is using Layer 3 Switches.  
If you are using for example Linode, Hetzner Dedicated Server with vSwitches or Bare Metal you can leave it at multicast.

To avoid conflicts between several Kubealived installations within the same
network the `VRID` Virtual Router ID should be different for each installation
within a particular network. It should be in the range from 1 to 255.

```
$ IFACE="<Network Interface>"
$ IP="<IP Address>"
$ cat curl -s https://raw.githubusercontent.com/Gurkengewuerz/kubealived/main/manifests/kubealived.yaml | \
       sed -e "s/_IFACE_/${IFACE}/" \
           -e "s/_IP_/${IP}/" \
       kubectl apply -f-
```

After deployment one of the master nodes should get the specified IP address on
the specified network interface. If this master node or a running pod on it
is down, the IP address moves to another master node.

## Try With Docker

1. clone this repository
```
$ git clone git@github.com:Gurkengewuerz/kubealived.git
$ cd kubealived/
```

2. edit `docker-compose.yml` enviroment variables to your needs

3. run container using `docker-compose`:

```
$ docker-compose up
```

Your host now have the `KEEPALIVE_IPADDRESS` IP address assigned to the `KEEPALIVE_INTERFACE`. If you run the same on another host in the same network and
stop this one, the IP address will be moved over.
