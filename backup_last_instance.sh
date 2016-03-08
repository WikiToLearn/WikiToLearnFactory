#!/bin/bash
cd "$(dirname "$(readlink "$0" || printf %s "$0")")"

if [ ! -f ./factory.config ] ; then
 echo "Missing ./factory.config. Run ./init-update.sh first"
 exit 1
fi

. ./factory.config
if [ "$WTL_FACTORY_RELASE" != "0.2" ] ; then
 echo "WTL Factory Relase Error"
 exit
fi

if [[ -f ./instances.log ]] ; then
 WTL_INSTANCE_NAME=$(cat ./instances.log | tail -1)
fi

[[ -z "$WTL_INSTANCE_NAME" ]] && WTL_INSTANCE_NAME="wtl-dev"

if [ ! -d "${WTL_RUNNING_DIR}" ] ; then
 echo "Missing ${WTL_RUNNING_DIR}"
 exit 1
fi

if [ ! -d "${WTL_RUNNING_DIR}/${WTL_INSTANCE_NAME}" ] ; then
 echo "Instance ${WTL_INSTANCE_NAME} not exist"
 exit 1
fi

cd "${WTL_RUNNING_DIR}/${WTL_INSTANCE_NAME}/Dockers"
./backup.sh
