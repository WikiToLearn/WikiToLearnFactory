#!/bin/bash
cd "$(dirname "$(readlink "$0" || printf %s "$0")")"

if [ ! -f ./factory.config ] ; then
 if [ -z "$W2L_BACKUP_PATH" ] ; then
  echo "Missing \$W2L_BACKUP_PATH variabile"
  exit 1
 fi
 if [ -z "$W2L_RUNNING_DIR" ] ; then
  echo "Missing \$W2L_RUNNING_DIR variabile"
  echo "Using default running/"
  export W2L_RUNNING_DIR=running/
 fi
 {
  echo "export W2L_PRODUCTION=1"
  echo "export W2L_STAGING=1"
  echo "export W2L_BACKUP_PATH=$W2L_BACKUP_PATH"
  echo "export W2L_RUNNING_DIR=$W2L_RUNNING_DIR"
 } > ./factory.config
 chmod +x ./factory.config
fi

if [ ! -d WikiToLearn ] ; then
 git clone --recursive https://github.com/WikiToLearn/WikiToLearn.git WikiToLearn
fi

cd WikiToLearn
git pull --recurse-submodules
git submodule update --recursive
cd ..
