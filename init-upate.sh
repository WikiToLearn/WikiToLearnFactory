#!/bin/bash
cd "$(dirname "$(readlink "$0" || printf %s "$0")")"

which mysql &> /dev/null
if [[ $? -ne 0 ]] ; then
 echo "'mysql' command not found"
 exit 1
fi

which rsync &> /dev/null
if [[ $? -ne 0 ]] ; then
 echo "Missing rsync command"
 exit 1
fi

if [ ! -f ./factory.config ] ; then
 if [ -z "$W2L_BACKUP_PATH" ] ; then
  echo "Missing \$W2L_BACKUP_PATH variabile"
  echo "Using default: backups/"
  export W2L_BACKUP_PATH=$(pwd)"/backups/"
 fi
 if [ -z "$W2L_RUNNING_DIR" ] ; then
  echo "Missing \$W2L_RUNNING_DIR variabile"
  echo "Using default: running/"
  export W2L_RUNNING_DIR=$(pwd)"/running/"
 fi
 {
  echo "export W2L_PRODUCTION=1"
  echo "export W2L_USE_LAST='commit' # set 'tag' for use only last WikiToLearn git tag"
  echo "export W2L_BACKUP_PATH=$W2L_BACKUP_PATH"
  echo "export W2L_RUNNING_DIR=$W2L_RUNNING_DIR"
  echo "export W2L_FACTORY_RELASE=0.2"
  echo "# export W2L_RELAY_HOST=relayhost.not.used"
  echo "# export W2L_DOCKER_MOUNT_DIRS=0"
  echo "# export W2L_BRANCH=master"
 } > ./factory.config
 chmod +x ./factory.config
fi

. ./factory.config
if [ "$W2L_FACTORY_RELASE" != "0.2" ] ; then
 echo "W2L Factory Relase Error"
 exit
fi

if [ ! -d "$W2L_BACKUP_PATH" ] ; then
 echo "Missing backup PATH"
 exit 1
fi

if [ ! -d "$W2L_RUNNING_DIR" ] ; then
 echo "Missing running PATH"
 exit 1
fi

if [ ! -d WikiToLearn ] ; then
 git clone --recursive https://github.com/WikiToLearn/WikiToLearn.git WikiToLearn
fi

cd WikiToLearn
if [[ "$W2L_BRANCH" != "" ]] ; then
 git checkout "$W2L_BRANCH"
else
 git checkout master
fi
git pull
git submodule sync
git submodule init
git submodule update --recursive
cd ..
