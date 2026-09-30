#!/bin/bash
##
# @file run.sh
# @brief Prove the table works: shell seats say and hear in rounds.
# @details Shell seats on a mesh say and hear in rounds, and every one hears
#          every other seat's words byte for byte and none of its own. Every
#          seat says at once before any hears, with a round past one pipe,
#          and every say returns: a read end holds a say as big as the moot
#          was made for, a model's longest by default, from each seat that
#          writes into it. A round is the next say from each, so a seat a
#          round ahead is kept and not swallowed, and a hear before its
#          round is all in says not yet and takes nothing. A seat spelled
#          another way than the map spells it, with an escape in it, or as
#          the map's "-", a body holding a line shaped like the mark, and a
#          say past what the moot was made for are all refused and put
#          nothing on the wire. mesh 2 is one pipe, a say there at most a
#          lane, and each seat hears the other; on mesh-p the parent hears
#          the round, every seat's, and cannot say. create leaves no patch
#          when it cannot finish or a signal cuts it off; remove leaves the
#          moot when the patch will not go; remove it, see nothing left. A
#          moot over an ICC checkout whose path has a space works.
#          Raspberries are what is said, and what is said and heard is held
#          here and goes into no file. Runs beside other patches, in a
#          directory of its own, and touches only what it made. Needs $ICC,
#          and Patch needs what its SKILL.md says; sources icc-lib from
#          there.
# @stdin nothing
# @stdout ok, once every check has passed
# @stderr whatever a failing check printed
# @exit 0 every check passed; otherwise the status of the first that
#       did not
#
# Copyright (c) 2026 Brian Case. All rights reserved.
# AI contributor: Claude (Anthropic)
#
# MIT Licence. See LICENCE.TXT
##
set -eu
cd "$(dirname "$0")/.."
pMoot=$PWD/.claude/skills/moot/scripts
pSay=$PWD/.claude/skills/moot-say/scripts/say
pHear=$PWD/.claude/skills/moot-hear/scripts/hear
pIcc=$(cd "${ICC:-../ICC}" && pwd)
pIccPatch=$pIcc/.claude/skills/icc-patch/scripts
pRaspberry=$pIcc/.claude/skills/icc-raspberry/scripts/raspberry
source "$pIcc/.claude/skills/icc-lib/scripts/lib"
# Armed before anything is made, as icc-lib's vArm says: every moot made
# goes, and the work directory with it, however this ends.
pWork=
osMade=
vArm 'for pMade in $osMade; do
        "$pMoot/remove" "$pMade" 2>/dev/null || :
      done
      [ -z "$pWork" ] || rm -rf "$pWork"'
pWork=$(mktemp -d)
cd "$pWork"
declare -A hSaid
declare -A hHeard

##
# @fn vMake()
# @brief Make a moot, and remember it for the EXIT trap.
# @param $1... - SHAPE N [BYTES], as create takes them
# @global pDir - set, the moot's directory
# @global pPatch - set, its patch
# @global osMade - read and set, every moot made so far
# @return 0; a create that fails ends the harness
##
vMake() {
  pDir=$("$pMoot/create" "$@")
  osMade="$osMade $pDir"
  pPatch=$(cut -d' ' -f3 "$pDir/moot")
}

##
# @fn vBlow()
# @brief Blow a raspberry of so many bytes for each seat.
# @param $1 nRound - the round it is for
# @param $2 nBytes - how long each raspberry is
# @param $3... - the seats
# @global hSaid - set, each seat's raspberry, by SEAT.ROUND
# @return 0
##
vBlow() {
  local nRound=$1
  local nBytes=$2
  local osSeat
  shift 2
  for osSeat; do
    hSaid[$osSeat.$nRound]=$("$pRaspberry" "$nBytes")
  done
}

##
# @fn vSay()
# @brief Have a seat say its raspberry for a round, a line of its own.
# @param $1 nRound - the round
# @param $2 osSeat - the seat
# @global hSaid - read
# @return 0; a say that fails or waits a minute ends the harness
##
vSay() {
  local nRound=$1
  local osSeat=$2
  printf '%s\n' "${hSaid[$osSeat.$nRound]}" |
    timeout 60 "$pSay" "$pDir" "$osSeat"
}

##
# @fn vHear()
# @brief Have a seat hear a round.
# @param $1 nRound - the round
# @param $2 osSeat - the seat
# @global hHeard - set, what the seat heard, by SEAT.ROUND, with a . after
#                  it so that the newline it ends in is kept
# @return 0; a hear that fails or waits a minute ends the harness
##
vHear() {
  local nRound=$1
  local osSeat=$2
  hHeard[$osSeat.$nRound]=$(
    timeout 60 "$pHear" "$pDir" "$osSeat" && echo .
  )
}

##
# @fn vHeard()
# @brief Succeed when a seat heard just what the other seats said, whole.
# @details The seats given are the round's speakers. A seat hears every one
#          but itself: its own words never come back to it.
# @param $1 nRound - the round
# @param $2 osEar - the seat that heard it
# @param $3... - the seats that said the round
# @return 0 it did; 1 it did not, which ends the harness
##
vHeard() {
  local nRound=$1
  local osEar=$2
  local osHeard=${hHeard[$osEar.$nRound]%.}
  local osSpeaker
  local aOthers=()
  shift 2
  for osSpeaker; do
    [ "$osSpeaker" = "$osEar" ] || aOthers+=("$osSpeaker")
  done
  [ "$(printf '%s' "$osHeard" | grep -c '^SEAT ')" -eq "${#aOthers[@]}" ]
  for osSpeaker in "${aOthers[@]}"; do
    [ "$(printf '%s' "$osHeard" | awk -v s="$osSpeaker" \
      '/^SEAT [0-9p]+$/ {f = ($2 == s); next} f; END {print "."}')" \
      = "${hSaid[$osSpeaker.$nRound]}"$'\n.' ]
  done
}

##
# @fn vAtOnce()
# @brief Have every seat given say its raspberry for a round at once, and
#        wait.
# @param $1 nRound - the round
# @param $2... - the seats
# @return 0; a say that fails or waits a minute ends the harness
##
vAtOnce() {
  local nRound=$1
  local osSeat
  local aPids=()
  local pidCall
  shift
  for osSeat; do
    vSay "$nRound" "$osSeat" &
    aPids+=($!)
  done
  for pidCall in "${aPids[@]}"; do wait "$pidCall"; done
}

"$pMoot/create" 2>/dev/null && exit 1
"$pMoot/create" ring 3 2>/dev/null && exit 1
"$pMoot/create" mesh 1 2>/dev/null && exit 1
"$pMoot/create" mesh 3 0 2>/dev/null && exit 1
# A create that cannot finish: mktemp fails for the moot's directory and
# logs every directory Patch's pieces asked for; none may survive.
printf '%s\n' '#!/bin/bash' 'case $* in *moot-*) exit 1;; esac' \
  "/usr/bin/mktemp \"\$@\" | tee -a $pWork/asked" > mktemp
chmod +x mktemp
PATH=$pWork:$PATH "$pMoot/create" mesh 3 2>/dev/null && exit 1
[ -s asked ]
for pAsked in $(cat asked); do [ ! -e "$pAsked" ]; done
rm mktemp
# A create a signal cuts off while Patch's create is building takes the
# patch with it and exits 1, as icc-lib's vCutOff checks.
vCutOff "$pMoot/create" mesh 3 1000
# Made for says of 80000, two deep: a seat's read end from each other seat
# holds one of them. All say at once, every say returns with nobody hearing,
# then every seat hears the others'. A say past 80000 is refused and puts
# nothing on the wire.
vMake mesh 3 80000
[ -f "$pPatch/patch" ]
"$pIccPatch/list" | grep -qx "$pPatch up mesh 3 2 2"
"$pSay" "$pDir" 01 < /dev/null 2>/dev/null && exit 1
"$pSay" "$pDir" '\060' < /dev/null 2>/dev/null && exit 1
timeout 3 "$pHear" "$pDir" - 2>&1 | grep -q '^no seat - '
printf 'a\nSEAT 2\n' | "$pSay" "$pDir" 0 2>/dev/null && exit 1
"$pRaspberry" 80000 | "$pSay" "$pDir" 0 2>/dev/null && exit 1
vBlow 1 70000 0 1 2
vAtOnce 1 0 1 2
for osSeat in 0 1 2; do
  vHear 1 "$osSeat"
  vHeard 1 "$osSeat" 0 1 2
done
# A round is the next say from each: 0 and 1 hear round 2 and say round 3
# before 2 hears round 2, and 2 hears round 2 and nothing of round 3.
vBlow 2 3000 0 1 2
vBlow 3 3000 0 1 2
for osSeat in 0 1 2; do vSay 2 "$osSeat"; done
for osSeat in 0 1; do
  vHear 2 "$osSeat"
  vSay 3 "$osSeat"
done
vHear 2 2
vSay 3 2
for osSeat in 0 1 2; do
  vHeard 2 "$osSeat" 0 1 2
  vHear 3 "$osSeat"
  vHeard 3 "$osSeat" 0 1 2
done
# A hear before its round is all in says not yet and takes nothing: 1 has
# said round 4 and 2 has not, so 0 hears nothing; once 2 says, 0 hears
# both whole.
vBlow 4 3000 1 2
vSay 4 1
BASH_MAX_TIMEOUT_MS=1000 timeout 60 "$pHear" "$pDir" 0 2>&1 >/dev/null |
  grep -qx 'seat 0: not yet, nothing taken'
vSay 4 2
vHear 4 0
vHeard 4 0 1 2
"$pMoot/remove" "$pDir"
[ ! -d "$pDir" ]
[ ! -d "$pPatch" ]
# mesh 2 is one pipe, and each seat hears the other. Nothing deepens it, so
# a say is at most a lane: two that size said at once both go on. A say a
# round ahead is kept for the next hear.
vMake mesh 2
[ "$(sed 1d "$pPatch/patch" | cut -d' ' -f3 | sort -u | wc -l)" -eq 1 ]
[ "$(cut -d' ' -f4 "$pDir/moot")" -eq 65472 ]
vBlow 1 65000 0 1
vAtOnce 1 0 1
vHear 1 0
vHear 1 1
vHeard 1 0 1
vHeard 1 1 0
printf 'A\n' | "$pSay" "$pDir" 0
printf 'B\n' | "$pSay" "$pDir" 1
osRound=$("$pHear" "$pDir" 1)
printf '%s\n' "$osRound" | grep -qx A
printf 'C\n' | "$pSay" "$pDir" 1
osRound=$("$pHear" "$pDir" 0)
printf '%s\n' "$osRound" | grep -qx B
printf '%s\n' "$osRound" | grep -qx C && exit 1
printf 'D\n' | "$pSay" "$pDir" 0
osRound=$("$pHear" "$pDir" 0)
printf '%s\n' "$osRound" | grep -qx C
osRound=$("$pHear" "$pDir" 1)
printf '%s\n' "$osRound" | grep -qx D
# remove leaves the moot when the patch will not go, and takes it all when
# it will
mv "$pPatch/made" "$pPatch/held"
"$pMoot/remove" "$pDir" 2>/dev/null && exit 1
[ -f "$pDir/moot" ]
mv "$pPatch/held" "$pPatch/made"
"$pMoot/remove" "$pDir"
[ ! -d "$pDir" ]
[ ! -d "$pPatch" ]
# On mesh-p the parent hears the round, every seat's words, off the merge,
# and cannot say; made as a moot is by default, for says as big as a model's
# longest.
vMake mesh-p 2
"$pSay" "$pDir" p < /dev/null 2>/dev/null && exit 1
exec {fdParent}< <("$pHear" "$pDir" p)
pidParent=$!
vBlow 1 500000 0 1
vAtOnce 1 0 1
for osSeat in 0 1; do
  vHear 1 "$osSeat"
  vHeard 1 "$osSeat" 0 1
done
hHeard[p.1]=$(cat <&"$fdParent" && echo .)
exec {fdParent}<&-
wait "$pidParent"
vHeard 1 p 0 1
"$pMoot/remove" "$pDir"
[ ! -d "$pDir" ]
[ ! -d "$pPatch" ]
# An ICC checkout whose path has a space in it: the moot's line ends with
# Patch's scripts, and say, hear and remove read them back whole.
ln -s "$pIcc" "with space"
ICC="$pWork/with space" vMake mesh 2 1000
grep -q ' /.*with space/' "$pDir/moot"
printf 'A\n' | "$pSay" "$pDir" 0
"$pHear" "$pDir" 1 | grep -qx A
"$pMoot/remove" "$pDir"
[ ! -d "$pDir" ]
[ ! -d "$pPatch" ]
echo ok
