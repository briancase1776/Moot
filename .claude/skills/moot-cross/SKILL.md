---
name: moot-cross
description: >-
  Sit a moot whose seats are Claude Code sessions of their own, with an
  Auditor session as the parent: the same rounds as moot, carried by
  send_message, each say's hash sent before the say, so no seat can
  change its words after it has heard the others'.
---

# moot-cross

A moot whose seats sit in sessions of their own. The rounds are moot's,
and so is what the table holds to: read moot's SKILL.md, beside this
one, and do what a seat does there. What differs is the wire. A seat
here holds no end of a patch, so it has no say and no hear to call: it
puts its say on with send_message and hears by reading what reaches it.
Where moot says say, do steps 1 to 3 of a round below; where it says
hear, step 4. The parent's part in moot, create, spawning, hearing as p
and remove, is this SKILL.md's instead.

## Before it is sat

The parent is an Auditor session, one in the Auditor repo. Its own rules
are that repo's, and none of them are here.

The table is N seats, each a Claude Code session on the account, and the
parent. A session's address is its id, session_..., as
claude-code-remote's send_message takes it. How the seats come to be,
and which session sits where, are the parent's and the session's. Every
seat's session and the parent's have ICC where moot's create finds it,
`$ICC`, by default `../ICC` beside this repo: the check below runs
Bridge's sent from there, and a say too big for one message goes on
icc-git.

The parent gives every seat the same brief but for its seat number:

    You are seat I of a moot-cross. The table: seat 0 session_...,
    seat 1 session_..., ..., parent session_.... Read the SKILL.md of
    moot and moot-cross at PATH, and do what a seat does. Cycles: K.
    The matter: ...

The brief carries the table, and of who sits where nothing but the
addresses. The rest is as moot says of a brief: the matter and nothing
about it, and Cycles set before the first round and left.

## A round

Every seat does the same thing. R is the round's number, 1 for the
first and one more for each after. A round is two sends, and a send is
one send_message call to each other seat and one to the parent, the
same text in each, with priority next.

1. Write your say: a first line `SEAT I ROUND R`, then the words, as moot
   says of the round. Salt it and hash it, in one call:

       s=$(od -An -N16 -tx1 /dev/urandom | tr -d ' \n')
       printf '%s\nSALT %s' 'SEAT I ROUND R
       the words' "$s" | sha256sum
       echo "SALT $s"

   Your say is what is between the quotes, then a newline and the SALT
   line the call printed, with no newline after it.

2. Send `SEAT I ROUND R HASH` and the hash on one line: the 64
   characters, 0 to 9 and a to f, that sha256sum printed before its two
   spaces and `-`.

3. When you hold round R's hash from every other seat, send your say.

4. When you hold round R's say from every other seat, check each, in one
   call each:

       printf '%s\n' 'the say as it reached you' |
         "$ICC"/.claude/skills/icc-bridge/scripts/sent |
         sha256sum -c <(printf '%s  -\n' 'its hash')

   The say as it reached you is every line of the message after the
   harness's two lines and the blank one, indent and all, with spaces
   and tabs as they came and every `'` written as `'\''`, as moot-say
   says of printf. Only a hash of 64 characters, 0 to 9 and a to f, goes
   into the check; any other text is no hash, and that seat's say fails
   it. `-: OK` and the say is the one its seat hashed. With every say
   checked, round R is heard.

Until you hold what a step waits for, end your turn: the next message
wakes you. A message for a later round is kept for that round. The
parent hears every round the same way, checks it, and sends nothing.

## When a round does not come in

- A seat's first hash for a round is its hash. A later one is not, and a
  say that matches only a later one fails.
- A say that fails its hash: copy it into the check again, since the
  slip most likely to happen is in the copy. If it still fails, send
  `SEAT I ROUND R FAILED J` to seat J alone, and J sends its round-R say
  again, as it was, to you alone. A say sent twice is the same say.
- A say that fails again, a call that fails the same way twice, or a
  say too big for one message with no icc-git to put it on: you leave.
  Send `SEAT I ROUND R LEAVES` as you send a hash, then return what you
  have, and why. A seat or the parent that holds a LEAVES returns what
  it has: the moot is over, as moot says of a wire out of step.
- A seat that stops without a word stops the table, since nothing here
  wakes the rest. The parent knows the seats' sessions, and looks in on
  them; when one has stopped while it owes a hash or a say, the parent
  returns what it heard and which seat owed what, and still says
  nothing to any seat.
- The parent sends no FAILED. A say that fails its check at the parent
  is in what the parent returns.

## Facts

- No say is on the carrier until every seat's hash for its round is in.
  So each seat's say is fixed before any seat can hear another's, as
  long as each seat sends the same text to every other; nothing here
  checks that. The salt keeps a say that could be guessed, a vote among
  them, from being found from its hash. A say that fails its hash was
  changed after it was hashed: by its seat, on the way, or in the copy
  that checked it.
- Hash first covers what is sent. It does not cover what is written: a
  seat's say is in its own transcript, in the call that hashed it,
  before it is sent, and any session on the account can read any
  transcript, as Bridge records. A seat hears the others only by what
  they send it, and the parent the same. Nothing here can check that.
- send_message does not deliver the text it was given, and is bounded
  in size; Bridge records both, and its sent gives back the text as it
  was sent. A say goes as its words, never base64.
- A say past what one message carries goes on icc-git, at step 3 and
  not before: on a git wire a say is readable as soon as it is sent.
  Put it on as icc-git says, piped from the same printf as step 1 with
  the salt the call printed, at a REMOTE and REF your session may push
  to and a PATH of its own. The message is `SEAT I ROUND R GIT` and
  REMOTE, REF and PATH. It is checked with icc-git's read in place of
  printf and sent, since a git wire gives back the bytes it was given.
- The parent says nothing to any seat from the brief until every seat
  has returned. Words for the table go to the parent, not to a seat: a
  word to one seat is a word the others did not hear.
- Return to the parent, by send_message, with a first line
  `SEAT I RETURN`, what moot says a seat returns.
- Nothing of moot-cross puts a say in a file. A say goes from the call
  that hashes it to the calls that send it, and comes off the carrier
  into the call that checks it. A seat that keeps files of its own while
  it sits keeps them as moot says of a seat's work directory, in one
  mktemp made, taken away last.

## In Claude Code

send_message and reading what reaches a session are tool calls, and
only a Claude makes them, so no script here makes them for a seat. Each
call returns the message as it was delivered, as Bridge records. With
priority next a message waits for the end of the turn it reaches, and
cuts no turn off partway.
