sudo docker run -d -e SERVICE_NAME=rest --net=host --name=rest --dns=127.0.0.1 --dns-search="service.consul" -p 80:80 -p 1936:1936 mnorsic/haproxy
