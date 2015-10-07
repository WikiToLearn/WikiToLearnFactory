#!/bin/bash
cd "$(dirname "$(readlink "$0" || printf %s "$0")")"
curdir=$(pwd)

if [ ! -f ../factory.config ] ; then
 echo "Missing ./factory.config. Run ./init-update.sh first"
 exit 1
fi

if [ ! -d ../WikiToLearn ] ; then
 echo "Missing WikiToLearn repo"
 exit 1
fi

. ../factory.config
if [ "$W2L_FACTORY_RELASE" != "0.2" ] ; then
 echo "W2L Factory Relase Error"
 exit
fi


which rsync &> /dev/null
if [[ $? -ne 0 ]] ; then
 echo "Missing rsync command"
 exit 1
fi

[[ -z "$W2L_INSTANCE_NAME" ]] && W2L_INSTANCE_NAME="w2l-dev"

if [ ! -d "${W2L_RUNNING_DIR}" ] ; then
 echo "Missing ${W2L_RUNNING_DIR}"
 exit 1
fi

if [ -d "${W2L_RUNNING_DIR}/${W2L_INSTANCE_NAME}" ] ; then
 echo "Instance ${W2L_INSTANCE_NAME} exist"
 exit 1
fi

echo "Create repository copy"

rsync -a --stats ../WikiToLearn/ "${W2L_RUNNING_DIR}/${W2L_INSTANCE_NAME}/"
chown 1000:1000 "${W2L_RUNNING_DIR}/${W2L_INSTANCE_NAME}/" -R
cd "${W2L_RUNNING_DIR}/${W2L_INSTANCE_NAME}/"
if [[ ! -z "$W2L_COMMIT" ]] ; then
 git checkout "$W2L_COMMIT"
 git pull --recurse-submodules
 git submodule update --recursive
fi
cd "Dockers/"
export W2L_BACKUP_ENABLED=1
./run.sh
./fix-hosts.sh
if [[ "$W2L_BACKUP_TO_RESTORE" == "" ]] ; then
 export W2L_INIT_DB=1
 ./init-docker.sh
else
 export W2L_INIT_DB=0
 ./restore.sh "$W2L_BACKUP_TO_RESTORE"
 ./init-docker.sh
fi
./use-instance.sh

cd "$curdir"
echo ${W2L_INSTANCE_NAME} >> ../instances.log
