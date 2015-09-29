#!/bin/bash
cd "$(dirname "$(readlink "$0" || printf %s "$0")")"

if [ ! -f ./factory.config ] ; then
 echo "Missing ./factory.config. Run ./init-update.sh first"
 exit 1
fi

if [ ! -d WikiToLearn ] ; then
 echo "Missing WikiToLearn repo"
 exit 1
fi

. ./factory.config

CURRENT=$(cat instances.log | tail -1)

ls $W2L_RUNNING_DIR | grep -v $CURRENT | while read TO_DELETE_W2L_INSTANCE_NAME ; do
 export W2L_INSTANCE_NAME=$TO_DELETE_W2L_INSTANCE_NAME
 ./destroy-instance.sh
done
