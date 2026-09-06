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
The moot returns what survived. Patch made the wire and the map; Frames
carries what a seat says; see their SKILL.md. The moot adds the rounds
and nothing else.

    /tmp/moot-XXXXXXXX/moot        SHAPE N PATCH, then Patch's and Frames' scripts
    /tmp/moot-XXXXXXXX/SEAT/       what SEAT has heard and not yet read, as it came
    /tmp/moot-XXXXXXXX/SEAT/.next  a read cut inside a payload, if one was; see Facts

## Operations

    scripts/create SHAPE N [LANES]  patch a mesh over N seats, LANES lanes
                                    each (even, default 2), print the
                                    moot's directory
    scripts/say DIR SEAT < text     put text on the wire as SEAT, once
    scripts/hear DIR SEAT           print the round: everything every seat
                                    said, SEAT's own included, once all N
                                    are in
    scripts/remove DIR              remove the patch, then DIR

SHAPE is mesh or mesh-p, as Patch says. N is 2 or more. On mesh-p the
parent holds seat p: it hears every round and says nothing.

## Sitting a moot

The parent does this.

    d=$(scripts/create mesh 3)

Spawn N agents at once, one per seat 0 to N-1, each with the same brief
but for its seat number:

    You are seat I of the moot at DIR. Read SKILL.md at PATH and do what
    a seat does. The matter: ...

At once, in the background: a round waits for every seat, so a parent
that spawns one seat and waits on it before spawning the next waits on
a round the first cannot finish alone. The brief carries the matter and
nothing about it: not what the parent expects, not what any seat should
find, not who sits where. On mesh-p, hear every round as p. There are
two rounds if no seat said a DELTA in round 2 and N+2 if one did, and p
learns which the way the seats do, by reading round 2. When the seats
return, read what they returned, then remove DIR.

## At a seat

Every seat does the same thing. A round is one say, then one hear. hear
returns when every seat has said, so nothing is heard before it is said.

1. Investigate the matter alone. say

       REPORT
       what you found

   hear.

2. Read every report. say the discrepancies you see, zero or more, each
   a claim that some reports hold and others do not, numbered I.k with k
   from 1, then where you stand having read them all:

       DELTA I.1 the claim
       DELTA I.2 another
       REPORT
       where you stand

   hear. If no seat said a DELTA, return your REPORT and stop.

3. Rotate. In rotation m, for m from 1 to N-1, hold the position seat
   I-m (mod N) took in round 2 and argue it on every DELTA said, as well
   as it can be argued, with whatever you have found since. say

       REPORT
       the case for it

   hear. After N-1 rotations every seat has argued every position.

4. Vote. For every DELTA said, yes or no on its claim:

       VOTE J.k yes

   hear. Count. A claim with more yes than no stands; more no than yes,
   it falls; a tie is a tie.

5. Return every DELTA with its count, and where you stand now.

## Facts

- What a seat says goes on the wire as one Frames payload with a
  `SEAT I` line in front and a newline at the end. That line is the
  only mark of who said what, as Merge says, and it is what say was
  told: nothing binds a caller to a seat number. Say nothing that
  starts a line with SEAT.
- hear prints the round in the order it reached the seat's end. The
  order means nothing. Through fittings it is the order the says took
  the lock, which is a race; on mesh 2 a seat's own words are put in
  place when its say returns, so two seats can see one round in two
  orders.
- hear counts N payloads and returns. That is why p says nothing on
  mesh-p: a payload from p would count as a seat's, and every round
  after would be one out.
- say returns when what it said is past the fittings and back at its
  own seat; on mesh 2 there are no fittings and it returns at once.
  While what it said fits in what the wire holds, say does not wait on
  anyone; bigger, it waits for the slowest seat to come to say or hear.
  Through fittings the wire is three pipes deep, and Pipes says what
  one holds. hear returns when the round is in.
- Give either call the longest timeout you have. A hear cut off waiting
  leaves nothing behind; call it again. A call cut off inside a payload
  leaves DIR/SEAT/.next, the seat is out of step with the round, and say
  and hear refuse from then on and say so. A say cut off may also have
  left part of a payload on the wire, which every seat then waits for.
  Frames says what is lost. Nothing here recovers either; remove the
  moot.
- A seat that has not said cannot hear: the round is one short. A seat
  that neither says nor hears stalls the others once its end fills, as
  Patch says, and frees them the moment it does either. On mesh-p that
  includes p.
- Nothing here reads what is heard. say compares what came back with
  what it put on the wire, byte for byte, to know its own are past the
  fittings; that is all. A REPORT, a DELTA or a VOTE is what the seats
  agree to say, and the seats read them.
- Every seat gets the same brief, every position gets every seat, the
  vote is yes or no with no tiebreak, and the parent says nothing. That
  is all the moot does about fairness. The rest is the seats'.

## In Claude Code

Every Bash call is a fresh shell. The patch is its own processes, as
Patch says, so a moot outlives calls. Seats are agents the parent
spawns; they share its container and its /tmp. A moot does not cross a
session.
