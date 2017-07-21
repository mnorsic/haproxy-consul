sudo docker run -d -v /var/run/docker.sock:/tmp/docker.sock --net=host --name registrator gliderlabs/registrator:latest consul://localhost:8500
