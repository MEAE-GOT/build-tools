#!/bin/sh

host=$1
process_name=$2
package_file=$3

#process_to_stop="W3CServer"
ssh_key="/media/pfpro/SpareDisc/bamboo/ssh/id_rsa"
package_name=$(basename $package_file)

echo "Stopping $process_name ..."
ssh -i $ssh_key root@$host "killall -9 $process_name"

set -e

echo "Copy $package_file to target ..."
scp -i $ssh_key "$package_file" root@$host:/home/root

echo "Install $package_name ..."
(ssh -i $ssh_key root@$host "nohup rpm -i --replacepkgs /home/root/$package_name")&

pid=$!
echo "pid: $pid"

sleep 10

echo "killing ssh connection..."
kill $pid

echo "done!"
