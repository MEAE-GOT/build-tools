#!/bin/sh

set -e

server=$1
no_clients=$2
test_case=$3
build_number=$4
repo_revision=$5

echo "Test client parameters:"
echo "      server host: $server"
echo "number of clients: $no_clients"
echo "        test case: $test_case"
echo "     build number: $build_number"
echo "    repo revision: $repo_revision"

ssh_key="/media/pfpro/SpareDisc/bamboo/ssh/id_rsa"
w3cserver_build_path="gdp/gdp-src-build/tmp/work/cortexa7hf-neon-vfpv4-poky-linux-gnueabi/w3c-server/1.0-r0/build/src"
test_client="../LP-W3CSER-COM/w3c-server/W3CQtTestClient/src/W3CQtTestClient"

echo "Stopping and removing old w3cserver from client..."
ssh -i $ssh_key root@$server 'killall -9 W3CServer'

echo "Copying new w3cserver..."
scp -i $ssh_key "${w3cserver_build_path}/W3CServer" root@$server:/usr/bin

echo "Start new server and whait a while..."
(ssh -i $ssh_key root@$server 'nohup /usr/bin/W3CServer -secure')&

pid=$!
echo "pid: $pid"

sleep 10

echo "Server started"

software=$build_number_$repo_revision
args="-u wss://$server:8080 -c $no_clients --software $software $test_case"

echo "Starting test client with arguments: $args"

$test_client $args

echo "Closing ssh connection."
kill $pid
