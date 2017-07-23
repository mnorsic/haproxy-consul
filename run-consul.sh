sudo docker run --net=host -d -e 'CONSUL_ALLOW_PRIVILEGED_PORTS=' --name=consul consul:0.9.0 agent -dev -dns-port=53 -recursor=8.8.8.8
