#!/bin/sh

rpi3_ip=$1
ssh_key="/media/pfpro/SpareDisc/bamboo/ssh/id_rsa"
w3cserver_build_path="../LP-W3CSER-JOB1/gdp/gdp-src-build/tmp/work/cortexa7hf-neon-vfpv4-poky-linux-gnueabi/w3c-server/1.0-r0/build/src"
test_client="../LP-W3CSER-COM/w3c-server/W3CQtTestClient/src/W3CQtTestClient"

echo "Stopping and removing old w3cserver from client..."
ssh -i $ssh_key root@$rpi3_ip 'killall -9 W3CServer'

echo "Copying new w3cserver..."
scp -i $ssh_key "${w3cserver_build_path}/W3CServer" root@$rpi3_ip:/usr/bin

echo "Start new server and whait a while..."
(ssh -i $ssh_key root@$rpi3_ip 'nohup /usr/bin/W3CServer -secure')&

pid=$!
echo "pid: $pid"

sleep 10

echo "Server started"

kill $pid

echo "Start test clients..."
$test_client wss://$rpi3_ip:8080 -getvss
