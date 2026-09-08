# Moot

Sit N cold agents around a table and have a matter argued out.

Each agent investigates alone and reports. They read each other's reports
and say where they differ. Then every seat takes up the position of the
seat to its left and argues it, one rotation at a time, until every seat
has argued every position. What is still in dispute goes to a vote. The
moot returns what survived.

It is a Claude Code skill. The agents talk over real pipes, made by
[ICC](https://github.com/briancase1776/ICC).

## What is different about it

**No chair.** No seat runs the moot, none speaks first by right, and the
parent that started it does not steer. There is no moderator, no
summariser, no judge, no tiebreak. Most tools that run several agents put
one in charge to synthesise what the others found. This one refuses, on
purpose, because that seat's opinion would decide the outcome.

**Every seat argues every position.** Not its own — everyone else's, in
turn. A seat made to argue somebody else's case goes and looks where it
would not have looked, which is where most of the good findings come
from.

**A real wire.** The seats are connected by pipes with an ordering
guarantee, not by a loop passing strings around. Every seat hears every
other seat's words, byte for byte, in rounds, and nothing is heard before
everything in that round has been said.

**The spread is the product.** Cold seats of the same model, on the same
brief, go at a matter from different sides and come back with mostly
different things. N seats find more than one does and dig further into
what they find. Nothing here narrows that: no fuller brief for one seat,
no shared plan, no house style for a report.

## What it found

The issues on this repo are the output of one sitting: three seats, six
rounds, forty-one claims, argued over this project's own scripts.

Eight were defects in the table itself,
[#15](https://github.com/briancase1776/Moot/issues/15) through
[#22](https://github.com/briancase1776/Moot/issues/22). The worst of them:
`hear` would return a complete-looking round that nobody had said — exit
zero, no error, nothing left behind to show it — and the one-line fix all
three seats first agreed on was then proved insufficient by one of them.
Another let a seat spelled a slightly different way write into the merge
with the lock off. All eight are fixed.

Four are questions about the rules of order that the sitting could not
settle itself,
[#23](https://github.com/briancase1776/Moot/issues/23) through
[#26](https://github.com/briancase1776/Moot/issues/26): whether a
discrepancy raised too late to be argued may be voted on, whether a moot
may end early, whether the ballot is well formed, and what the scripts
actually hold.

One was not this project's at all, and the seats said so:
[ICC-Frames#1](https://github.com/briancase1776/ICC-Frames/issues/1).

What that evidence is worth: one sitting, one small codebase, and seats
auditing the thing they were sitting on — which gave them unusually good
access to whether they were right.

## What it costs

A moot is expensive. Read this before choosing N.

A sitting is N+3 rounds, and N more for every cycle the parent buys past
the first. Every round is a full turn for every seat, so one cycle is
N×(N+3) agent turns — 18 at three seats, 1,720 at forty. Expect
minutes per round rather than seconds; the wire is fast and the thinking
is not.

The work grows steeply. A round moves N² payloads, because every seat's
words reach every seat. Worse, the number of discrepancies grows with the
seats too, and every rotation asks every seat to argue **all** of them —
so the total argument volume grows roughly as N³.

Three seats is a sitting you can afford to run regularly. Forty is not a
bigger version of the same thing. The plumbing will carry it; the bill and
the wall clock will not.

## Using it

Needs the ICC checkouts beside this one — see
[ICC](https://github.com/briancase1776/ICC). Then read
`.claude/skills/moot/SKILL.md`, which says what a round is and what a seat
says in it.

    tests/run.sh        prove the table works; shell seats, no agents, no cost

## What it does not do

It does not read what the seats say. It carries their words and holds the
turn; what they find, what they conclude and what to do about it are
theirs and yours.

It corrects a seat, not a model. Seats of one model share blind spots, and
what they all miss alike, the moot will miss too. Sitting the same matter
again turns up what one sitting did not.

Its fairness is part mechanism and part discipline. The wire makes every
seat hear the same words in the same rounds. It cannot stop a parent
having a quiet word with one seat outside the moot, and nothing here can
check that. After the brief, the parent says nothing to a seat.

The vote is what survived the argument you could afford, not what is true.

## Licence

MIT. See LICENCE.TXT.
