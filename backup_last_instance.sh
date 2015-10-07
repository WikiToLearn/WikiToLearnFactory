#!/bin/bash
cd "$(dirname "$(readlink "$0" || printf %s "$0")")"

if [ ! -f ./factory.config ] ; then
 echo "Missing ./factory.config. Run ./init-update.sh first"
 exit 1
fi

. ./factory.config
if [ "$W2L_FACTORY_RELASE" != "0.2" ] ; then
 echo "W2L Factory Relase Error"
 exit
fi

if [[ -f ./instances.log ]] ; then
 W2L_INSTANCE_NAME=$(cat ./instances.log | tail -1)
fi

[[ -z "$W2L_INSTANCE_NAME" ]] && W2L_INSTANCE_NAME="w2l-dev"

if [ ! -d "${W2L_RUNNING_DIR}" ] ; then
 echo "Missing ${W2L_RUNNING_DIR}"
 exit 1
fi

if [ ! -d "${W2L_RUNNING_DIR}/${W2L_INSTANCE_NAME}" ] ; then
 echo "Instance ${W2L_INSTANCE_NAME} not exist"
 exit 1
fi

cd "${W2L_RUNNING_DIR}/${W2L_INSTANCE_NAME}/Dockers"
./backup.sh
