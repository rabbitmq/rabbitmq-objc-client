#!/bin/sh
server=rabbitmq-server
ctl=rabbitmqctl
plugins=rabbitmq-plugins
delay=5

$server -detached

echo "Waiting $delay seconds for RabbitMQ to start."

sleep $delay

$ctl add_vhost "vhost/with/a/few/slashes"
$ctl add_user "O=client,CN=guest" bunnies
$ctl set_permissions "O=client,CN=guest" ".*" ".*" ".*"

$plugins enable rabbitmq_auth_mechanism_ssl
$plugins enable rabbitmq_management
$ctl eval 'supervisor2:terminate_child(rabbit_mgmt_sup_sup, rabbit_mgmt_sup), application:set_env(rabbitmq_management,       sample_retention_policies, [{global, [{605, 1}]}, {basic, [{605, 1}]}, {detailed, [{10, 1}]}]), rabbit_mgmt_sup_sup:start_child().'
$ctl eval 'supervisor2:terminate_child(rabbit_mgmt_agent_sup_sup, rabbit_mgmt_agent_sup), application:set_env(rabbitmq_management_agent, sample_retention_policies, [{global, [{605, 1}]}, {basic, [{605, 1}]}, {detailed, [{10, 1}]}]), rabbit_mgmt_agent_sup_sup:start_child().'

$ctl shutdown --timeout $delay

echo 'Starting RabbitMQ in the foreground (Ctrl-C to stop)'

exec $server
