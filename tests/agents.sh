#!/bin/bash
# tests/agents.sh
# Prove the wire carries for agents, which tests/run.sh cannot: shell seats
# share a process tree and a shell, agents share neither. Sits a mesh-p, prints
# one brief per seat for the parent to spawn, then hears both rounds as p and
# checks every seat said once and heard every other. Two rounds and not one,
# because hear counts N and does not know seats, so a round that counts wrong
# only shows on the round after it. Usage: agents.sh [N] [LANES].
# Copyright (c) 2026 Brian Case. All rights reserved.
# AI contributor: Claude (Anthropic)
#
# MIT License text omitted for brevity, See LICENCE.TXT
set -eu
n=${1:-3}; lanes=${2:-2}
[ "$n" -ge 2 ] 2>/dev/null || { echo "seats must be 2 or more" >&2; exit 1; }
cd "$(dirname "$0")/.."
S=$PWD/.claude/skills/moot/scripts
K=$PWD/.claude/skills/moot/SKILL.md
d=$("$S/create" mesh-p "$n" "$lanes")
trap '"$S/remove" "$d" 2>/dev/null || :' EXIT
w=$(mktemp -d)
trap '"$S/remove" "$d" 2>/dev/null || :; rm -rf "$w"' EXIT

i=0; while [ "$i" -lt "$n" ]; do cat <<BRIEF

---- brief for seat $i, spawn all $n at once, in the background ----
You are seat $i of the moot at $d.

This is a WIRE TEST, not a deliberation. There is no matter. Investigate
nothing, and read nothing but $K, and from it only how
say and hear are called. Make no work directory: you write no files.

Do exactly this, then stop.

  ROUND 1  Run: date -u +%Y-%m-%dT%H:%M:%S.%NZ  -- call it T1.
           say, one Bash call, quoted heredoc, marker PING-Q7x3, body:
               PING $i <T1>
           hear, its own Bash call.

  ROUND 2  Run the same date again -- call it T2.
           say, one Bash call, quoted heredoc, marker PONG-Q7x3, body:
               PONG $i <T2> SAW <every T1 you heard in round 1, space
               separated, in the order hear printed them>
           hear, its own Bash call.

Return the lines you heard in both rounds, verbatim, and nothing else. Say
nothing but those two bodies. Do not vote, report or raise anything. Give
every Bash call the longest timeout you have.
BRIEF
i=$((i + 1)); done
echo
echo "---- waiting for round 1 ----"
timeout 1800 "$S/hear" "$d" p > "$w/r1"
echo "---- waiting for round 2 ----"
timeout 1800 "$S/hear" "$d" p > "$w/r2"

awk -v n="$n" '
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
      for (q in t) if (index(saw[s], t[q]) == 0)
        bad("seat " s " never heard seat " q)
    }
    same = 1; for (s in saw) if (saw[s] != ord) same = 0
    print "  every seat said once and heard all " n ": " (rc ? "no" : "yes")
    # Order is a race through the fittings, as SKILL.md says, so this is
    # reported and never required.
    print "  order seen: " (same ? "the same at every seat, and at p" \
                                  : "differed between seats, which is allowed")
    exit rc
  }' "$w/r1" "$w/r2"
echo ok
