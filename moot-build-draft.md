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

moot-build is a working name. Part 1 is the change to CLAUDE.md. Part 2
is the add-on's SKILL.md. Part 3 is where this departs from what the
moot voted, and why. Part 4 is what is still open.


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
parent's. Remove DIR with MOOT/scripts/remove.

### At a seat

Make your work dir as in any moot. Nothing you write goes in the tree
until the build round. Set TMPDIR to your work dir in every call that
builds or runs anything, and bind nothing to a fixed port.

**Plan.** Sit the moot, steps 1 to 5, with three changes.

- In step 2, say beside your DELTAs the changes you would build,
  numbered on in the same count, each one change and the command that
  shows it is done:

      ITEM I.3 the change
      CHECK the command

- There is always an ITEM to vote, so step 2 does not end the moot.
  Every ITEM is voted, even one no seat disputes, and is argued like a
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
lock, one read, one line changed, one write, one remove:

    ICCLOCK/create DIR/plan
    ... read it, change your line, write it ...
    ICCLOCK/remove DIR/plan

Refused, try again. Read the plan file whenever you like; change it
only holding its lock.

The plan file is one line an item that stood, in number order:

    J.k free
    J.k claimed I
    J.k done I COMMIT
    J.k blocked I why

1. The first seat to take the lock after the vote finds no plan file
   and writes it, every standing item free. Every other seat, taking
   the lock in turn, compares it with the items it counted, and says
   any difference in its REPORT this round.
2. Claim: take the lock, mark the first free line claimed I, give the
   lock back. Hold one unbuilt item at a time.
3. Build: lock each file in the tree before you touch it, absolute
   path, and hold it until the item is committed. A file you are
   refused, you wait for; refused one while holding others, give back
   the ones you hold and start again, as Lock says.
4. Commit the item with only its own files, then give back their
   locks:

       git -C TREE add NEWFILES
       git -C TREE commit -m 'ITEM J.k' -- FILES

   git refuses a second commit at once while one is running; try again.
5. Mark it: take the lock, done I COMMIT, give it back. Commit first,
   then mark, so the plan file never says done for what is not in the
   tree. An item you cannot build, mark blocked I and why.
6. Claim again. When no line is free, say

       REPORT
       what you built and what you ran

   and hear. The plan file is the record of the build; the REPORT is
   what you have to say about it.

**Check.** Sit the moot again, steps 1 to 6, on the same DIR, on the
tree as it now stands. In step 1, read the plan file, run every
standing item's CHECK, read every commit since BASE, and say what you
found. Every seat checks every item, so no item is checked only by the
seat that built it. A DELTA here is a claim about the tree: an item
not done, or done and breaking something, with the command that shows
it.

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
  work, not the status: it is held from the first edit of a file to
  the commit of its item.
- Which seat builds which item is decided by who marked it first. That
  favors no item and no outcome: every item that stood is built by
  someone, and the check is every seat's.
- The plan file sits in DIR and goes with remove. Anyone can read it
  at any time, the parent included, to see where the build is.
- A seat that stops holding a lock leaves it; `ICCLOCK/list` shows it.
  The moot is over then anyway, as it is when any seat stops.
- In the build round the tree moves: what a seat runs then runs on a
  tree other seats are editing. The check runs on a tree that has
  stopped, since hear returns only when every seat has said.
- Every item is its own commit, so every item can be read, run and
  reverted alone. Nothing of the build goes on the wire but REPORTs:
  the tree and the plan file are what comes of the matter, not what is
  said.
- A tie builds nothing. So does a DELTA that says two items conflict,
  when it stands. The tree reaches BASE for them, and the return says
  which.
- Nobody writes the tree before the build round, so a seat that
  investigates finds only BASE there and nothing another seat has not
  said.


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

Cost at N seats and K cycles: at most KN+3 rounds to plan, one to
build, at most KN+3 to check. That is 13 at three seats and one cycle,
against the table's KN+4 = 7. Each item is built once, where the
table's design built everything N times and ran each tree N times.


## Part 4. Open

- **Name.** moot-build is a working name.
- **Order.** Where one item needs another built first, the draft has
  no rule; a builder that finds it waits for that item's commit, and
  two items that need each other are both blocked. An AFTER J.k on
  the ITEM line would say it, at the cost of one more thing to read.
- **Items that turn out not to fit.** Two standing items nobody saw
  conflict: the one committed first is in, and the second is blocked
  against it. That is an order by speed. It is said, and the check
  argues it, but nothing undoes the first.
- **Duplicates.** Two items for one change: the second builder finds it
  done and marks its line done with the first's commit, or blocked. No
  rule needed, but the check may call it.
- **Rework.** A DELTA that stands against the tree goes back to the
  parent. A build round after the check, the items the check condemned
  going back to their builders, is the obvious next piece. It is left
  out for now: the parent can sit it again.
- **Tests.** moot's harnesses prove the wire. What moot-build adds is
  rules for seats and the plan file under a lock; whether it needs a
  harness of its own, and what one would prove, is not settled.
- **Size and time.** A build round is small: REPORTs only. The
  timeout is being worked on elsewhere. A round past about 30KB is
  still lost from view at the seat that hears it, here as in any moot.
