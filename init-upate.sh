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
 if [ -z "$WTL_BACKUP_PATH" ] ; then
  echo "Missing \$WTL_BACKUP_PATH variabile"
  echo "Using default: backups/"
  export WTL_BACKUP_PATH=$(pwd)"/backups/"
 fi
 if [ -z "$WTL_RUNNING_DIR" ] ; then
  echo "Missing \$WTL_RUNNING_DIR variabile"
  echo "Using default: running/"
  export WTL_RUNNING_DIR=$(pwd)"/running/"
 fi
 {
  echo "export WTL_PRODUCTION=1"
  echo "export WTL_USE_LAST='commit' # set 'tag' for use only last WikiToLearn git tag"
  echo "export WTL_BACKUP_PATH=$WTL_BACKUP_PATH"
  echo "export WTL_RUNNING_DIR=$WTL_RUNNING_DIR"
  echo "export WTL_FACTORY_RELASE=0.2"
  echo "# export WTL_RELAY_HOST=relayhost.not.used"
  echo "# export WTL_DOCKER_MOUNT_DIRS=0"
  echo "# export WTL_BRANCH=master"
 } > ./factory.config
 chmod +x ./factory.config
fi

. ./factory.config
if [ "$WTL_FACTORY_RELASE" != "0.2" ] ; then
 echo "WTL Factory Relase Error"
 exit
fi

if [ ! -d "$WTL_BACKUP_PATH" ] ; then
 echo "Missing backup PATH"
 exit 1
fi

if [ ! -d "$WTL_RUNNING_DIR" ] ; then
 echo "Missing running PATH"
 exit 1
fi

if [ ! -d WikiToLearn ] ; then
 git clone --recursive https://github.com/WikiToLearn/WikiToLearn.git WikiToLearn
fi

cd WikiToLearn
if [[ "$WTL_BRANCH" != "" ]] ; then
 git checkout "$WTL_BRANCH"
else
 git checkout master
fi
git pull
git submodule sync
git submodule update --init --recursive --checkout
cd ..
