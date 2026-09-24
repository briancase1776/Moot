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

    /tmp/moot-XXXXXXXX/moot           SHAPE N PATCH, then Patch's and Frames' scripts
    /tmp/moot-XXXXXXXX/SEAT/          what SEAT has heard and not yet read, as it came
    /tmp/moot-XXXXXXXX/SEAT/.next     a read cut inside a payload, if one was; see Facts
    /tmp/moot-XXXXXXXX/work.XXXXXXXX  a seat's own; it makes it and it takes it away

## Operations

    scripts/create SHAPE N [LANES]  patch a mesh over N seats, LANES lanes
                                    each (even, default 2), print the
                                    moot's directory
    scripts/say DIR SEAT            put what is on stdin on the wire as
                                    SEAT, once; give it a quoted heredoc
                                    in the same call, never a file
    scripts/hear DIR SEAT           print the round: everything every seat
                                    said, SEAT's own included, once all N
                                    are in
    scripts/remove DIR              remove the patch, then DIR

SHAPE is mesh or mesh-p, as Patch says. N is 2 or more, and no more
than Claude Code runs subagents at once, since a round waits for every
seat: `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS`, 20 when it is unset.
create refuses anything else. On mesh-p the parent holds seat p: it
hears every round and says nothing.

create runs Patch's create and finds Frames' scripts in `$ICC`, by
default `../ICC` beside this repo, and writes both paths into
DIR/moot; say, hear and remove take them from there. Patch finds
Pipes, Tee and Merge itself, as its SKILL.md says.

## Sitting a moot

The parent does this.

    d=$(scripts/create mesh 3)

Spawn N agents at once, one per seat 0 to N-1, each with the same brief
but for its seat number:

    You are seat I of the moot at DIR. Read SKILL.md at PATH and do what
    a seat does. Cycles: K. The matter: ...

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

Every seat does the same thing. A round is one say, then one hear. hear
returns when every seat has said, so nothing is heard before it is said.

Before the first round, make yourself somewhere to work, and print it:

    mktemp -d DIR/work.XXXXXXXX

Every file you write while you sit goes under it and nothing else does:
a script you wrote to look into the matter, something you fetched, a
note to yourself. The name has a hash in it so that no two seats can
choose the same one, which is the whole of why it is made this way; see
In Claude Code for what happens when two do. Every Bash call is a fresh
shell, so carry the path and name it in full in each one. Nothing you
say goes through it: a say is a heredoc and a round is what hear
printed, as the Facts say.

However you leave the table, after the vote, after a round that ended
it, or because you are giving up, take it away last: remove what you
put in it, then rmdir it. rmdir and not rm -r, so that anything still
in there refuses, and you look at what you left rather than delete it.
It sits inside DIR, so a seat that dies before it gets that far leaves
it to the parent's remove; that is the sweep, not the plan.

1. Investigate the matter alone. say

       scripts/say DIR I <<'MOOT-XXXX'
       REPORT
       what you found
       MOOT-XXXX

   hear. Every say below is that same call, with what is written between
   the markers.

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

- What a seat says goes on the wire as one Frames payload with a
  `SEAT I` line in front and a newline at the end. That line is the
  only mark of who said what, as Merge says, and it is what say was
  told: nothing binds a caller to a seat number. Say nothing that
  starts a line with SEAT; say refuses a body holding a line of that
  shape, SEAT and one word alone, because a reader would take it for
  the mark and the words under it would speak, and vote, as another
  seat.
- Give say what you have to say on stdin, from a heredoc with its
  marker quoted, in the same call. Quoted, so the body goes down the
  wire as it was written: unquoted, the shell expands a `$name` or a
  backtick in it, and a report with code in it arrives as something the
  seat did not say. Put a few characters of your own in the marker, the
  way the work directory has a hash in it, and be sure no line of the
  body is it. A body line equal to the marker ends the heredoc there:
  the say stops at that line, and the rest of the report goes to the
  shell as commands to run. Nothing catches that. say is handed what
  is left after the shell has eaten the rest, and what it is handed is
  a well formed say, so it goes down the wire and the seats read it as
  all you had to say. The seat that trips is the one whose matter is
  this project, because its report quotes the marker this file shows.
  Do not write what you are going to say to a file and redirect the
  file in: that is two calls for one say, and the seats share a /tmp,
  so what a seat has not said yet would be sitting there to be read by
  a seat that has not heard it.
- hear prints the round in the order it reached the seat's end. The
  round is the first N it has; a payload that arrived behind them is
  the next round's and is kept for the next hear. The order means
  nothing. Through fittings it is the order the says took
  the lock, which is a race; on mesh 2 a seat's own words are put in
  place when its say returns, so two seats can see one round in two
  orders.
- hear counts N payloads and returns; it does not know seats. That is
  why p says nothing on mesh-p, and why a seat that says twice puts
  every seat one over: a payload from p, or a second from a seat,
  counts as a seat's, and every round after is one out. On mesh 2 say
  spools what arrives while its write runs, so a peer that says, hears
  and says again inside that instant is heard a round early.
- say returns when what it said is past the fittings and back at its
  own seat; on mesh 2 there are no fittings and it returns when the
  pipe has taken it. Between a say and each seat's read end the wire
  holds one pipe: LANES/2 lanes of what Pipes says a lane holds, less
  what the count line takes. While what it said fits there, say waits
  on no seat's hear; bigger, the tee stalls on the first outlet that
  is full, so say waits for the slowest seat to come to say or hear,
  and so does every say after it. Choose LANES so a round fits; more
  lanes is the only remedy. There is a ceiling as well as a wait, and
  it is Frames': what a seat says is weighed in flight before any of
  it goes, so a say bigger than Frames will hold does not wait, it
  never finishes. Frames says how deep that is. Both bounds move with
  LANES, and LANES is fixed when the patch is made: a round that will
  not fit is a moot to be sat again, wider. hear returns when the
  round is in.
- A seat that has not said cannot hear: the round is one short. A seat
  that has said and not yet heard stalls the others once its end fills
  the same as one that did neither, as Patch says, and frees them the
  moment it does either. On mesh-p that includes p.
- What hear prints is the round: take it whole in the call that printed
  it. Do not redirect it into a file and read the file back. That is a
  second call, it leaves what the seats said lying in a /tmp they and
  the parent share, and a file read can be cut without saying so, where
  the call that printed it says when it cut it. A round you saw part of
  is a round you have not heard, and hear has taken it off the wire: the
  next hear is the next round's, not that one again. Only a hear cut off
  inside its own print leaves the round to be heard again, because
  nothing is dropped until it has been printed.
- Give either call the longest timeout you have. A hear cut off
  waiting, or a say cut off waiting for the lock, leaves nothing
  behind; call it again. A say that fails or is cut off with the lock
  leaves it held and says so;
  cut inside its write, it leaves part of a payload on the wire, which
  cuts every seat's next hear inside it. A call cut off inside a read
  leaves DIR/SEAT/.next, and say and hear at that seat refuse from
  then on and say so. Past the lock the moot is over: remove it.
  Frames says what is lost.
- Nothing here reads what is heard. say compares what came back with
  what it put on the wire, byte for byte, to know its own are past the
  fittings; that is all. A REPORT, a DELTA or a VOTE is what the seats
  agree to say, and the seats read them.
- Every seat gets the same brief, every position gets every seat,
  nothing is voted that every seat has not argued, the vote is yes or
  no with no tiebreak, and the parent says nothing. That is all the
  moot does about fairness. The rest is the seats'.

## In Claude Code

Every Bash call is a fresh shell, so a say is one call with its heredoc
in it, and a hear is one call and what it printed there. Neither goes
through a file. A report composed with an editing tool is a report
another seat can read before it was said, and a round written to a file
is the moot kept somewhere the moot is not.

And it will be the same file. The seats are N agents of one model on one
brief in one container: they go at a matter from different sides, which
is the point of them, but on an incidental like where to put a scratch
file they land on the same obvious name in the same /tmp. Then one
seat's report is written over another's, and a seat says words it did
not write under its own SEAT mark. Nothing here catches it: say compares
what came back with what it put on the wire, and that is what it put on
the wire. The words are another seat's, the mark is this one's, and the
vote counts them. That is why a seat's files go in a directory mktemp
named: two seats agreeing where to work is the one agreement the table
cannot have.

The patch is its own processes, as Patch says, so a moot outlives calls.
Seats are agents the parent spawns; they share its container and its
/tmp. A moot does not cross a session.
