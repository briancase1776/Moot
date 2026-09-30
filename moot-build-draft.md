# Draft: moot-build, an add-on to moot

A draft to read, not a change. Nothing it proposes is in the repo yet.

moot-build is a second skill beside moot. It is not a rewrite: moot's
SKILL.md and its four scripts stay exactly as they are. moot-build has
no scripts of its own. It sits a moot as moot's SKILL.md says, and
adds a build round between two sittings of it:

1. **Plan:** a moot with ITEM lines in it.
2. **Build:** one round.
3. **Check:** the moot again, over what was built.

The seats divide the building by claiming items in one shared plan
file, locked with icc-lock while its status changes. They build in one
shared tree, locking each file while they edit it. The spread goes
where it finds things: every seat investigates everything and checks
everything, and each item is built once.

Part 1 is the change to CLAUDE.md. Part 2
is the add-on's SKILL.md. Part 3 is where this departs from what the
moot voted, and why. Part 4 is what is settled for now.


## Part 1. CLAUDE.md

### Already done

"The run" is gone from what this is not (1b49db2), and "not a
shared plan" is gone from what may narrow the spread (8fcfc96).

### What this is: add

> - **moot-build**, an add-on skill: a moot sat on a plan, one build
>   round, and the moot sat again on what was built. It uses moot's
>   four scripts and icc-lock, and changes nothing in moot.

### Depends on ICC: add

> moot-build takes icc-lock from the same `$ICC`, beside Patch's
> scripts, for its claims and its edits. A lock is Lock's; this repo
> says what a build moot locks and when, and nothing about what a lock
> is.

### Layout: add

```
.claude/skills/moot-build/SKILL.md  the add-on: plan, build, check,
                                    over moot's scripts. No scripts
                                    of its own.
```


## Part 2. .claude/skills/moot-build/SKILL.md

```
---
name: moot-build
description: >-
  Add-on to moot. Sit N cold agents on a moot that plans, builds and
  checks: they vote what should be built, divide the building among
  themselves by claiming items in a shared plan file, build in one
  shared tree under icc-lock, then check the tree and vote what is
  wrong with it. Returns the tree, the plan with its status, and what
  the check found.
---
```

# moot-build

A build moot is a moot, as moot's SKILL.md says, with a build round in
it. Everything there holds here: the wire, the rounds, say, hear, the
Facts, In Claude Code. This file says only what the build adds. MOOT is
moot's skill directory, beside this one.

A build moot needs hear to wait before it takes anything, so that a
hear cut off while waiting loses nothing and can be called again. That
is being made in moot. Until it is, a build moot cannot be sat: a build
round lasts as long as its slowest item, far past what one call may
wait, and a hear cut off has lost its round.

### Sitting one

The parent does this. Make a tree for the moot: a checkout of the
repository at a base commit, somewhere every seat can reach, its own
and nobody else's while the moot sits. Create the moot with
MOOT/scripts/create, as moot says. Brief every seat alike:

    You are seat I of the build moot at DIR. Read SKILL.md at PATH and
    MOOT/SKILL.md, and do what a seat of a build moot does. Cycles: K.
    The tree: TREE at BASE. The matter: ...

Spawn them all at once, as moot says. When they return, the tree holds
what was built, one commit an item, on top of BASE, and DIR/plan says
the status of every item. What the parent does with the tree is the
parent's.

Locks live in /tmp, not in DIR, so remove does not take them. Before
removing DIR, take away any a seat left behind: ICCLOCK/remove on
DIR/plan and on TREE/F for every file F that `git -C TREE ls-files`
and `git -C TREE ls-files --others` list. remove refuses a path
nobody holds. That is the sweep for a seat that died holding a lock,
not the plan. Then remove DIR with MOOT/scripts/remove.

### At a seat

Make your work dir as in any moot, WORK, and in it a clone of the
tree to run things in:

    git clone -q --shared TREE WORK/run

TREE is for editing under lock and for committing, and nothing runs in
it: a test, a build, an install or a CHECK writes files where it runs,
and in TREE those would be writes outside any lock. Everything that
runs, runs in your clone, brought first to TREE's HEAD:

    git -C WORK/run fetch -q origin HEAD
    git -C WORK/run reset -q --hard FETCH_HEAD

To run an item you have not committed yet, bring the clone to HEAD,
then, for each file you hold, copy it in if it is in TREE and remove
it from the clone if it is not: that carries a deletion, and a rename
is the two paths it touched. Nobody writes TREE before the build
round. Set TMPDIR to your work dir in every call that runs anything,
and bind nothing to a fixed port.

Every round of a build moot is sat, in the plan and in the check. No
step ends early: step 2 goes on though no seat said a DELTA, step 3
runs all N-1 rotations though the seats agree, and step 4 goes back to
3 until K cycles have run. A seat with nothing to add says an empty
REPORT. So every seat says in every round, and no seat decides alone
where the moot is.

**Plan.** Sit the moot, steps 1 to 5, with three changes.

- In step 2, say beside your DELTAs the changes you would build,
  numbered on in the same count, each one change and the command that
  shows it is done:

      ITEM I.3 the change
      CHECK the command

- Every ITEM is voted, even one no seat disputes, and is argued like a
  DELTA.
- Step 6 does not return: go on to the build.

Two items that cannot both be built are a DELTA like any other; if it
stands, neither is built. What stood is the plan: every ITEM with more
yes than no, in the order of their numbers. Every seat counts it from
the same bytes.

**Build.** One round. Two kinds of lock, for two things: the plan file,
which says who is doing what, and the files in the tree, which are what
is being done.

ICCLOCK is icc-lock's scripts, beside Patch's: the path DIR/moot ends
with, icc-patch put as icc-lock. Every change to the plan file is one
Bash call: take the lock, change one line, give the lock back:

    ICCLOCK/create DIR/plan && { CHANGE; ICCLOCK/remove DIR/plan; }

Refused, nothing else runs: call it again. Taken, remove runs whether
CHANGE worked or not. One call, so that no call ends holding the lock;
remove inside the braces, so that it only ever follows your own
create. `create && change; remove` runs remove when create is refused,
and takes away the lock of the seat that holds it. Read the plan file
whenever you like; change it only holding its lock.

CHANGE decides under the lock, not before it: what you read before
taking the lock may have changed by the time you hold it. It changes a
line only if the line still says what it expects, and then prints the
line, so the call shows whether the change took:

    sed -i 's/^1\.2 free$/1.2 claimed 0/' DIR/plan
    grep '^1\.2 ' DIR/plan

If the line printed is not yours, another seat got there first.

The plan file is one line an item that stood, in number order: the
item's number, as moot numbers a DELTA, so 1.2 is seat 1's second,
then its status. For example:

    0.1 done 2 3f2a9c1
    0.2 claimed 0
    1.1 claimed 1 waits 0.2
    1.2 free
    2.1 blocked 2 needs a schema change first

free; claimed and the seat that holds it; claimed and waits and the
item it waits on; done, the seat and the commit; blocked, the seat
and why.

1. The first seat to take the lock after the vote finds no plan file
   and writes it, every standing item free. Every other seat, taking
   the lock in turn, compares it with the items it counted, and says
   any difference in its REPORT this round.
2. Claim: in one CHANGE, find the first free line and mark it claimed
   I. Hold one unbuilt item at a time, but for this: if the item needs
   another built first, read that one's line. Done, go on. Free, claim
   it too and build it first. Claimed, follow its waits: from the line
   you would wait on, to the line that one waits on, and on. If the
   chain comes back to your item, the items need each other: mark
   yours blocked, and why. Otherwise add waits and its number to your
   line, and go on when its line says done. If it says blocked
   instead, mark yours blocked too, and why: it will never be done.
3. Build: lock every file in the tree the item needs, absolute path,
   before you edit any of them, and hold each until the item is
   committed. Refused one, give back the ones you hold, as Lock says,
   and try again later. Never give back a lock on a file you have
   changed and not committed: the next seat to lock it would edit on
   top of your change and commit it as its own. If you find partway
   that you need a file you are refused, first put back every file you
   changed as it was, then give back every lock and start the item
   again. For a file in HEAD, from HEAD, index and all, since a plain
   restore takes the index, and puts back an edit already added:

       git -C TREE restore --source=HEAD --staged --worktree -- FILE

   For a file you made, out of the index and then away:

       git -C TREE rm -q --cached --ignore-unmatch -- FILE
       rm -f TREE/FILE
4. Commit the item with only its own files, then give back their
   locks:

       git -C TREE add NEWFILES
       git -C TREE commit -m 'ITEM J.k' -- FILES

   git refuses an add or a commit at once while another is running;
   try again. FILES names every path the item touched: one it deleted,
   and both the old and the new path of one it renamed.
5. Mark it: take the lock, done I COMMIT, give it back. Commit first,
   then mark, so the plan file never says done for what is not in the
   tree. An item you cannot build, put back what you changed as in 3,
   give back its locks, and mark it blocked I and why.
6. Claim again. When no line is free, say

       REPORT
       what you built and what you ran

   and hear. The plan file is the record of the build; the REPORT is
   what you have to say about it.

**Check.** Sit the moot again, steps 1 to 6, on the same DIR, on the
tree as it now stands. In step 1, read the plan file, bring your clone
to TREE's HEAD and run every standing item's CHECK there, read every
commit since BASE, and say what you found. Every seat checks every
item, so no item is checked only by the seat that built it. A DELTA
here is a claim about the tree: an item not done, or done and
breaking something, with the command that shows it.

**Return** the plan with its counts; every item built, with its commit;
every item blocked or not built, and why; every DELTA the check
argued, with its count; and where you stand.

### Facts

- A lock is a directory. Of any number of seats asking for one path at
  once, one gets it and the rest are refused at once. Read, Edit and
  Write know nothing of it. It keeps out only seats that take it, and
  every seat of a build moot takes it, because this says to.
- The plan file lock guards the status, not the work: it is held for
  one change of one line, never while building. A file lock guards the
  work, not the status: it is taken before the first edit of a file
  and held to the commit of its item.
- Which seat builds which item is decided by who marked it first. That
  favors no item and no outcome: every item that stood is built by
  someone, and the check is every seat's.
- The plan file sits in DIR and goes with remove. Anyone can read it
  at any time, the parent included, to see where the build is.
- A seat that stops holding a lock leaves it. `ICCLOCK/list` shows
  that there is one, by its hash only, not which path it is on; the
  parent's sweep before remove takes it away. The moot is over then
  anyway, as it is when any seat stops.
- In the build round the tree moves. What a seat runs then runs in its
  own clone at TREE's HEAD, with the committed items in it and nobody's
  uncommitted edits but its own. The check runs on a tree that has
  stopped, since hear returns only when every seat has said.
- Every item is its own commit, so every item can be read, run and
  reverted alone. Nothing of the build goes on the wire but REPORTs:
  the tree and the plan file are what comes of the matter, not what is
  said.
- A tie builds nothing. So does a DELTA that says two items conflict,
  when it stands. The tree reaches BASE for them, and the return says
  which.
- Nobody writes the tree before the build round and nothing ever runs
  in it, so a seat that investigates finds only BASE there and nothing
  another seat has not said.


## Part 3. Where this departs from what the moot voted, and why

The moot voted 3-0 that every seat builds the whole matter in a private
clone, with no plan vote, and each tree voted whole. This draft keeps
several of its findings:

- one sitting;
- rotation for arguing;
- a round schedule nobody leaves early;
- TMPDIR and ports.

It departs on three points.

- **One tree, divided by claims, not N trees.** The objections were:
  - an assignment needs every seat to compute it alike;
  - pieces built apart need combining, which is a chair;
  - a lock is advisory.

  A claim is not computed: it is a line marked in one file under one
  lock, once. There is nothing to combine: one tree, file locks while
  editing, a commit an item. And the moot already rests on seats
  keeping to what they agreed; the work dir is advisory too.
- **A plan vote.** The objection was that standing items can
  contradict. Here a contradiction is a DELTA like any other, argued
  and voted, and if it stands neither item is built. The other
  objection, that a voted plan narrows the spread, rested on a line
  CLAUDE.md no longer has: the spread is for finding, and the plan is
  what was found.
- **Checking, not N builds.** The spread goes into the check: every
  seat checks every item, then the check's arguments rotate as the
  moot's always have. Each item is built once and checked N times.

Cost at N seats and K cycles: KN+3 rounds to plan, one to build,
KN+3 to check, every one of them sat. That is 13 at three seats and
one cycle, against the table's KN+4 = 7. Each item is built once,
where the table's design built everything N times and ran each tree
N times.


## Part 4. Settled for now

These were open. Each is settled the simplest way until a sitting
shows otherwise.

- **Items that turn out not to fit.** Two standing items nobody saw
  conflict: the one committed first is in, the second is marked
  blocked against it, and the check argues it. That is an order by
  speed, and it is said.
- **Duplicates.** No rule. The second builder finds the change done
  and marks its line done with the first's commit.
- **Rework.** Left out. A DELTA that stands against the tree goes back
  to the parent, who sits the matter again.
- **Tests.** None yet. moot's harnesses prove the wire. Sit a build
  moot by hand once before deciding what a harness of its own would
  prove.
- **Size.** A build round is small: REPORTs only. A round past about
  30KB is still lost from view at the seat that hears it, as in any
  moot. The wait before hear is a precondition: see the top of Part 2.
