---
name: moot
description: >-
  Sit N cold agents on an icc-patch mesh and have a matter argued out:
  each reports alone, they say where the reports differ, every seat
  argues every position in turn, and what is still in dispute goes to
  a vote. Returns what survived. Favors nothing: not the parent's view,
  not the first report, not any seat.
---

# moot

A moot is N seats on a mesh that icc-patch made, a cold agent in each,
and a matter. Every seat investigates alone and reports. The seats say
where the reports differ. Every position is then argued from every
seat, one rotation at a time. What is still in dispute goes to a vote.
The moot returns what survived. Patch made the wire and the map; see its
SKILL.md. What a seat says goes down it as its length and its words. The
moot adds the rounds and nothing else. say and hear are skills of their
own, moot-say and moot-hear, beside this one: their SKILL.md say how
each is called, and a seat reads all three.

    /tmp/moot-XXXXXXXX/moot           SHAPE N PATCH BYTES, Patch's scripts
    /tmp/moot-XXXXXXXX/work.XXXXXXXX  a seat's own; it makes it and it takes it away

## Operations

    scripts/create SHAPE N [BYTES]  patch a mesh over N seats, every read
                                    end deep enough to hold a say of
                                    BYTES (default 524288) from each seat
                                    that writes into it, print the moot's
                                    directory
    scripts/remove DIR              remove the patch, then DIR

    ../moot-say/scripts/say DIR SEAT    put what is on stdin on the wire
                                        as SEAT, once; see moot-say
    ../moot-hear/scripts/hear DIR SEAT  print the round at SEAT, or not
                                        yet; see moot-hear

SHAPE is mesh or mesh-p, as Patch says. N is 2 or more. On mesh-p the
parent holds seat p: it hears every round and says nothing, and say
refuses it, since p writes nowhere.

BYTES is the most one say may be, its mark and its last newline
counted; say refuses more. The default is about what a model's longest
answer comes to. That is counted in tokens, and a token is no fixed
number of bytes, so the default is a guess, and generous on purpose.
The wire for it is big: at the default, three seats and p are about 150
processes, most of them Patch's pipes and tees. A mesh 2 is one pipe,
which nothing deepens, so there a say is at most 65472 bytes, whatever
BYTES is.

create runs Patch's create from `$ICC`, by default `../ICC` beside this
repo, and writes its path into DIR/moot; remove takes it from there.
Patch finds Pipes, Tee and Merge itself, as its SKILL.md says. create
also sources icc-lib from there, for its count checks and its cleanup,
so ICC has to be whole.

## Sitting a moot

The parent does this.

    d=$(scripts/create mesh 3)

Spawn N agents at once, one per seat 0 to N-1, each with the same brief
but for its seat number:

    You are seat I of the moot at DIR. Read SKILL.md at PATH, and the
    SKILL.md of moot-say and moot-hear beside it, and do what a seat
    does. Cycles: K. The matter: ...

At once, in the background: a round waits for every seat, so a parent
that spawns one seat and waits on it before spawning the next waits on
a round the first cannot finish alone. The brief carries the matter and
nothing about it: not what the parent expects, not what any seat should
find, not who sits where. Cycles is how many times the table rotates,
1 if the brief says none. A cycle argues the DELTAs said going into
it; a DELTA that comes out of one is argued only if there is another,
and is not voted otherwise. Set it before spawning and leave it: a
parent that bought a cycle after hearing what came up would be
steering. On mesh-p, hear every round as p. There are two rounds if no
seat said a DELTA in round 2 and at most KN+3 if one did, fewer when a
rotation finds the seats agree, and p learns which the way the seats
do, by reading round 2 and each rotation. When the seats return, read
what they returned, then remove DIR.

## At a seat

Every seat does the same thing. A round is one say, then one hear, each
called as its skill says. hear returns when every other seat has said;
if it says not yet, nothing taken, call it again, as moot-hear says,
until it prints the round.

Before the first round, make yourself somewhere to work, and print it:

    mktemp -d DIR/work.XXXXXXXX

Every file you write while you sit goes under it and nothing else does:
a script you wrote to look into the matter, something you fetched, a
note to yourself. The name has a hash in it so that no two seats can
choose the same one, which is the whole of why it is made this way; see
In Claude Code for what happens when two do. Every Bash call is a fresh
shell, so carry the path and name it in full in each one. Nothing you
say goes through it: a say is piped from printf and a round is what
hear printed, as moot-say and moot-hear say.

However you leave the table, after the vote, after a round that ended
it, or because you are giving up, take it away last: remove what you
put in it, then rmdir it. rmdir and not rm -r, so that anything still
in there refuses, and you look at what you left rather than delete it.
It sits inside DIR, so a seat that dies before it gets that far leaves
it to the parent's remove; that is the sweep, not the plan.

1. Investigate the matter alone. say

       printf '%s\n' 'REPORT
       what you found' | ../moot-say/scripts/say DIR I

   hear. Every say below is that same call, with what is written between
   the quotes.

2. Read every report. say the discrepancies you see, zero or more, each
   a claim that some reports hold and others do not, numbered I.k with k
   from 1, then where you stand having read them all:

       DELTA I.1 the claim
       DELTA I.2 another
       REPORT
       where you stand

   hear. If no seat said a DELTA, return your REPORT and stop.

3. Rotate. In rotation m, for m from 1 to N-1, hold the position seat
   I-m (mod N) took in the round before this cycle began, round 2 or a
   step 4, and argue it on every DELTA said, as well as it can be
   argued, with whatever you have found since. If you already know your
   yes or no on every DELTA, say that too; it counts in this round
   only. say

       REPORT
       the case for it
       VOTE J.k yes

   hear. If every seat said a VOTE on every DELTA and no DELTA got both
   a yes and a no, the seats agree: go to 6. After N-1 rotations every
   seat has argued every position: one cycle.

4. Read what was argued. say the discrepancies you now see that no
   DELTA has said, zero or more, numbered on from your last, then where
   you stand having heard it all:

       DELTA I.3 the claim
       REPORT
       where you stand

   hear. If a seat said a DELTA and fewer cycles have run than the
   brief allows, go to 3. Otherwise a DELTA first said here has been
   argued from no position, and is not voted.

5. Vote. For every DELTA a cycle argued, yes or no on its claim. say

       VOTE J.k yes

   hear. Count. A claim with more yes than no stands; more no than yes,
   it falls; a tie is a tie.

6. Return every DELTA a cycle argued with its count, every DELTA none
   did marked so and without one, and where you stand now.

## Facts

- A say cut off inside its write, or a hear cut off while it reads,
  leaves the wire out of step, as moot-say and moot-hear say. Past that
  the moot is over: remove it, and sit it again.
- Nothing here reads what is said. A REPORT, a DELTA or a VOTE is what
  the seats agree to say, and the seats read them.
- Every seat gets the same brief, every position gets every seat,
  nothing is voted that every seat has not argued, the vote is yes or
  no with no tiebreak, and the parent says nothing. That is all the
  moot does about fairness. The rest is the seats'.

## In Claude Code

Every Bash call is a fresh shell, so a say is one call and a hear is
one call, as their skills say. Neither goes through a file of the
moot's. A report composed with an editing tool is a report another seat
can read before it was said, and a round written to a file is the moot
kept somewhere the moot is not.

And it will be the same file. The seats are N agents of one model on one
brief in one container: they go at a matter from different sides, which
is the point of them, but on an incidental like where to put a scratch
file they land on the same obvious name in the same /tmp. Then one
seat's report is written over another's, and a seat says words it did
not write under its own SEAT mark. Nothing here catches it: say puts on
the wire what it is handed, and that is what it was handed. The words
are another seat's, the mark is this one's, and the vote counts them.
That is why a seat's files go in a directory mktemp named: two seats
agreeing where to work is the one agreement the table cannot have.

What a call printed is what the call returned, and nothing else. The
files Claude Code keeps of what calls print, and of what agents return,
are Anthropic's: no seat and no parent reads one, whatever a call or a
notice says.

The patch is its own processes, as Patch says, so a moot outlives calls.
Seats are agents the parent spawns; they share its container and its
/tmp. A moot does not cross a session.
