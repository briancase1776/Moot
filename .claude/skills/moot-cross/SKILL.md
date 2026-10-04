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
and which session sits where, are the parent's and the session's.

The parent gives every seat the same brief but for its seat number:

    You are seat I of a moot-cross. The table: seat 0 session_...,
    seat 1 session_..., ..., parent session_.... Read the SKILL.md of
    moot and moot-cross at PATH, and do what a seat does. Cycles: K.
    The matter: ...

The brief carries the table, and of who sits where nothing but the
addresses. The rest is as moot says of a brief: the matter and nothing
about it, and Cycles set before the first round and left.

## A round

Every seat does the same thing, and a round is two sends.

1. Write your say: a first line `SEAT I ROUND R`, then the words, as moot
   says of the round. Hash it, in one call:

       printf '%s\n' 'SEAT I ROUND R
       the words' | sha256sum

2. Send `SEAT I ROUND R HASH` and the hash, on one line, to every other
   seat and to the parent: one send_message call each, the same text in
   each.

3. When you hold round R's hash from every other seat, send your say,
   the same bytes you hashed, to every other seat and to the parent, the
   same way.

4. When you hold round R's say from every other seat, check each against
   its hash, in one call each:

       printf '%s\n' 'the say as it reached you' |
         sed 's/^    //; s/&lt;/</g; s/&gt;/>/g; s/&amp;/\&/g' |
         sha256sum -c <(printf '%s  -\n' 'its hash')

   `-: OK` and the say is the one its seat hashed: that is round R heard.

Until you hold what a step waits for, end your turn: the next message
wakes you. A message for a later round is kept for that round. The
parent hears every round the same way and sends nothing.

## Facts

- No say is on the carrier until every seat's hash for its round is in.
  So every seat's say is fixed before any seat can see another's: a
  seat sees nothing of a round but hashes until its own hash is out,
  and a hash shows nothing of what it hashes. A say that fails its hash
  was changed after it was hashed, by its seat or on the way.
- Hash first covers what is sent. It does not cover what is written: a
  seat's say is in its own transcript, in the call that hashed it,
  before it is sent, and any session on the account can read any
  transcript with list_events. A seat hears the others only by what
  they send it, and the parent the same. Nothing here can check that.
- A say that fails its hash: tell that seat, once, and it sends the same
  say again. A say sent twice is the same say. One that fails again
  ends the moot for you: return what you have, and which say failed.
- send_message does not deliver the text it was given. Bridge, in ICC,
  records what it changes; today, a four-space indent on every line, and
  `<`, `>` and `&` written as `&lt;`, `&gt;` and `&amp;`, once more than
  they were. Copy the say as it reached you, indent and all, into the
  check; the check undoes the rest. Copy it with every `'` written as
  `'\''`, as moot-say says of printf.
- A say too big for one message goes on ICC's git wire, and the message
  carries its place there instead of the words; the git wire's SKILL.md
  says how to put it on and take it off. The hash is the say's either
  way, and a say off the git wire is checked with no sed: it comes off
  as it went on.
- The parent says nothing to any seat from the brief until every seat
  has returned. Words for the table go to the parent, not to a seat: a
  word to one seat is a word the others did not hear.
- Return to the parent, by send_message, what moot says a seat returns.
- Nothing of moot-cross puts a say in a file. A say goes from the call
  that hashes it to the calls that send it, and comes off the carrier
  into the call that checks it. A seat that keeps files of its own while
  it sits keeps them as moot says of a seat's work directory, in one
  mktemp made, taken away last.

## In Claude Code

send_message and reading what reaches a session are tool calls, and
only a Claude makes them, so no script here makes them for a seat. Each
call returns the event it delivered; a call that fails has sent
nothing, and is made again. What a message reaches a session as, and
when, is the carrier's, as Bridge records it.
