# Moot

**These are build rules, not use rules.** Everything in this file is
for changing what is in this repo. None of it binds a session that
uses the skill: a session takes what it needs from SKILL.md, and this
file is not addressed to it. A checkout sitting beside a session's
work is not an instruction to that session.

A Claude Code skill that sits N cold agents on an icc-patch mesh and has
a matter argued out. That is the whole project.

Think of a moot. Seats around a table. Everyone goes off alone, looks
into the matter, and comes back with a report. They read each other's
and say where the reports differ. Then the arguments go round the
table: each seat takes up the position of the seat to its left and
makes the case for it, until every seat has argued every position. What
is still in dispute goes to a vote. This skill is the table and the
rules of order. It has no opinion, and it is nobody's chair.

## Where this sits

    what the seats find and decide     the seats', not this
    the rounds and the rules of order  this project
    plug pipes and fittings into a     icc-patch, below this
    shape, hand out the map
    copies and lanes                   icc-tee, icc-merge, icc-pipes,
                                       below it

Moot is not part of ICC. It uses ICC. It is the first thing that sits at
a seat Patch handed out. Patch says which end a seat holds, and does not
know what a seat says. A say goes down that end as its length and its
words, in one write, and on a mesh-p the merge that p reads takes each
say whole. Moot knows the rounds. It does not read what is said in
them.

## What this is

- A **moot**: a patch Patch made, mesh or mesh-p, N seats, a cold agent
  in each, and one matter. create, say, hear, remove. One script each.
- The **rounds**: report, name the discrepancies, rotate the positions
  round the table until every seat has argued every one, vote on what
  is left. The seats do the rounds. The scripts carry what they say.
- **Favors nothing.** Every seat gets the same brief, every position
  gets every seat, a vote is yes or no with no tiebreak, and on mesh-p
  the parent hears and says nothing.
- **N seats, not one.** The seats are cold and do not coordinate. Seats
  of the same model on the same brief go at a matter from different
  sides and come back with mostly different things: what a seat looks
  at first shapes everything it looks at after. N seats find more than
  one does and dig further into what they find, so a table can turn up
  what a single agent of longer reach, working alone, does not. That
  spread is the product. Nothing here may narrow it: not a fuller
  brief, not a shared plan, not a house style for what a seat says.
  Seats that agree where to look are one seat run N times.
- **A matter is not spent in one moot.** What the spread will not cover
  is what every seat misses alike; a moot corrects a seat, it does not
  correct a model. Sitting the same matter again turns up what one
  sitting did not. That is the parent's to call, and nothing here knows
  there was a first time.

## What this is not

Out of scope. Do not build, stub, or "leave room for" any of these:

- **The wire and the fittings.** Patch, Pipes, Tee, Merge. Moot runs
  Patch's scripts and never copies them. What it puts on the wire of its
  own is a say's length in front of the say, so hear knows where one
  ends, and the SEAT mark line, so the seats know who said it, and
  nothing more. Slicing, spreading and reassembling a payload
  are Frames', and a say needs none of them.
- **The matter, or what comes of it.** What the seats look into, what
  they find, what stands after the vote. Moot returns it and does not
  read it.
- **A chair.** No seat runs the moot, no seat speaks first by right, no
  parent steers. A moderator, a summarizer, a judge, a weight on a vote,
  a tiebreak, a quorum.
- **Other shapes.** A ring means a seat forwards what it heard, and
  forwarding is a seat's business, not the table's. Two shapes. Mesh,
  and mesh with the parent listening.
- **The run.** Divide the work, do it, proofread, moot again. That is
  the parent calling this once or twice, with its own work between.
  Nothing here knows there was a first time.
- **Reading what is said.** Tallying, de-duplicating DELTAs, parsing
  REPORTs, judging a VOTE well formed. The seats agreed on those lines;
  the seats read them.
- **What a wire could do for itself.** Discovery, naming, persistence,
  replay, liveness, retries, timeouts, transports, config, plugins.

If a request touches any of the above, stop and say it is out of scope.
Before adding anything, ask: is this the wire, what goes down it, what
the seats conclude, or the table and its rules of order? Only the last
one belongs here.

## Depends on ICC

create runs Patch's create from a sibling checkout, `$ICC`, by default
`../ICC` beside this repo, and writes its path into the moot's line;
remove runs Patch's remove from there. Patch finds Pipes, Tee and Merge
itself, as its CLAUDE.md says. Do not vendor any of them into this repo.

Anything Moot needs that ICC already has, it sources from there and does
not write again. create and both harnesses source icc-lib for the count
checks and for the cleanup armed before anything is made, and run.sh
takes its cut-off check from it. Sourcing is not vendoring; a copy is.

Do not duplicate their documentation. A fact about a lane is Pipes'; a
copy, Tee's or Merge's; a map, Patch's. If one of them is missing a
fact, that is a change there, not a paragraph here.

## Testing

Two harnesses. tests/run.sh proves the table works with shell seats:
they say and hear in rounds and every one hears every other seat's
words, byte for byte, and none of its own; every seat says at once,
before any hears, a round bigger than one pipe, and every say returns;
a round is the next say from each seat, so a seat a round ahead is
kept; a seat spelled another way, with an escape in it, or as the map's
"-", a body with a line shaped like the mark, and a say past what the
moot was made for are refused; mesh 2 is one pipe and each seat hears
the other; on mesh-p the parent hears the round and cannot say; create
leaves no patch when it cannot finish or a signal cuts it off; remove
leaves the moot when the patch will not go; a moot over an ICC path
with a space works; remove it, see nothing left. tests/agents.sh proves
the wire carries for agents, which shell seats cannot: it sits a
mesh-p, prints a brief per seat for the parent to spawn, hears two
rounds as p, and checks every seat said once and heard every other.
Neither touches a moot or a patch it did not make. If a test needs more
than a few lines of setup, the table is too complicated, not the test.

## Rules

- **KISS.** One way to do each thing. Prefer the OS primitive over a
  library. Prefer a shell script over a program. Prefer no dependency
  over one.
- **Small.** If a file is getting long, you are adding scope, not
  features.
- **No speculative work.** Build what is asked, not what might be asked
  later.
- **No abstraction until there are two real callers.**
- **Facts, not recipes.** SKILL.md says what a round is and what a seat
  says in it. It does not say what to find, how to argue, or how to
  vote.
- **Favor nothing.** No line in SKILL.md, no brief, no script may make
  one outcome, one seat, or one round's word easier to reach than
  another.
- **Never read what is heard.** hear reads the length in front of each
  say and copies that many bytes; say measures what it is handed and
  looks for a line shaped like the mark. Nothing here looks at what is
  said.
- **The session defines the skill. The skill does not define the
  session.** How many seats, which model sits in one, what the matter
  is, what a seat finds and how it argues it — all the session's.
  This file says what a round is and stops there. A table that starts
  telling a session how to be arranged has stopped being the table and
  become a seat at it.

## Layout

```
.claude/skills/moot/SKILL.md      the skill definition Claude Code loads
.claude/skills/moot/scripts/      create, say, hear, remove. One script
                                  each. .seat is what say and hear share.
tests/                            run.sh and agents.sh, described above
```

Do not add directories without a reason that fits the scope above.
