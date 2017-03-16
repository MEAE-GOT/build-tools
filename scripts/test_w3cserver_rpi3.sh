#!/bin/sh

set -e

server=$1
test_case=$2
build_number=$3
repo_revision=$4

echo "Test client parameters:"
echo "  server host: $server"
echo "    test case: $test_case"
echo " build number: $build_number"
echo "repo revision: $repo_revision"

ssh_key="/media/pfpro/SpareDisc/bamboo/ssh/id_rsa"
w3cserver_build_path="../LP-W3CSER-JOB1/gdp/gdp-src-build/tmp/work/cortexa7hf-neon-vfpv4-poky-linux-gnueabi/w3c-server/1.0-r0/build/src"
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

echo "Start test clients..."
$test_client wss://$server:8080 $test_case

kill $pid
