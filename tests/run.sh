#!/bin/sh
# tests/run.sh
# Prove the moot: shell seats on a mesh say and hear in rounds, every one
# hears all N, its own included, byte for byte, with a say bigger than a
# seat's end holds; a seat cannot hear before it says, and a hear cut off
# waiting leaves nothing behind; a say cut inside its write, and a hear cut
# inside what it left, make a seat that refuses; the lock is down between
# rounds; mesh 2 is one pipe and every seat hears all N there too; on
# mesh-p the parent hears the round; create leaves no patch when it cannot
# finish; remove leaves the moot when the patch will not go; remove it, see
# nothing left. Runs beside other patches, in a directory of its own, and
# touches only what it made. Needs $ICC_PATCH, and Patch needs what its
# SKILL.md says.
# Copyright (c) 2026 Brian Case. All rights reserved.
# AI contributor: Claude (Anthropic)
#
# MIT License text omitted for brevity, See LICENCE.TXT
set -eu
cd "$(dirname "$0")/.."
S=$PWD/.claude/skills/moot/scripts
B=$(cd "${ICC_PATCH:-../ICC-Patch}/.claude/skills/icc-patch/scripts" && pwd)
T=$(mktemp -d); export TMPDIR=$T; cd "$T"; made=
trap 'for d in $made; do "$S/remove" "$d" 2>/dev/null || :; done; rm -rf "$T"' EXIT INT TERM
"$S/create" 2>/dev/null && exit 1
"$S/create" ring 3 2>/dev/null && exit 1
"$S/create" mesh 1 2>/dev/null && exit 1
mk() {  # mk SHAPE N [LANES]: create, note it for cleanup, size a say past a seat's end
  d=$("$S/create" "$@"); made="$made $d"; x=$(cut -d' ' -f3 "$d/moot")
  big=$(( 65536 * ${3:-2} ))  # twice one pipe: LANES/2 lanes a side, 64K a lane
}
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
# a create that cannot finish: mktemp fails for the moot's directory and logs
# every directory Patch's pieces asked for; none may survive
printf '#!/bin/sh\ncase $* in *moot-*) exit 1;; esac\n/usr/bin/mktemp "$@" | tee -a %s\n' "$T/asked" > mktemp
chmod +x mktemp
PATH=$T:$PATH "$S/create" mesh 3 2>/dev/null && exit 1
[ -s asked ]; for p in $(cat asked); do [ ! -e "$p" ]; done
mk mesh 3; [ -f "$x/patch" ]
"$B/list" | grep -qx "$x up mesh 3 2"
round 1 "$big" 0 1 2
round 2 100 0 1 2
printf 'REPORT\n' | "$S/say" "$d" 1; printf 'REPORT\n' | "$S/say" "$d" 2
timeout 3 "$S/hear" "$d" 0 > /dev/null && exit 1
[ ! -e "$d/0/.next" ]
printf 'REPORT\n' | "$S/say" "$d" 0
for i in 0 1 2; do "$S/hear" "$d" $i > out.$i.3; [ "$(grep -c '^REPORT$' out.$i.3)" -eq 3 ]; done
"$S/remove" "$d"; [ ! -d "$d" ]; [ ! -d "$x" ]
mk mesh 2; [ "$(sed 1d "$x/patch" | cut -d' ' -f3 | sort -u | wc -l)" -eq 1 ]
round 1 "$big" 0 1
head -c "$big" /dev/urandom | timeout 1 "$S/say" "$d" 1 2>/dev/null && exit 1
timeout 3 "$S/hear" "$d" 0 2>/dev/null && exit 1
[ -s "$d/0/.next" ]
timeout 3 "$S/hear" "$d" 0 2>&1 | grep -q 'did not finish'
printf 'REPORT\n' | timeout 3 "$S/say" "$d" 0 2>&1 | grep -q 'did not finish'
mv "$x/made" "$x/held"; "$S/remove" "$d" 2>/dev/null && exit 1; [ -f "$d/moot" ]
mv "$x/held" "$x/made"; "$S/remove" "$d"; [ ! -d "$d" ]; [ ! -d "$x" ]
mk mesh-p 2 4
"$S/hear" "$d" p > out.p.1 & h=$!
round 1 "$big" 0 1
wait $h; [ "$(grep -c '^SEAT ' out.p.1)" -eq 2 ]; cmp out.p.1 out.0.1
"$S/remove" "$d"; [ ! -d "$d" ]; [ ! -d "$x" ]
echo ok
