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
if [ "$WTL_FACTORY_RELASE" != "0.2" ] ; then
 echo "WTL Factory Relase Error"
 exit
fi

cd WikiToLearn
export WTL_COMMIT="$WTL_COMMIT"
if [[ "$WTL_COMMIT" == "" ]] ; then
 if [[ "$WTL_USE_LAST" == "tag" ]] ; then
  export WTL_COMMIT=$(git show $(git tag | sort -Vr | head -1) | head -1 | grep commit | awk '{ print $2 }')
 elif [[ "$WTL_USE_LAST" == "commit" ]] ; then
  export WTL_COMMIT=$(git log -n1 | grep commit | awk '{ print $2 }')
 fi
fi
cd ..
echo "New version hash: "$WTL_COMMIT

export WTL_NEW_INSTANCE_NAME="wtl-"${WTL_COMMIT:0:8}

grep $WTL_NEW_INSTANCE_NAME instances.log &> /dev/null
if [[ $? -eq 0 ]] ; then
 echo "WTL Is already at last version"
 exit 1
fi

if [ -f instances.log ] ; then
 OLD_WTL_INSTANCE_NAME=$(cat instances.log | tail -1)

 echo "Old version name: "$OLD_WTL_INSTANCE_NAME
 WTL_INSTANCE_NAME=$OLD_WTL_INSTANCE_NAME
 cd "${WTL_RUNNING_DIR}/${WTL_INSTANCE_NAME}/"
 echo "\$wgReadOnly = 'This wiki is currently being upgraded to a newer software version.';" >> LocalSettings.php
 cd "${WTL_RUNNING_DIR}/${WTL_INSTANCE_NAME}/Dockers"
 ./backup.sh

 cd "$FACTORY_PWD"

 BACKUP_DIR=$(ls $WTL_BACKUP_PATH | sort -Vr | head -1)
 echo "Backup dir: "$BACKUP_DIR

 export WTL_BACKUP_TO_RESTORE=$WTL_BACKUP_PATH"/"$BACKUP_DIR
else
 if [[ "$1" != "" ]] ; then
  echo "Restoring $1 backup..."
  export WTL_BACKUP_TO_RESTORE="$1"
 fi
fi

export WTL_INSTANCE_NAME=$WTL_NEW_INSTANCE_NAME

./bin/make-instance.sh

cd "$FACTORY_PWD"
if [ -f secrets.php ] ; then
 echo "Copy secrets.php to ${WTL_RUNNING_DIR}/${WTL_INSTANCE_NAME}/Dockers/configs/secrets/secrets.php"
 cp secrets.php "${WTL_RUNNING_DIR}/${WTL_INSTANCE_NAME}/Dockers/configs/secrets/secrets.php"
 echo "Copy secrets.php to ${WTL_RUNNING_DIR}/${WTL_INSTANCE_NAME}/secrets/secrets.php"
 cp secrets.php "${WTL_RUNNING_DIR}/${WTL_INSTANCE_NAME}/secrets/secrets.php"
fi
