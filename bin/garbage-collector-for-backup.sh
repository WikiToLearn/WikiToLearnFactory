#!/bin/bash
cd "$(dirname "$(readlink "$0" || printf %s "$0")")"

if [ ! -f ../factory.config ] ; then
 echo "Missing ./factory.config. Run ./init-update.sh first"
 exit 1
fi

. ../factory.config
if [ "$WTL_FACTORY_RELASE" != "0.2" ] ; then
 echo "WTL Factory Relase Error"
 exit
fi
ls $WTL_BACKUP_PATH | sort -Vr
