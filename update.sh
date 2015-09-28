#!/bin/bash
cd "$(dirname "$(readlink "$0" || printf %s "$0")")"

# initial pull of repository
if [[ ! -d WikiToLearn ]] ; then
 git clone --recursive https://github.com/WikiToLearn/WikiToLearn.git WikiToLearn
fi

# update repo
cd WikiToLearn
git pull --recurse-submodules
git submodule update --recursive
