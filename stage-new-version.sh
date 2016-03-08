#!/bin/bash
cd "$(dirname "$(readlink "$0" || printf %s "$0")")"
FACTORY_PWD=$(pwd)

export WTL_BACKUP_TO_RESTORE="$1"

if [[ ! -d "$WTL_BACKUP_TO_RESTORE" ]] ; then
 echo "Missing $WTL_BACKUP_TO_RESTORE directory"
 exit 1
fi

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

export WTL_INSTANCE_NAME=$WTL_NEW_INSTANCE_NAME

./bin/make-instance.sh

if [[ "$WTL_STAGE_URL" != "" ]] ; then
 curl --data "commit=$WTL_COMMIT&host=$(hostname -f)&baseurl=$WTL_STAGE_PUBLIC_NAME" "$WTL_STAGE_URL"
fi

cd "$FACTORY_PWD"
if [ -f secrets.php ] ; then
 echo "Copy secrets.php to ${WTL_RUNNING_DIR}/${WTL_INSTANCE_NAME}/Dockers/configs/secrets/secrets.php"
 cp secrets.php "${WTL_RUNNING_DIR}/${WTL_INSTANCE_NAME}/Dockers/configs/secrets/secrets.php"
 echo "Copy secrets.php to ${WTL_RUNNING_DIR}/${WTL_INSTANCE_NAME}/secrets/secrets.php"
 cp secrets.php "${WTL_RUNNING_DIR}/${WTL_INSTANCE_NAME}/secrets/secrets.php"
fi
