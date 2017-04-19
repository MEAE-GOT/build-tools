#!/bin/sh

server=$1
no_clients=$2
test_case=$3
build_number=$4
repo_revision=$5
build_timestamp=$6

echo "Test client parameters:"
echo "      server host: $server"
echo "number of clients: $no_clients"
echo "        test case: $test_case"
echo "     build number: $build_number"
echo "    repo revision: $repo_revision"
echo "  build timestamp: $build_timestamp"

ssh_key="/media/pfpro/SpareDisc/bamboo/ssh/id_rsa"
test_client="../LP-W3CSER-COM/w3c-server/W3CQtTestClient/src/W3CQtTestClient"

echo "Kill W3CServer if any running..."
ssh -i $ssh_key root@$server 'killall -9 W3CServer'

# remove old test reports
rm -f w3c-tests.*

set -e

echo "Start W3CServer and whait a while..."
(ssh -i $ssh_key root@$server 'nohup /usr/bin/W3CServer -secure')&

pid=$!
echo "pid: $pid"

sleep 10

echo "Server started"

software="${build_number}_${repo_revision}"
args="--url wss://$server:8080 -c $no_clients --timestamp $build_timestamp --software $software $test_case"

echo "Starting test client with arguments: $args"

$test_client $args

echo "Closing ssh connection."
kill $pid
