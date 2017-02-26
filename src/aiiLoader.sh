#!/bin/bash
#
# AppleIntelInfo Loader Version 1.0. - Copyright (c) 2017 by M.F.C. and PMHeart
#
#
#
# Introduction:
#     - AppleIntelInfo Loader is a simple automated bash script that
#       loads Piker-Alpha's AppleIntelInfo.kext without any user input.
#     - Simply double click the aiiLoader.command file to load the script! 
#
#
# Bugs:
#     - Bug reports can be filed at:
#        https://github.com/mattcarlotta/AppleIntelInfoLoader/issues
#     - Please provide clear steps to reproduce the bug and the output
#        of the script. Thank you!
#
#


#===============================================================================##
## GLOBAL VARIABLES #
##==============================================================================##


gRepo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#
# Kext path, will be overrided by _find_kext()
#
gKext=""

gAii="AppleIntelInfo.kext"

gPikerAII="https://github.com/Piker-Alpha/AppleIntelInfo"


#===============================================================================##
## CHECK SIP #
##==============================================================================##


function _getSIPStat()
{
  case "$(/usr/bin/csrutil status)" in
    "System Integrity Protection status: enabled." )
      printf 'SIP enabled, aborting...\n'
      exit 1
      ;;

    *"Kext Signing: enabled"* )
      printf 'SIP Kext Restriction enabled, aborting...\n'
      exit 1
      ;;

    * )
      ;;
  esac
}


#===============================================================================##
## COMPILE KEXT #
##==============================================================================##


function _find_kext()
{
  local dkpKext="$HOME/Desktop/${gAii}"

  #
  # If the kext cannot be found at current dir,
  # then we shall search at Desktop.
  # If still not found,
  # then we need to download and then compile it.
  #
  if [[ ! -e "${gRepo}/${gAii}" ]];
    then
      printf "${gAii} could not be located!\n"
      printf " \n"
      printf "Searching for ${gAii} in $HOME/Desktop...\n"
      sleep 1
      if [[ -e "${dkpKext}" ]];
        then
          printf "${gAii} was found!\n"
          printf " \n"
          gKext="${dkpKext}"
        else
          printf "${gAii} wasn't found on the Desktop either!\n"
          printf " \n"
          printf "Downloading from Pike's GitHub instead...\n"
          cd /tmp
          rm -R ./AppleIntelInfo
          git clone "${gPikerAII}"
          if [[ $? -ne 0 ]];
            then
              printf 'An error occurred! Make sure your network connection is active and/or if you have installed Xcode properly!\n'
              exit 1
            else
              cd AppleIntelInfo
              xcodebuild > /dev/null
              if [[ $? -eq 0 ]];
                then
                  mv ./build/Release/AppleIntelInfo.kext $HOME/Desktop
                  gKext="$dkpKext"
                else
                  printf 'Uh-oh! Compilation failed!!!\n'
                  exit 1
              fi
          fi
      fi
    else
      gKext="${gRepo}/${gAii}"
  fi
}


#===============================================================================##
## SET PERMISSIONS #
##==============================================================================##

function _set_perm()
{
  chown -R 0:0 "${gKext}"
  chmod -R 755 "${gKext}"
}


#===============================================================================##
## USER ABORTS SCRIPT #
##==============================================================================##

function _clean_up() {
  printf "User aborted! Cleaning up script...\033[0K\r\n"
  sudo kextunload "${gKext}"
  clear
}

#===============================================================================##
## TIMOUT KEXT AND OUTPUT #
##==============================================================================##

function showTimer()
{
  secs=$((3 * 60))
  while [ $secs -gt 0 ]; do
    printf " ----- Generating kext output in: $secs seconds -----\033[0K\r"
    sleep 1
    : $((secs--))
  done
}

#===============================================================================##
## LOAD AND UNLOAD KEXT #
##==============================================================================##

function LoadAndUnload()
{
  sudo kextload "${gKext}"
  if [[ $? == 0 ]];
    then
      printf " \n"
      printf "${gAii} has been loaded! Sit back and relax. :-)\n"
      printf " \n"
      showTimer
      clear
      kextunload "${gKext}"
    else
      printf "ERROR loading ${gKext} !!!\n"
      exit 1
  fi
}


#===============================================================================##
## PRINT RESULT #
##==============================================================================##


function _printResult()
{
  if [ -f /tmp/AppleIntelInfo.dat ];
    then
      cat /tmp/AppleIntelInfo.dat
      echo ''
      echo '----------------------------------------------------'
      echo "Done populating the CPU states!"
      echo '----------------------------------------------------'
      exit 0
    else
      printf 'ERROR populating AppleIntelInfo/s results, aborting...\n'
      exit 1
  fi
}

#===============================================================================##
## GREET USER #
##==============================================================================##
function greet(){
  echo '     AppleIntelInfo Loader Version 1.0.0 - Copyright (c) 2017 by M.F.C. and PMHeart'
  echo '------------------------------------------------------------------------------------------'
  echo ''
  sleep 0.5
}


#===============================================================================##
## START #
##==============================================================================##


function main()
{
  clear
  greet
  _getSIPStat
  _find_kext
  _set_perm
  LoadAndUnload
  _printResult
}

trap '{ _clean_up; exit 1; }' INT

if [[ `id -u` -ne 0 ]];
  then
    echo "This script must be run as ROOT!"
    sudo "$0"
  else
    main
fi
