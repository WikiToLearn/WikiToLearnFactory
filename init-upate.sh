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
 } > ./factory.config
 chmod +x ./factory.config
fi

. ./factory.config

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
git pull --recurse-submodules
git submodule update --recursive
cd ..
