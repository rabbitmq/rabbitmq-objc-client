FROM rabbitmq:3.12-management

COPY docker-entrypoint.sh /
COPY certificates/*.pem /etc/rabbitmq/
COPY rabbitmq.conf      /etc/rabbitmq/rabbitmq.conf

ENTRYPOINT /docker-entrypoint.sh

EXPOSE 5671 5672 15672
