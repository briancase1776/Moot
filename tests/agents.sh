#!/bin/bash
##
# @file agents.sh
# @brief Prove the wire carries for agents, which run.sh cannot.
# @details agents.sh [N] [BYTES]. Shell seats share a process tree and a
#          shell; agents share neither. Sits a mesh-p of N seats, 3 when
#          not given, made for says of BYTES, create's default when not
#          given; prints one brief per seat for the parent to spawn; then
#          hears both rounds as p and checks every seat said once and heard
#          every other. Two rounds and not one, because hear counts N and
#          does not know seats, so a round that counts wrong only shows on
#          the round after it.
# @stdin nothing
# @stdout the briefs, then what p heard checked, and ok
# @stderr whatever a failing step printed
# @exit 0 every seat said once and heard every other; otherwise not
#
# Copyright (c) 2026 Brian Case. All rights reserved.
# AI contributor: Claude (Anthropic)
#
# MIT Licence. See LICENCE.TXT
##
nSeats=${1:-3}
nBytes=${2:-524288}
set -eu
cd "$(dirname "$0")/.."
pMoot=$PWD/.claude/skills/moot/scripts
pSkill=$PWD/.claude/skills/moot/SKILL.md
# Armed before anything is made: the moot and the work directory go
# however this ends.
pDir=
pWork=
trap '[ -z "$pDir" ] || "$pMoot/remove" "$pDir" 2>/dev/null || :
      [ -z "$pWork" ] || rm -rf "$pWork"' EXIT
pDir=$("$pMoot/create" mesh-p "$nSeats" "$nBytes")
pWork=$(mktemp -d)

iSeat=0
while [ "$iSeat" -lt "$nSeats" ]; do
  cat <<BRIEF

---- brief for seat $iSeat, spawn all $nSeats at once, in the background ----
You are seat $iSeat of the moot at $pDir.

This is a WIRE TEST, not a deliberation. There is no matter. Investigate
nothing, and read nothing but $pSkill, and from it only how
say and hear are called. Make no work directory: you write no files.

Do exactly this, then stop.

  ROUND 1  Run: date -u +%Y-%m-%dT%H:%M:%S.%NZ  -- call it T1.
           say, one Bash call, quoted heredoc, marker PING-Q7x3, body:
               PING $iSeat <T1>
           hear, its own Bash call.

  ROUND 2  Run the same date again -- call it T2.
           say, one Bash call, quoted heredoc, marker PONG-Q7x3, body:
               PONG $iSeat <T2> SAW <every T1 you heard in round 1, space
               separated, in the order hear printed them>
           hear, its own Bash call.

Return the lines you heard in both rounds, verbatim, and nothing else. Say
nothing but those two bodies. Do not vote, report or raise anything. Give
every Bash call the longest timeout you have.
BRIEF
  iSeat=$((iSeat + 1))
done
echo
echo "---- waiting for round 1 ----"
timeout 1800 "$pMoot/hear" "$pDir" p > "$pWork/r1"
echo "---- waiting for round 2 ----"
timeout 1800 "$pMoot/hear" "$pDir" p > "$pWork/r2"

awk -v n="$nSeats" '
  function bad(m) { print "  FAIL: " m; rc = 1 }
  FILENAME ~ /r1$/ && /^PING / {
    if (++seen[$2] > 1) bad("seat " $2 " pinged twice")
    t[$2] = $3; np++; ord = ord " " $3 }
  FILENAME ~ /r2$/ && /^PONG / {
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
    # What a seat saw is the order p heard, less its own.
    same = 1
    for (s in saw) {
      want = ord
      i = index(want, " " t[s])
      if (i) want = substr(want, 1, i - 1) substr(want, i + 1 + length(t[s]))
      if (saw[s] != want) same = 0
    }
    print "  every seat said once and heard every other: " (rc ? "no" : "yes")
    # The tee hands every seat the order the merge took the says in, so
    # this should be the same everywhere; it is reported, not required.
    print "  order seen: " (same ? "the same at every seat, and at p" \
                                  : "differed between seats")
    exit rc
  }' "$pWork/r1" "$pWork/r2"
echo ok
