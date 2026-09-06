#!/bin/sh
# tests/run.sh
# Prove the moot: shell seats on a mesh say and hear in rounds, every one
# hears all N, its own included, byte for byte, with a round bigger than the
# fittings hold in flight; a seat cannot hear before it says; the lock is
# down between rounds; mesh 2 is one pipe and works the same; on mesh-p the
# parent hears every round; remove it, see nothing left.
# Copyright (c) 2026 Brian Case. All rights reserved.
# AI contributor: Claude (Anthropic)
#
# MIT License text omitted for brevity, See LICENCE.TXT
set -eu
cd "$(dirname "$0")/.."
S=.claude/skills/moot/scripts
B=${ICC_PATCH:-../ICC-Patch}/.claude/skills/icc-patch/scripts
"$S/create" 2>/dev/null && exit 1
"$S/create" ring 3 2>/dev/null && exit 1
"$S/create" mesh 1 2>/dev/null && exit 1
[ -z "$("$B/list")" ]
trap 'for d in /tmp/moot-*; do "$S/remove" "$d" 2>/dev/null || :; done; rm -f in.* out.* got.*' EXIT INT TERM
seat() {  # seat I R BYTES: say BYTES of I's own, hear, keep the round
  head -c "$3" /dev/urandom | base64 > "in.$1.$2"
  timeout 60 "$S/say" "$d" "$1" < "in.$1.$2"
  timeout 60 "$S/hear" "$d" "$1" > "out.$1.$2"
}
round() {  # round R BYTES SEAT...: every seat at once, then check each heard all
  r=$1; z=$2; shift 2; pids=
  for i; do seat "$i" "$r" "$z" & pids="$pids $!"; done
  for p in $pids; do wait "$p"; done
  for i; do
    [ "$(grep -c '^SEAT ' "out.$i.$r")" -eq $# ]
    awk -v o="got.$r" '/^SEAT [0-9p]+$/ {f=o "." $2; next} {print > f}' "out.$i.$r"
    for j; do cmp "in.$j.$r" "got.$r.$j"; done
  done
  [ ! -e "$x/lock" ]
}
d=$("$S/create" mesh 3); x=$(cut -d' ' -f3 "$d/moot"); [ -f "$x/patch" ]
"$B/list" | grep -qx "$x up mesh 3 2"
round 1 100000 0 1 2
round 2 100 0 1 2
printf 'REPORT\n' | "$S/say" "$d" 1; printf 'REPORT\n' | "$S/say" "$d" 2
timeout 3 "$S/hear" "$d" 0 > /dev/null && exit 1
printf 'REPORT\n' | "$S/say" "$d" 0
for i in 0 1 2; do "$S/hear" "$d" $i > out.$i.3; [ "$(grep -c '^REPORT$' out.$i.3)" -eq 3 ]; done
"$S/remove" "$d"; [ ! -d "$d" ]; [ ! -d "$x" ]
d=$("$S/create" mesh 2); x=$(cut -d' ' -f3 "$d/moot")
round 1 100000 0 1
"$S/remove" "$d"
d=$("$S/create" mesh-p 2 4); x=$(cut -d' ' -f3 "$d/moot")
"$S/hear" "$d" p > out.p.1 & h=$!
round 1 50000 0 1
wait $h; [ "$(grep -c '^SEAT ' out.p.1)" -eq 2 ]; cmp out.p.1 out.0.1
"$S/remove" "$d"; [ ! -d "$d" ]; [ ! -d "$x" ]
[ -z "$("$B/list")" ]
rm -f in.* out.* got.*
trap - EXIT
echo ok
