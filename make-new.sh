#!/bin/bash
cd "$(dirname "$(readlink "$0" || printf %s "$0")")"

if [ ! -d running ] ; then
 mkdir running
fi

which rsync &> /dev/null
if [[ $? -ne 0 ]] ; then
 echo "Missing rsync command"
 exit 1
fi

rsync -a WikiToLearn/ running/newinstance/
cd running/newinstance/Dockers
pwd
./run.sh
./fix-hosts.sh
./init-docker.sh
./use-instance.sh
