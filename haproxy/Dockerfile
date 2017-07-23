FROM alpine
MAINTAINER Miljenko Norsic version: 0.1

ENV CONSUL_TEMPLATE_VERSION=0.19.0

# Update wget to get support for SSL
RUN apk --update add haproxy wget

# Download consul-template
RUN ( wget --no-check-certificate https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip -O /tmp/consul_template.zip && unzip /tmp/consul_template.zip -d /tmp && mv /tmp/consul-template /usr/bin && rm -rf /tmp/* )

COPY haproxy.json /tmp/haproxy.json
COPY haproxy.ctmpl /tmp/haproxy.ctmpl

CMD ["consul-template", "-config=/tmp/haproxy.json", "-log-level=debug"]
