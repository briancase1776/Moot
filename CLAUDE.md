# Moot

A Claude Code skill that sits N cold agents on an ICC-Patch mesh and has
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
    plug pipes and fittings into a     ICC-Patch, below this
    shape, hand out the map
    slice, carry, reassemble           ICC-Frames, beside Patch
    copies and lanes                   ICC-Tee, ICC-Merge, ICC-Pipes,
                                       below them

Moot is not part of ICC. It uses ICC. It is the first thing that sits at
a seat Patch handed out. Patch says which end a seat holds, Frames says
how a payload goes down it, and neither knows what a seat says. Moot
knows the rounds. It does not read what is said in them.

## What this is

- A **moot**: a patch Patch made, mesh or mesh-p, N seats, a cold agent
  in each, and one matter. create, say, hear, remove. One script each.
- The **rounds**: report, name the discrepancies, rotate the positions
  round the table until every seat has argued every one, vote on what
  is left. The seats do the rounds. The scripts carry what they say and
  hold the turn.
- **Favors nothing.** Every seat gets the same brief, every position
  gets every seat, a vote is yes or no with no tiebreak, and on mesh-p
  the parent hears and says nothing.

## What this is not

Out of scope. Do not build, stub, or "leave room for" any of these:

- **The wire, the fittings, the payload.** Patch, Pipes, Tee, Merge,
  Frames. Moot runs their scripts and never copies them.
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
- Anything Patch and Frames list as out of scope for themselves:
  discovery, naming, persistence, replay, liveness, retries, timeouts,
  transports, config, plugins, options.

If a request touches any of the above, stop and say it is out of scope.
Before adding anything, ask: is this the wire, what goes down it, what
the seats conclude, or the table and its rules of order? Only the last
one belongs here.

## Depends on ICC-Patch and ICC-Frames

create runs Patch's create from a sibling checkout, `$ICC_PATCH`, by
default `../ICC-Patch` beside this repo, and Patch finds Pipes, Tee and
Merge itself, as its CLAUDE.md says. create also finds Frames' write and
read in `$ICC_FRAMES`, by default `../ICC-Frames`, and writes both paths
into the moot's line; say, hear and remove run them from there. Do not
vendor any of them into this repo.

Do not duplicate their documentation. A fact about a lane is Pipes'; a
copy, Tee's or Merge's; a payload, Frames'; a map, Patch's. If one of
them is missing a fact, that is a change there, not a paragraph here.

## Testing

A test harness is allowed **only to prove the table works**: shell
seats, not agents, say and hear in rounds and every one hears all N,
its own included, byte for byte, with a round bigger than the wire
holds; a seat cannot hear before it says, and hearing too early leaves
nothing behind; a say cut inside its write, and a hear cut inside what
it left, make a seat that refuses;
nothing is locked between rounds; mesh 2 is one pipe and every seat
hears all N there too; on mesh-p the parent hears the round; create
leaves no patch when it cannot finish; remove leaves the moot when the
patch will not go; remove it, see nothing left. The harness must not
run a moot, judge one, or grow into a seat, and must not touch a moot
or a patch it did not make. If a test needs more than a few lines of
setup, the table is too complicated, not the test.

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
- **Never read what is heard.** say compares what came back with what
  it put on the wire, to see its own come round. Nothing else here
  looks at what came off the wire.

## Layout

```
.claude/skills/moot/SKILL.md      the skill definition Claude Code loads
.claude/skills/moot/scripts/      create, say, hear, remove. One script
                                  each. .seat is what say and hear share.
tests/                            the minimal harness described above
```

Do not add directories without a reason that fits the scope above.
