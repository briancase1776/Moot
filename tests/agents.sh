#!/bin/bash
##
# @file agents.sh
# @brief Prove the wire carries for agents, which run.sh cannot.
# @details agents.sh sit [N] [BYTES], then agents.sh check DIR. Shell seats
#          share a process tree and a shell; agents share neither. sit makes
#          a mesh-p of N seats, 3 when not given, made for says of BYTES,
#          create's default when not given, prints one brief per seat for
#          the parent to spawn, and returns, leaving the moot up: the seats
#          are the parent's, and only the parent sees them return. Once
#          every seat has returned, check hears both rounds as p, checks
#          every seat said once and heard every other and not itself, and
#          removes the moot, however it ends. Two rounds and not one,
#          because hear at p counts N off the merge and does not know seats,
#          so a round that counts wrong only shows on the round after it.
#          p's read end holds a round of says of BYTES, so both rounds of a
#          seat's short lines wait there and no seat waits on p. Neither
#          call waits on a seat, so neither outlasts the parent's call:
#          what each printed is what the call returned, and the parent
#          reads no file Claude Code keeps.
# @stdin nothing
# @stdout sit: the briefs, then the check to run; check: what p heard
#         checked, then ok
# @stderr whatever a failing step printed
# @exit 0 sit made the moot, or check found every seat said once and heard
#       every other; otherwise not
#
# Copyright (c) 2026 Brian Case. All rights reserved.
# AI contributor: Claude (Anthropic)
#
# MIT Licence. See LICENCE.TXT
##
set -eu
cd "$(dirname "$0")/.."
pMoot=$PWD/.claude/skills/moot/scripts
pHear=$PWD/.claude/skills/moot-hear/scripts/hear
pSaySkill=$PWD/.claude/skills/moot-say/SKILL.md
pHearSkill=$PWD/.claude/skills/moot-hear/SKILL.md
pAgents=$PWD/tests/agents.sh
source "${ICC:-../ICC}/.claude/skills/icc-lib/scripts/lib"
pDir=
case ${1:-} in
  sit)
    nSeats=${2:-3}
    nBytes=${3:-524288}
    # Armed before anything is made, as icc-lib's vArm says: the moot goes
    # however this ends, until the briefs are out.
    vArm '[ -z "$pDir" ] || "$pMoot/remove" "$pDir" 2>/dev/null || :'
    pDir=$("$pMoot/create" mesh-p "$nSeats" "$nBytes")
    iSeat=0
    while [ "$iSeat" -lt "$nSeats" ]; do
      cat <<BRIEF

---- brief for seat $iSeat, spawn all $nSeats at once, in the background ----
You are seat $iSeat of the moot at $pDir.

This is a WIRE TEST, not a deliberation. There is no matter. Investigate
nothing, and read nothing but $pSaySkill and
$pHearSkill, how say and hear are called. Make no work
directory: you write no files.

Do exactly this, then stop.

  ROUND 1  Run: date -u +%Y-%m-%dT%H:%M:%S.%NZ  -- call it T1.
           say, one Bash call, piped from printf as moot-say says, body:
               PING $iSeat <T1>
           hear, its own Bash call.

  ROUND 2  Run the same date again -- call it T2.
           say, one Bash call, piped from printf as moot-say says, body:
               PONG $iSeat <T2> SAW <every T1 you heard in round 1, space
               separated, in the order hear printed them>
           hear, its own Bash call.

Return the lines you heard in both rounds, verbatim, and nothing else. Say
nothing but those two bodies. Do not vote, report or raise anything. Give
every Bash call the longest timeout you have.
BRIEF
      iSeat=$((iSeat + 1))
    done
    # The briefs are out, so seats may be on the wire: from here the moot is
    # the parent's, and check takes it away.
    vDisarm
    echo
    echo "once every seat has returned: $pAgents check $pDir"
    ;;
  check)
    pDir=${2:?usage: agents.sh check DIR}
    nSeats=$(cut -d' ' -f2 "$pDir/moot")
    vArm '"$pMoot/remove" "$pDir" 2>/dev/null || :'
    # Every seat has said both rounds, so both are on p's read end and
    # neither hear waits. What p hears is held here and goes into no file.
    osRound1=$(timeout 60 "$pHear" "$pDir" p)
    osRound2=$(timeout 60 "$pHear" "$pDir" p)
    awk -v n="$nSeats" '
      function bad(m) { print "  FAIL: " m; rc = 1 }
      nRound == 1 && /^PING / {
        if (++seen[$2] > 1) bad("seat " $2 " pinged twice")
        t[$2] = $3; np++ }
      nRound == 2 && /^PONG / {
        if (++sn[$2] > 1) bad("seat " $2 " ponged twice")
        saw[$2] = ""
        for (k = 5; k <= NF; k++) saw[$2] = saw[$2] " " $k
        ng++ }
      END {
        if (np != n) bad(np " pings, wanted " n)
        if (ng != n) bad(ng " pongs, wanted " n)
        for (s = 0; s < n; s++) {
          if (!(s in t)) bad("no ping from seat " s)
          if (!(s in saw)) { bad("no pong from seat " s); continue }
          # A seat hears every other seat and not itself.
          for (q in t) if (q != s && index(saw[s], t[q]) == 0)
            bad("seat " s " never heard seat " q)
          if (s in t && index(saw[s], t[s]) != 0)
            bad("seat " s " heard itself")
        }
        print "  every seat said once and heard every other: " \
          (rc ? "no" : "yes")
        exit rc
      }' nRound=1 <(printf '%s\n' "$osRound1") \
        nRound=2 <(printf '%s\n' "$osRound2")
    echo ok
    ;;
  *)
    echo "usage: agents.sh sit [N] [BYTES], then agents.sh check DIR" >&2
    exit 1
    ;;
esac
