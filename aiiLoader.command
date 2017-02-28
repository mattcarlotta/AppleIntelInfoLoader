#!/bin/bash
#
# AppleIntelInfo Loader Version 1.1.0 - Copyright (c) 2017 by M.F.C. and PMheart
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

# User's current directory
gRepo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Kext path, will be overrided by _find_kext()
gKext=""

# Kext name
gAii="AppleIntelInfo.kext"

# AII.kext Repo
gPikerAII="https://github.com/Piker-Alpha/AppleIntelInfo"


#===============================================================================##
## CHECK SIP #
##==============================================================================##
function _getSIPStat()
{
  case "$(/usr/bin/csrutil status)" in
    "System Integrity Protection status: enabled." )
      printf 'ERROR! S.I.P is enabled, aborting...\n'
      printf 'Please disable S.I.P. by setting CsrActiveConfig to 0x67 in your config.plist!\n'
      exit 1
      ;;

    *"Kext Signing: enabled"* )
      printf 'ERROR! S.I.P. is partially disabled, but kext signing is still enabled, aborting...\n'
      printf 'Please completely disable S.I.P. by setting CsrActiveConfig to 0x67 in your config.plist!\n'
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
  printf "Searching for ${gAii} in ${gRepo}...\n"
  if [[ ! -e "${gRepo}/${gAii}" ]];
    then
      printf "${gAii} was not found in the current directory!\n"
      printf " \n"
      printf "Searching for ${gAii} in $HOME/Desktop instead...\n"
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
              printf ' \n'
              printf 'ERROR! Make sure your network connection is active and/or make sure you have already installed Xcode from the App store!\n'
              exit 1
            else
              cd AppleIntelInfo
              xcodebuild > /dev/null
              if [[ $? -eq 0 ]];
                then
                  mv ./build/Release/AppleIntelInfo.kext $HOME/Desktop
                  gKext="$dkpKext"
                else
                  printf "ERROR! Compiling the ${gAii} has failed, aborting...\n"
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
      printf "ERROR loading ${gKext}, aborting...\n"
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
      printf 'ERROR! Unable to populate AppleIntelInfo/s results, aborting...\n'
      exit 1
  fi
}


#===============================================================================##
## GREET USER #
##==============================================================================##
function greet(){
  echo ' AppleIntelInfo Loader Version 1.1.0 - Copyright (c) 2017 by M.F.C. and PMheart'
  echo '--------------------------------------------------------------------------------'
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


#===============================================================================##
## EOF #
##==============================================================================##
