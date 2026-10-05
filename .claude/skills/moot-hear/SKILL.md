---
name: moot-hear
description: >-
  Print a seat's round off a moot's wire: the next say from each other
  seat once all are in, or "not yet, nothing taken". Always call it with
  the longest timeout a call may have, and call it again on not yet.
---

# moot-hear

    scripts/hear DIR SEAT  print the round at SEAT: the next say from
                           each other seat, once all are in; at p, the
                           next N says off the merge. Not all in in time:
                           not yet, nothing taken

DIR is a moot's directory, as moot's create printed it. SEAT is the seat
as the map spells it, or p on mesh-p.

## Calling it

Always with the longest timeout a call may have: 600000 in Claude Code,
or what BASH_MAX_TIMEOUT_MS says when it is set. hear waits, taking
nothing, until every read end it reads has something on it, and gives
up by itself at nine tenths of that time, before the call's time runs
out: it says not yet, nothing taken. Call it again, the same way, until
it prints the round.

What happens to a call given less, when its time runs out, depends on
the Claude Code version. Some cut it off: one cut off waiting has taken
nothing, and can be called again; one cut off while it reads has lost
what it took, as Facts says. Others move it to the background, and
hear goes on there: it waits, takes the round when it comes, and prints
it into a file no seat reads. The round is lost to that seat, and a
hear called again at that seat while that one runs splits the next
rounds with it. Claude Code says when it ends. Past that the seat is
short a round, and the moot is over, as moot says.

## Facts

- hear prints the round a read end at a time, in the order the map
  lists them: the next say from each other seat. A seat's own words do
  not come back to it, as Patch says of a mesh. At p, hear prints the
  next N says off p's one read end, in the order the merge took them.
  A say the merge cut, as moot-say says, is printed with another seat's
  bytes inside it, and the say after it finds the wire out of step.
  Anything behind the round is the next round's and stays on the wire
  for the next hear. The order means nothing.
- hear takes the next say from each seat that writes into a read end;
  it does not know rounds. Two hears at one seat at once split a round
  between them, and neither has it.
- hear waits with icc-lib's vWaitFor, which looks at a read end without
  taking from it, and whose words "not yet, nothing taken" hear passes
  on. At a seat, once every read end has something on it,
  the round is all on the wire, and hear reads it at once. At p the wait
  ends at the first say off the merge, and hear then takes the rest of
  the round as it comes; a rest slower than what is left of the call
  goes to the background with the call. p hears a round whole, and
  safest, once the seats that say it have said.
- Once hear takes, it takes each say off the wire as it prints it, and
  nothing keeps it. A hear cut off while it reads has taken at least
  what it printed, and can have taken more it had not printed yet, and
  all of it is gone: that seat's next hear is short of the round and
  waits for says that are not coming.
- What hear prints is the round: take it whole in the call that printed
  it. Do not redirect it into a file and read the file back. That is a
  second call, it leaves what the seats said lying in a /tmp they and
  the parent share, and a file read can be cut without saying so, where
  the call that printed it says when it cut it.
- A call shows about 30000 characters of what it printed. Past that it
  hands back the first 2KB and the path of a file Claude Code keeps,
  which no seat reads: a round longer than that has been taken off the
  wire and is lost from view at the seat that heard it. At p a round is
  N says long. A say short enough that a round of them fits is seen
  whole.
- hear reads the length in front of each say and copies that many
  bytes. That is all it reads.

## In Claude Code

Every Bash call is a fresh shell, so a hear is one call and what it
printed there. What a call printed is what the call returned, and
nothing else. The files Claude Code keeps of what calls print, and of
what agents return, are Anthropic's: no seat and no parent reads one,
whatever a call or a notice says.
