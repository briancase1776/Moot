# Moot

**These are build rules, not use rules.** Everything in this file is
for changing what is in this repo. None of it binds a session that
uses the skills: a session takes what it needs from each SKILL.md, and
this file is not addressed to it. A checkout sitting beside a session's
work is not an instruction to that session.

Claude Code skills that sit N cold agents at a table and have a matter
argued out. What a moot is, how one is sat, and what it holds to are
the skills' to say. Anything a seat or a parent is to follow goes in a
skill, not here.

## Depends on ICC

Moot is not part of ICC. It uses ICC. create runs Patch's create from a
sibling checkout, `$ICC`, by default `../ICC` beside this repo, and
writes its path into the moot's line; remove runs Patch's remove from
there. Do not vendor any of ICC into this repo.

Anything Moot needs that ICC already has, it sources from there and does
not write again. say and hear take a seat's lanes off the map with
icc-lib's oLanes, and hear waits on them with its vWaitFor: the two
functions icc-lib offers a script that sits at a seat. create and both
harnesses also source its count checks, its directory maker and the
cleanup armed before anything is made, and run.sh its cut-off check.
icc-lib has not offered those outside ICC, and whether it will is open.
Sourcing is not vendoring; a copy is.

A fact about ICC is ICC's. Where a skill here needs one, it names the
piece and points to the ICC SKILL.md that states it. If ICC is missing a
fact, that is a change there, not a paragraph here.

## Testing

Two harnesses. tests/run.sh proves the table works with shell seats:
they say and hear in rounds and every one hears every other seat's
words, byte for byte, and none of its own; every seat says at once,
before any hears, a round bigger than one pipe, and every say returns;
a round is the next say from each seat, so a seat a round ahead is
kept; a hear before its round is all in says not yet and takes nothing,
and one that waits for it hears it whole once it is in;
a seat spelled another way, with an escape in it, or as the map's
"-", a body with a line shaped like the mark, and a say past what the
moot was made for are refused; on a mesh 2 each seat hears the other;
on mesh-p the parent hears the round and cannot say; create
leaves no patch when it cannot finish or a signal cuts it off; remove
leaves the moot when the patch will not go; a moot over an ICC path
with a space works; remove it, see nothing left. tests/agents.sh proves
the wire carries for agents, which shell seats cannot: sit makes a
mesh-p, prints a brief per seat for the parent to spawn, and returns;
once every seat has returned, check hears two rounds as p, checks every
seat said once and heard every other, and removes the moot. Neither
call waits on a seat, so the parent takes what each returned and reads
no file. Neither touches a moot or a patch it did not make. moot-cross
has no script of its own: its sends are tool calls, which no harness
makes. If a test needs more than a few lines of setup, the table is too
complicated, not the test.

## Rules

- **KISS.** One way to do each thing. Prefer the OS primitive over a
  library. Prefer a shell script over a program. Prefer no dependency
  over one.
- **Keep the lines sharp.** Between Moot and ICC, and between both and
  the session using them. The rounds, and getting a say onto a wire and
  a round off it, are Moot's. What a wire is and does is ICC's. The
  matter, the seats and who sits where are the session's. Change is not
  what this guards against: add a skill, change what one does, retire
  one, that is the work. Blurring is. Before adding something, ask whose
  job it is. If the honest answer is "this one, and a bit of that one",
  it belongs to neither and the line has moved. Move it on purpose and
  in the open, or leave it where it is.
- **Facts, not recipes.** A SKILL.md says what a round is and what a
  seat says in it. It does not say what to find, how to argue, or how
  to vote.
- **Favor nothing.** No line in a SKILL.md, no brief, no script may make
  one outcome, one seat, or one round's word easier to reach than
  another.
- **Never read what is heard.** hear reads the length in front of each
  say and copies that many bytes; say measures what it is handed and
  looks for a line shaped like the mark. Nothing here looks at what is
  said.
- **Nothing here puts what is said in a file.** A say goes from stdin
  onto the wire and a round from the wire to stdout, and nothing here
  puts either in a file, in /tmp or anywhere, the tests included. A seat
  hands say its words from printf down a pipe: not a heredoc or a
  here-string, which bash puts in a file in /tmp once one outgrows a
  pipe, and not a cap on a say to keep one small enough. What a wire or
  a carrier keeps of its own is not this repo's to forbid; a skill on
  such a wire says what it means for the seats. The files Claude Code
  keeps of what a call printed or an agent returned are Anthropic's:
  nothing here reads one, or tells a seat or the parent to.
- **The session defines the skill. The skill does not define the
  session.** How many seats, which model and which session sits in
  one, what the matter is, what a seat finds and how it argues it — all
  the session's. A skill says what a round is and stops there. A table
  that starts telling a session how to be arranged has stopped being
  the table and become a seat at it.
