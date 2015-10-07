#!/bin/bash
cd "$(dirname "$(readlink "$0" || printf %s "$0")")"

if [ ! -f ../factory.config ] ; then
 echo "Missing ./factory.config. Run ./init-update.sh first"
 exit 1
fi

. ../factory.config
if [ "$W2L_FACTORY_RELASE" != "0.2" ] ; then
 echo "W2L Factory Relase Error"
 exit
fi


CURRENT=$(cat ../instances.log | tail -1)

ls $W2L_RUNNING_DIR | grep -v $CURRENT | while read TO_DELETE_W2L_INSTANCE_NAME ; do
 export W2L_INSTANCE_NAME=$TO_DELETE_W2L_INSTANCE_NAME
 ./destroy-instance.sh
 sed -i '/'$W2L_INSTANCE_NAME'/d' ../instances.log
done
