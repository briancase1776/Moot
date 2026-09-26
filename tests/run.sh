#!/bin/bash
##
# @file run.sh
# @brief Prove the table works: shell seats say and hear in rounds.
# @details Shell seats on a mesh say and hear in rounds, and every one
#          hears every other seat's words byte for byte and none of its
#          own; p hears them all. Every seat says at once before any
#          hears, with a round past one pipe, and every say returns: the
#          read ends hold a round of says as big as the moot was made for,
#          a model's longest by default. A round is the next N says, so a
#          seat a round ahead is kept and not swallowed. A seat cannot
#          hear before it says. A seat spelled another way than the map
#          spells it, a body holding a line shaped like the mark, and a
#          say past what the moot was made for are all refused and put
#          nothing on the wire. mesh 2 is one pipe, a say there at most a
#          lane, and each seat hears the other; on mesh-p the parent hears
#          the round. create leaves no patch when it cannot finish; remove
#          leaves the moot when the patch will not go; remove it, see
#          nothing left. Raspberries are what is said. Runs beside other
#          patches, in a directory of its own, and touches only what it
#          made. Needs $ICC, and Patch needs what its SKILL.md says.
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
pIccPatch=$(cd "${ICC:-../ICC}/.claude/skills/icc-patch/scripts" && pwd)
pRaspberry=$(cd "${ICC:-../ICC}/.claude/skills/icc-raspberry/scripts" &&
  pwd)/raspberry
# Armed before anything is made: every moot made goes, and the work
# directory with it, however this ends.
pWork=
osMade=
trap 'for pMade in $osMade; do
        "$pMoot/remove" "$pMade" 2>/dev/null || :
      done
      [ -z "$pWork" ] || rm -rf "$pWork"' EXIT
pWork=$(mktemp -d)
export TMPDIR=$pWork
cd "$pWork"

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
# @brief Blow a raspberry of so many bytes for each seat, a line of its own.
# @param $1 nRound - the round it is for
# @param $2 nBytes - how long each raspberry is
# @param $3... - the seats
# @return 0
##
vBlow() {
  local nRound=$1
  local nBytes=$2
  local osSeat
  shift 2
  for osSeat; do
    {
      "$pRaspberry" "$nBytes"
      echo
    } > "in.$osSeat.$nRound"
  done
}

##
# @fn vHeard()
# @brief Succeed when a seat heard just what the other seats said, whole.
# @details The seats given are the round's speakers. A seat hears every one
#          but itself: its own words are taken off the wire and not
#          printed, so it has none of its own in what it heard.
# @param $1 nRound - the round
# @param $2 osEar - the seat that heard it
# @param $3... - the seats that said the round
# @return 0 it did; 1 it did not, which ends the harness
##
vHeard() {
  local nRound=$1
  local osEar=$2
  local osSpeaker
  local aOthers=()
  shift 2
  for osSpeaker; do
    [ "$osSpeaker" = "$osEar" ] || aOthers+=("$osSpeaker")
  done
  [ "$(grep -c '^SEAT ' "out.$osEar.$nRound")" -eq "${#aOthers[@]}" ]
  awk -v o="got.$nRound.$osEar" \
    '/^SEAT [0-9p]+$/ {f = o "." $2; next} {print > f}' \
    "out.$osEar.$nRound"
  for osSpeaker in "${aOthers[@]}"; do
    cmp "in.$osSpeaker.$nRound" "got.$nRound.$osEar.$osSpeaker"
  done
}

##
# @fn vAtOnce()
# @brief Run one call of say or hear for each seat at once, and wait.
# @param $1 osVerb - say or hear
# @param $2 nRound - the round, whose in or out files it reads or writes
# @param $3... - the seats
# @return 0; a call that fails or waits a minute ends the harness
##
vAtOnce() {
  local osVerb=$1
  local nRound=$2
  local osSeat
  local aPids=()
  local pidCall
  shift 2
  for osSeat; do
    if [ "$osVerb" = say ]; then
      timeout 60 "$pMoot/say" "$pDir" "$osSeat" < "in.$osSeat.$nRound" &
    else
      timeout 60 "$pMoot/hear" "$pDir" "$osSeat" > "out.$osSeat.$nRound" &
    fi
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
# Made for says of 80000, four deep: a seat's read end holds three of them.
# All say at once, every say returns with nobody hearing, then every seat
# hears them all. A say past 80000 is refused and puts nothing on the wire.
vMake mesh 3 80000
[ -f "$pPatch/patch" ]
"$pIccPatch/list" | grep -qx "$pPatch up mesh 3 2 4"
"$pMoot/say" "$pDir" 01 < /dev/null 2>/dev/null && exit 1
printf 'a\nSEAT 2\n' | "$pMoot/say" "$pDir" 0 2>/dev/null && exit 1
"$pRaspberry" 80000 | "$pMoot/say" "$pDir" 0 2>/dev/null && exit 1
vBlow 1 70000 0 1 2
vAtOnce say 1 0 1 2
vAtOnce hear 1 0 1 2
for osSeat in 0 1 2; do vHeard 1 "$osSeat" 0 1 2; done
# A round is the next N: 0 and 1 hear round 2 and say round 3 before 2
# hears round 2, and 2 hears round 2 and nothing of round 3.
vBlow 2 3000 0 1 2
vBlow 3 3000 0 1 2
for osSeat in 0 1 2; do "$pMoot/say" "$pDir" "$osSeat" < "in.$osSeat.2"; done
for osSeat in 0 1; do
  "$pMoot/hear" "$pDir" "$osSeat" > "out.$osSeat.2"
  "$pMoot/say" "$pDir" "$osSeat" < "in.$osSeat.3"
done
"$pMoot/hear" "$pDir" 2 > out.2.2
"$pMoot/say" "$pDir" 2 < in.2.3
for osSeat in 0 1 2; do
  vHeard 2 "$osSeat" 0 1 2
  "$pMoot/hear" "$pDir" "$osSeat" > "out.$osSeat.3"
  vHeard 3 "$osSeat" 0 1 2
done
# A seat cannot hear before it says: the round is one short, and hear
# waits.
printf 'REPORT\n' | "$pMoot/say" "$pDir" 1
printf 'REPORT\n' | "$pMoot/say" "$pDir" 2
timeout 3 "$pMoot/hear" "$pDir" 0 > /dev/null && exit 1
"$pMoot/remove" "$pDir"
[ ! -d "$pDir" ]
[ ! -d "$pPatch" ]
# mesh 2 is one pipe, and each seat hears the other. Nothing deepens it, so
# a say is at most a lane: two that size said at once both go on. A say a
# round ahead is kept for the next hear.
vMake mesh 2
[ "$(sed 1d "$pPatch/patch" | cut -d' ' -f3 | sort -u | wc -l)" -eq 1 ]
[ "$(cut -d' ' -f5 "$pDir/moot")" -eq 65472 ]
vBlow 1 65000 0 1
vAtOnce say 1 0 1
"$pMoot/hear" "$pDir" 0 > out.0.1
"$pMoot/hear" "$pDir" 1 > out.1.1
vHeard 1 0 1
vHeard 1 1 0
printf 'A\n' | "$pMoot/say" "$pDir" 0
printf 'B\n' | "$pMoot/say" "$pDir" 1
"$pMoot/hear" "$pDir" 1 > r
grep -qx A r
printf 'C\n' | "$pMoot/say" "$pDir" 1
"$pMoot/hear" "$pDir" 0 > r
grep -qx B r
grep -qx C r && exit 1
printf 'D\n' | "$pMoot/say" "$pDir" 0
"$pMoot/hear" "$pDir" 0 > r
grep -qx C r
"$pMoot/hear" "$pDir" 1 > r
grep -qx D r
# remove leaves the moot when the patch will not go, and takes it all when
# it will
mv "$pPatch/made" "$pPatch/held"
"$pMoot/remove" "$pDir" 2>/dev/null && exit 1
[ -f "$pDir/moot" ]
mv "$pPatch/held" "$pPatch/made"
"$pMoot/remove" "$pDir"
[ ! -d "$pDir" ]
[ ! -d "$pPatch" ]
# On mesh-p the parent hears the round, every seat's words, where a seat
# hears the others'; made as a moot is by default, for says as big as a
# model's longest.
vMake mesh-p 2
"$pMoot/hear" "$pDir" p > out.p.1 &
pidParent=$!
vBlow 1 500000 0 1
vAtOnce say 1 0 1
for osSeat in 0 1; do
  "$pMoot/hear" "$pDir" "$osSeat" > "out.$osSeat.1"
  vHeard 1 "$osSeat" 0 1
done
wait "$pidParent"
vHeard 1 p 0 1
"$pMoot/remove" "$pDir"
[ ! -d "$pDir" ]
[ ! -d "$pPatch" ]
echo ok
