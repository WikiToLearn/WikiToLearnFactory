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
if [ "$WTL_FACTORY_RELASE" != "0.2" ] ; then
 echo "WTL Factory Relase Error"
 exit
fi


which rsync &> /dev/null
if [[ $? -ne 0 ]] ; then
 echo "Missing rsync command"
 exit 1
fi

[[ -z "$WTL_INSTANCE_NAME" ]] && WTL_INSTANCE_NAME="wtl-dev"

if [ ! -d "${WTL_RUNNING_DIR}" ] ; then
 echo "Missing ${WTL_RUNNING_DIR}"
 exit 1
fi

if [ -d "${WTL_RUNNING_DIR}/${WTL_INSTANCE_NAME}" ] ; then
 echo "Instance ${WTL_INSTANCE_NAME} exist"
 exit 1
fi

echo "Create repository copy"

rsync -a --stats ../WikiToLearn/ "${WTL_RUNNING_DIR}/${WTL_INSTANCE_NAME}/"
chown 1000:1000 "${WTL_RUNNING_DIR}/${WTL_INSTANCE_NAME}/" -R
cd "${WTL_RUNNING_DIR}/${WTL_INSTANCE_NAME}/"
if [[ ! -z "$WTL_COMMIT" ]] ; then
 git checkout "$WTL_COMMIT"
 git submodule sync
 git submodule update --init --recursive --checkout
fi
cd "Dockers/"
export WTL_BACKUP_ENABLED=1
./run.sh
./fix-hosts.sh
if [[ "$WTL_BACKUP_TO_RESTORE" == "" ]] ; then
 export WTL_INIT_DB=1
 ./init-docker.sh
else
 export WTL_INIT_DB=0
 ./restore.sh "$WTL_BACKUP_TO_RESTORE"
 ./init-docker.sh
fi
./use-instance.sh

cd "$curdir"
echo ${WTL_INSTANCE_NAME} >> ../instances.log
