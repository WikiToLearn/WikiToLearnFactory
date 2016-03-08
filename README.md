# WikiToLearnFactory
Scripts and stuff for create, destroy, backup, migrate instances of WikiToLearn

This scripts act like an orchestrator of wikitolearn backup/update and migration ops

Scripts in this repos are useless for a single instance of the site


First time checkout
===================

The first script to run is

    export WTL_BACKUP_PATH=<path of backups>
    ./init-upate.sh
  
this pull the WikiToLearn repository and make a basic configuration file.
When you want pull last version of wikitolearn repo the command is:

    ./init-upate.sh
    
To start an instance the command is:

    ./relase-new-version.sh
