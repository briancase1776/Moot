#!/bin/bash
# tests/run.sh
# Prove the moot: shell seats on a mesh say and hear in rounds, every one
# hears the round byte for byte, its own included where a tee hands it back.
# Every seat says at once before any hears, with a round past one pipe, and
# every say returns: the read ends hold a round of says as big as the moot
# was made for, a model's longest by default. A round is the next N says, so
# a seat a round ahead is kept and not swallowed. A seat cannot hear before
# it says. A seat spelled another way than the map spells it, a body holding
# a line shaped like the mark, and a say past what the moot was made for are
# all refused and put nothing on the wire. mesh 2 is one pipe, a say there at
# most a lane, and each seat hears the other; on mesh-p the parent hears the
# round. create leaves no patch when it cannot finish;
# remove leaves the moot when the patch will not go; remove it, see nothing
# left. Raspberries are what is said. Runs beside other patches, in a
# directory of its own, and touches only what it made. Needs $ICC, and
# Patch needs what its SKILL.md says.
# Copyright (c) 2026 Brian Case. All rights reserved.
# AI contributor: Claude (Anthropic)
#
# MIT License text omitted for brevity, See LICENCE.TXT
set -eu
cd "$(dirname "$0")/.."
S=$PWD/.claude/skills/moot/scripts
B=$(cd "${ICC:-../ICC}/.claude/skills/icc-patch/scripts" && pwd)
R=$(cd "${ICC:-../ICC}/.claude/skills/icc-raspberry/scripts" && pwd)/raspberry
T=$(mktemp -d); export TMPDIR=$T; cd "$T"; made=
trap 'for d in $made; do "$S/remove" "$d" 2>/dev/null || :; done; rm -rf "$T"' EXIT
"$S/create" 2>/dev/null && exit 1
"$S/create" ring 3 2>/dev/null && exit 1
"$S/create" mesh 1 2>/dev/null && exit 1
"$S/create" mesh 3 0 2>/dev/null && exit 1
mk() {  # mk SHAPE N [BYTES]: create, note it for cleanup
  d=$("$S/create" "$@"); made="$made $d"; x=$(cut -d' ' -f3 "$d/moot")
}
blow() {  # blow R BYTES SEAT...: a raspberry for each seat, a line of its own
  for i in "${@:3}"; do { "$R" "$2"; echo; } > "in.$i.$1"; done
}
heard() {  # heard R EAR SEAT...: EAR heard just what SEAT... said in round R
  [ "$(grep -c '^SEAT ' "out.$2.$1")" -eq $(($# - 2)) ]
  awk -v o="got.$1.$2" '/^SEAT [0-9p]+$/ {f=o "." $2; next} {print > f}' "out.$2.$1"
  for j in "${@:3}"; do cmp "in.$j.$1" "got.$1.$2.$j"; done
}
# a create that cannot finish: mktemp fails for the moot's directory and logs
# every directory Patch's pieces asked for; none may survive
printf '#!/bin/bash\ncase $* in *moot-*) exit 1;; esac\n/usr/bin/mktemp "$@" | tee -a %s\n' "$T/asked" > mktemp
chmod +x mktemp
PATH=$T:$PATH "$S/create" mesh 3 2>/dev/null && exit 1
[ -s asked ]; for p in $(cat asked); do [ ! -e "$p" ]; done
# Made for says of 80000, four deep: a seat's read end holds three of them.
# All say at once, every say returns with nobody hearing, then every seat
# hears them all. A say past 80000 is refused and puts nothing on the wire.
mk mesh 3 80000; [ -f "$x/patch" ]
"$B/list" | grep -qx "$x up mesh 3 2 4"
"$S/say" "$d" 01 < /dev/null 2>/dev/null && exit 1
printf 'a\nSEAT 2\n' | "$S/say" "$d" 0 2>/dev/null && exit 1
"$R" 80000 | "$S/say" "$d" 0 2>/dev/null && exit 1
blow 1 70000 0 1 2
pids=; for i in 0 1 2; do timeout 60 "$S/say" "$d" $i < in.$i.1 & pids="$pids $!"; done
for p in $pids; do wait "$p"; done
pids=; for i in 0 1 2; do timeout 60 "$S/hear" "$d" $i > out.$i.1 & pids="$pids $!"; done
for p in $pids; do wait "$p"; done
for i in 0 1 2; do heard 1 $i 0 1 2; done
# a round is the next N: 0 and 1 hear round 2 and say round 3 before 2 hears
# round 2, and 2 hears round 2 and nothing of round 3
blow 2 3000 0 1 2; blow 3 3000 0 1 2
for i in 0 1 2; do "$S/say" "$d" $i < in.$i.2; done
for i in 0 1; do "$S/hear" "$d" $i > out.$i.2; "$S/say" "$d" $i < in.$i.3; done
"$S/hear" "$d" 2 > out.2.2; "$S/say" "$d" 2 < in.2.3
for i in 0 1 2; do heard 2 $i 0 1 2; "$S/hear" "$d" $i > out.$i.3; heard 3 $i 0 1 2; done
# a seat cannot hear before it says: the round is one short, and hear waits
printf 'REPORT\n' | "$S/say" "$d" 1; printf 'REPORT\n' | "$S/say" "$d" 2
timeout 3 "$S/hear" "$d" 0 > /dev/null && exit 1
"$S/remove" "$d"; [ ! -d "$d" ]; [ ! -d "$x" ]
# mesh 2 is one pipe, and each seat hears the other. Nothing deepens it, so a
# say is at most a lane: two that size said at once both go on. A say a round
# ahead is kept for the next hear.
mk mesh 2; [ "$(sed 1d "$x/patch" | cut -d' ' -f3 | sort -u | wc -l)" -eq 1 ]
[ "$(cut -d' ' -f5 "$d/moot")" -eq 65472 ]
blow 1 65000 0 1
pids=; for i in 0 1; do timeout 60 "$S/say" "$d" $i < in.$i.1 & pids="$pids $!"; done
for p in $pids; do wait "$p"; done
"$S/hear" "$d" 0 > out.0.1; "$S/hear" "$d" 1 > out.1.1
heard 1 0 1; heard 1 1 0
printf 'A\n' | "$S/say" "$d" 0; printf 'B\n' | "$S/say" "$d" 1
"$S/hear" "$d" 1 > r; grep -qx A r; printf 'C\n' | "$S/say" "$d" 1
"$S/hear" "$d" 0 > r; grep -qx B r; grep -qx C r && exit 1
printf 'D\n' | "$S/say" "$d" 0; "$S/hear" "$d" 0 > r; grep -qx C r
"$S/hear" "$d" 1 > r; grep -qx D r
mv "$x/made" "$x/held"; "$S/remove" "$d" 2>/dev/null && exit 1; [ -f "$d/moot" ]
mv "$x/held" "$x/made"; "$S/remove" "$d"; [ ! -d "$d" ]; [ ! -d "$x" ]
# on mesh-p the parent hears the round, as the seats do and in their order;
# made as a moot is by default, for says as big as a model's longest
mk mesh-p 2
"$S/hear" "$d" p > out.p.1 & h=$!
blow 1 500000 0 1
pids=; for i in 0 1; do timeout 60 "$S/say" "$d" $i < in.$i.1 & pids="$pids $!"; done
for p in $pids; do wait "$p"; done
for i in 0 1; do "$S/hear" "$d" $i > out.$i.1; heard 1 $i 0 1; done
wait $h; heard 1 p 0 1; cmp out.p.1 out.0.1
"$S/remove" "$d"; [ ! -d "$d" ]; [ ! -d "$x" ]
echo ok
