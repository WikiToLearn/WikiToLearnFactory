#!/bin/bash
cd "$(dirname "$(readlink "$0" || printf %s "$0")")"
FACTORY_PWD=$(pwd)

if [ ! -f ./factory.config ] ; then
 echo "Missing ./factory.config. Run ./init-update.sh first"
 exit 1
fi

if [ ! -d WikiToLearn ] ; then
 echo "Missing WikiToLearn repo"
 exit 1
fi

. ./factory.config
if [ "$W2L_FACTORY_RELASE" != "0.2" ] ; then
 echo "W2L Factory Relase Error"
 exit
fi

cd WikiToLearn
export W2L_COMMIT="$W2L_COMMIT"
if [[ "$W2L_COMMIT" == "" ]] ; then
 if [[ "$W2L_USE_LAST" == "tag" ]] ; then
  export W2L_COMMIT=$(git show $(git tag | sort -Vr | head -1) | head -1 | grep commit | awk '{ print $2 }')
 elif [[ "$W2L_USE_LAST" == "commit" ]] ; then
  export W2L_COMMIT=$(git log -n1 | grep commit | awk '{ print $2 }')
 fi
fi
cd ..
echo "New version hash: "$W2L_COMMIT

export W2L_NEW_INSTANCE_NAME="w2l-"${W2L_COMMIT:0:8}

grep $W2L_NEW_INSTANCE_NAME instances.log &> /dev/null
if [[ $? -eq 0 ]] ; then
 echo "W2L Is already at last version"
 exit 1
fi

if [ -f instances.log ] ; then
 OLD_W2L_INSTANCE_NAME=$(cat instances.log | tail -1)

 echo "Old version name: "$OLD_W2L_INSTANCE_NAME
 W2L_INSTANCE_NAME=$OLD_W2L_INSTANCE_NAME
 cd "${W2L_RUNNING_DIR}/${W2L_INSTANCE_NAME}/"
 echo "\$wgReadOnly = 'This wiki is currently being upgraded to a newer software version.';" >> LocalSettings.php
 cd "${W2L_RUNNING_DIR}/${W2L_INSTANCE_NAME}/Dockers"
 ./backup.sh

 cd "$FACTORY_PWD"

 BACKUP_DIR=$(ls $W2L_BACKUP_PATH | sort -Vr | head -1)
 echo "Backup dir: "$BACKUP_DIR

 export W2L_BACKUP_TO_RESTORE=$W2L_BACKUP_PATH"/"$BACKUP_DIR
else
 if [[ "$1" != "" ]] ; then
  echo "Restoring $1 backup..."
  export W2L_BACKUP_TO_RESTORE="$1"
 fi
fi

export W2L_INSTANCE_NAME=$W2L_NEW_INSTANCE_NAME

./bin/make-instance.sh

cd "$FACTORY_PWD"
if [ -f secrets.php ] ; then
 echo "Copy secrets.php to ${W2L_RUNNING_DIR}/${W2L_INSTANCE_NAME}/Dockers/configs/secrets/secrets.php"
 cp secrets.php "${W2L_RUNNING_DIR}/${W2L_INSTANCE_NAME}/Dockers/configs/secrets/secrets.php"
 echo "Copy secrets.php to ${W2L_RUNNING_DIR}/${W2L_INSTANCE_NAME}/secrets/secrets.php"
 cp secrets.php "${W2L_RUNNING_DIR}/${W2L_INSTANCE_NAME}/secrets/secrets.php"
fi
