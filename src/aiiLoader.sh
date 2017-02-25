#!/bin/bash
#
# AppleIntelInfo Loader Version 0.0.1 - Copyright (c) 2017 by M.F.C.
#
# Introduction:
#     - AppleIntelInfo Loader is a simple automated bash script that
#       loads Piker-Alpha's AppleIntelInfo.kext without any user input.
#     - Simply unzip the aiiLoader.command file and double click!
#
#
# Bugs:
#			- Bug reports can be filed at:
#        https://github.com/mattcarlotta/AppleIntelInfoLoader/issues
#			- Please provide clear steps to reproduce the bug and the output
#        of the script. Thank you!

#===============================================================================##
## GLOBAL VARIABLES #
##==============================================================================##
gFile="AppleIntelInfo.kext"

#===============================================================================##
## END SCRIPT #
##==============================================================================##
function endScript() {
  exit=$1
  Sleep 2
  echo ''
  echo 'Terminating the script...'
  Sleep 1.5
  if [[ $exit -eq 0 ]];
    then
    #
    # exit script without terminating window
    #
    killall Terminal
    else
    #
    # unload kext and exit script
    #
    echo ''
    sudo kextunload ${gFile}
    exit 0;
  fi
}

#===============================================================================##
## POPULATE STATES #
##==============================================================================##
function populateStates {
  let timesToLoop=10
  let timeLeft=10

  for (( i=0; i < $timesToLoop; i++ ))
  do
    sudo cat /tmp/AppleIntelInfo.dat
    timeLeft="$((timeLeft - 1))"
    if (( $timeLeft >= 1 ))
    then
      echo ''
      echo '----------------------------------------------------'
      echo "Status: Populating the CPU states ${timeLeft} more time(s)..."
      echo '----------------------------------------------------'
      echo ''
      sleep 10
    else
      echo ''
      echo '----------------------------------------------------'
      echo "Status: Done populating the CPU states!"
      echo '----------------------------------------------------'
    fi
  done
}

#===============================================================================##
## MAIN #
##==============================================================================##
function main(){
  sudo chown -R 0:0 ${gFile}
  sudo chmod -R 755 ${gFile}
  sudo kextload ${gFile}
  populateStates
  endScript 1
}

#===============================================================================##
## CHECK IF FILE EXISTS #
##==============================================================================##
function checkFileExist() {
  cd ~/Desktop
  if [ ! -e ${gFile} ];
  then
    echo "${gFile} not found!"
    sleep 1.5
    endScript
  else
    echo "This script must be temporarily run as root!"
    main
  fi
}

#===============================================================================##
## GREET USER #
##==============================================================================##
function greet(){
  echo '     AppleIntelInfo Loader Version 0.0.1 - Copyright (c) 2017 by M.F.C.'
  echo '--------------------------------------------------------------------------------'
  echo ''
  sleep 0.5
}

#===============================================================================##
## START PROGRAM #
##==============================================================================##
clear
greet
checkFileExist
#================================================================================
