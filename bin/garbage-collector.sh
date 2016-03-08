#!/bin/bash
cd "$(dirname "$(readlink "$0" || printf %s "$0")")"

if [ ! -f ../factory.config ] ; then
 echo "Missing ./factory.config. Run ./init-update.sh first"
 exit 1
fi

. ../factory.config
if [ "$WTL_FACTORY_RELASE" != "0.2" ] ; then
 echo "WTL Factory Relase Error"
 exit
fi


CURRENT=$(cat ../instances.log | tail -1)

ls $WTL_RUNNING_DIR | grep -v $CURRENT | while read TO_DELETE_WTL_INSTANCE_NAME ; do
 export WTL_INSTANCE_NAME=$TO_DELETE_WTL_INSTANCE_NAME
 ./destroy-instance.sh
 sed -i '/'$WTL_INSTANCE_NAME'/d' ../instances.log
done
