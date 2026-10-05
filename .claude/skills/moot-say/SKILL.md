---
name: moot-say
description: >-
  Put what is on stdin on a moot's wire as one seat, once: its length, a
  SEAT mark and the words, with one dd that does not pause. Piped from
  printf in the same call, never a heredoc or a file.
---

# moot-say

    scripts/say DIR SEAT  put what is on stdin on the wire as SEAT, once;
                          pipe it the words from printf in the same call,
                          never a heredoc or a file

DIR is a moot's directory, as moot's create printed it. SEAT is the seat
as the map spells it. On mesh-p say refuses p, which writes nowhere, as
Patch says.

## Calling it

With the longest timeout a call may have, as moot-hear says. What
happens to a say whose call reaches its timeout depends on the Claude
Code version. Some cut it off: before its write it has put nothing on,
and inside its write it has put part of a say on, as Facts says. Others
move it to the background, where it goes on, and its words land. Never
say again for one that went to the background: that is a second say,
and every round after it is one out.

## Facts

- What a seat says goes on the wire as a line with its length in bytes,
  then a `SEAT I` line, the words, and a newline at the end, put on by
  one dd, page after page, without a pause. The `SEAT I` line is the
  only mark of who said what that hear prints: hear prints no PEERS,
  and on p's read end nothing says which seat a byte came from, as
  Patch says of a read end with more than one PEER. It is what say was
  told: nothing binds a caller to a seat number. Say nothing that
  starts a line with SEAT; say refuses a body holding a line of that
  shape, SEAT and one word alone, because a reader would take it for the
  mark and the words under it would speak, and vote, as another seat.
- Give say what you have to say on stdin, piped from printf in the same
  call, the words one argument in single quotes:
  `printf '%s\n' 'the words' | scripts/say DIR I`. printf is the
  shell's own, so the words go from the call into the pipe and nowhere
  else, however long they are. Single quotes, so the words go down the
  wire as they were written: in double quotes or none, the shell expands
  a `$name` or a backtick in them, and a report with code in it arrives
  as something the seat did not say. In single quotes nothing is special
  but the quote itself, so write every `'` in the words as `'\''`. A `'`
  left as it is ends the quote there: the rest of the words go to the
  shell as commands to run, or come apart into pieces that printf prints
  a line each, and nothing catches that. Not a heredoc and not a
  here-string: bash puts either in a file in /tmp once it is bigger than
  a pipe, and every one before bash 5.1. Not a file of your own either:
  that is two calls for one say. The seats share a /tmp, so what a seat
  has not said yet would be sitting there to be read by a seat that has
  not heard it.
- say takes no turn and waits for nothing of its own. Every seat can say
  at once, and each say reaches every other seat on a cable of its own,
  as Patch says of a mesh. On a mesh-p every seat's says also reach p's
  merge. Merge says it takes a writer's bytes whole while that writer
  does not let its inlet go empty, and what writes into p's merge is
  each seat's tee, as Patch says; whether a tee fed by say's dd keeps
  its inlet from going empty for a whole say, ICC does not yet say.
  Until it does, p's hear can find a say mixed with another, and nothing
  says so; a seat or p far enough behind that its cable fills makes that
  likelier. At the moot's default BYTES a model's says come nowhere near
  filling one. say returns when the wire has taken them. A seat's read
  end holds a say of BYTES from its seat, and p's a round of them, so a
  say waits on no seat while every seat has heard the round before it;
  one made while a seat is still behind waits for that seat to hear, and
  so does every say after it.
- BYTES is what the moot was made for: the most one say may be, its mark
  and its last newline counted. Past it, say refuses and nothing goes
  on: a round that will not fit is a moot to be sat again, made for
  more.
- A seat that says twice has said its next round's too: every other
  seat hears its second say a round early, and p's rounds from then on
  are one out.
- A say cut off inside its write leaves part of a say on the wire: every
  other seat's next hear waits for the rest, and takes the start of that
  seat's next say for it, so what it prints is wrong and nothing says
  so. A say cut off before its write leaves nothing.
- say measures what it is handed and looks for a line shaped like the
  mark. That is all it reads.

## In Claude Code

Every Bash call is a fresh shell, so a say is one call with its printf
in it. It goes through no file. Words composed with an editing tool are
words another seat can read before they were said.
