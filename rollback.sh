#!/bin/bash
cd "$(dirname "$(readlink "$0" || printf %s "$0")")"

if [ ! -f ./factory.config ] ; then
 echo "Missing ./factory.config. Run ./init-update.sh first"
 exit 1
fi

. ./factory.config
if [ "$W2L_FACTORY_RELASE" != "0.2" ] ; then
 echo "W2L Factory Relase Error"
 exit
fi

if [[ -f ./instances.log ]] ; then
 W2L_INSTANCE_NAME=$(cat ./instances.log | tail -2 | head -1)
fi

REPLY=""
REPLY_DO="yY"
# if you set I_know_what_I_m_doing=danger it skip asking confermation

if [[ "$I_know_what_I_m_doing" != "danger" ]]
then
 if [[ $(($RANDOM % 2 )) -eq 0 ]] ; then
  read -p "Are you sure? This operation can't be undone (y/n) " -n 1 -r
  echo
 else
  read -p "You want quit? (y/n) " -n 1 -r
  echo
  REPLY_DO="nN"
 fi
else
 REPLY="y"
fi

if [[ $REPLY =~ ^[$REPLY_DO]$ ]]
then
 REPLY_DO="nN"
 if [[ "$I_know_what_I_m_doing" != "danger" ]]
 then
  if [[ $(($RANDOM % 2 )) -eq 0 ]] ; then
   read -p "You want quit the process? (y/n) " -n 1 -r
   echo
  else
   read -p "You want continue the process? (y/n) " -n 1 -r
   echo
   REPLY_DO="yY"
  fi
 else
  REPLY="n"
 fi

 if [[ $REPLY =~ ^[$REPLY_DO]$ ]]
 then
  echo "ok, I'm doing..."
 else
  exit
 fi
else
 exit
fi

[[ -z "$W2L_INSTANCE_NAME" ]] && W2L_INSTANCE_NAME="w2l-dev"

if [ ! -d "${W2L_RUNNING_DIR}" ] ; then
 echo "Missing ${W2L_RUNNING_DIR}"
 exit 1
fi

if [ ! -d "${W2L_RUNNING_DIR}/${W2L_INSTANCE_NAME}" ] ; then
 echo "Instance ${W2L_INSTANCE_NAME} not exist"
 exit 1
fi

cd "${W2L_RUNNING_DIR}/${W2L_INSTANCE_NAME}/Dockers"
./run.sh
./fix-hosts.sh
./use-instance.sh
