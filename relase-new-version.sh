#!/bin/bash
cd "$(dirname "$(readlink "$0" || printf %s "$0")")"

if [ ! -f ./factory.config ] ; then
 echo "Missing ./factory.config. Run ./init-update.sh first"
 exit 1
fi

if [ ! -d WikiToLearn ] ; then
 echo "Missing WikiToLearn repo"
 exit 1
fi

. ./factory.config

cd WikiToLearn
COMMIT_HASH=""
if [[ "$W2L_STAGING" == "1" ]] ; then
 COMMIT_HASH=$(git log -n1 | grep commit | awk '{ print $2 }')
else
 COMMIT_HASH=$(git show $(git tag | sort -Vr | head -1) | head -1 | grep commit | awk '{ print $2 }')
fi
cd ..

echo $COMMIT_HASH
BACKUP_DIR=$(ls $W2L_BACKUP_PATH | sort -Vr | head -1)
echo $BACKUP_DIR
cat instances.log | head -1
