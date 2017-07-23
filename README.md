# HAProxy with Consul and Registrator
This image is inspired by the following [blog post](http://sirile.github.io/2015/05/18/using-haproxy-and-consul-for-dynamic-service-discovery-on-docker.html), but with additional changes to fit newer versions of Consul, Consul Template, Registrator and HAProxy.
The main idea is to create a Docker-based service registry and automatic service registration based on [Consul](https://www.consul.io/) and [HAProxy](http://www.haproxy.org/), thereby using as a base for microservice development and deployment that allows horizontal microservice scaling.

The differences between the original post are:
* docker native client is used instead of docker-machine
* updated versions of Docker containers are used
* in a newer version of Consul-Template there is a bug with pidof command that does not work correctly, and this command is required to safely restart HAProxy service to reload a configuration
* HAProxy configuration file generation is fixed to work with latest version of Consul Template
* Consul was complaining about service name that contains forward slashes ('/'), therefore example service name was adjusted

The following components are used:
* Consul 0.9.0
* GliderLabs Registrator latest version
* Consul Template 0.19.0
* HAProxy latest version (currently 1.7.5, in Alpine Linux distro)
* Scala-based test service from the original post

## How it works
The system works as follows:
* Registrator service is registering service with Consul, so any microservice with valid SERVICE_NAME is registered on container startup
* HAProxy container uses Consul Template, which is responsible to connect to Consul and fetch configuration parameters from its key-value store.
* When a new service is started, or a configuration change is performed in Consul, Consul Template generates a new HAProxy configuration file and performs HAProxy reload. Consul Template runs as a daemon process and stays active after HAProxy restart
* Each microservice registered by Registrator is added into a Consul as a DNS entry

## Running

### Consul
Consul can be run with the following command:

```
sudo docker run --net=host -d -e 'CONSUL_ALLOW_PRIVILEGED_PORTS=' --name=consul consul:0.9.0 agent -dev -dns-port=53 -recursor=8.8.8.8
```

Consul agent is run in a development mode, and its DNS service is started on a default port 53 (the original Consul image runs DNS on port 8600).
Also, Consul is run with host networking, as according to documentation its gossip and consensus protocols are sensitive to packet loss and delays, so by eliminating an extra networking layer such issues are minimized.

### Registrator
Registrator is started with the following command:
```
sudo docker run -d -v /var/run/docker.sock:/tmp/docker.sock --net=host --name registrator gliderlabs/registrator:latest consul://localhost:8500
```

Registrator responsible to register a newely started service into a Consul. It does it by actively listening to a Docker socket and receiving events emitted by Docker runtime. Each service that needs to be registered with Consul should have SERVICE_NAME environment variable set.

### Example microservice
Example microservice is run with the following command:
```
sudo docker run -d -e SERVICE_NAME=hello1 -e SERVICE_TAGS=rest -h hello1 --name hello1 -p :80 sirile/scala-boot-test
```

### HAProxy
HAProxy image is based on Alpine image, with very small footprint.

Before running. HAProxy Docker image should be build by running
```
sudo docker build -t mnorsic/haproxy haproxy/.
```

After building, HAProxy service is run with the following command:
```
sudo docker run -d -e SERVICE_NAME=rest --net=host --name=rest --dns=127.0.0.1 --dns-search="service.consul" -p 80:80 -p 1936:1936 mnorsic/haproxy
```

## TODO
* create a Docker Compose image that would run all services at once
* use port 8600 for DNS lookup (currently, Docker does not support addition of DNS servers with ports, so this should be done on /etc/resolv.conf configuration file directly)
* limit network sharing (--net=host) for some images
