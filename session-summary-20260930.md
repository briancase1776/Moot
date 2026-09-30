# Session summary: Moot build protocol design, 2026-09-29 to 30

Written for the next session to pick up. Session branch
`claude/tender-babbage-0azwl7` of briancase1776/Moot. It started from
main at `e2bc767`, and main was fast-forwarded to the branch at the end.
The sibling ICC checkout was used at `briancase1776/icc`, with
`ICC=/home/user/briancase1776/icc`.

## What was asked, in order

1. Sit a moot on Moot about a "build" version: investigate, plan, build.
2. Design that protocol with Brian, turn it into a draft, and put the
   draft on the branch.
3. Have the Auditor session review it, and apply the reviews.
4. Make hear wait without taking anything; that became the
   ICC/Moot split of `vWaitFor` and hear.
5. Split say and hear into skills of their own.
6. Sit a moot on this session's changes, and fix what it found.
7. Summarize, put it in the repo, fast-forward main.

## Ground rules Brian set this session

- CLAUDE.md is build rules for the repo, not rules for the skill or the
  session. When a CLAUDE.md line conflicts with what Brian wants built,
  the line goes. Stop citing CLAUDE.md against his design.
- Agents talking to each other is fine ("msg away"). Routines are the
  channel between cloud sessions (see Cross-session messaging below).
- Short phone replies; yes/no questions where possible.

## Commits, oldest first (all on main now)

- `1b49db2` Drop "The run" from What this is not.
- `8fcfc96` Drop "not a shared plan" from what may narrow the spread.
- `a981282` to `e30a976` Add moot-build-draft.md and revise it through
  two Auditor reviews:
  - `12178e2`, `8c4c499`, `a2377ee`, `04e99f3`, `e30a976`
- `b5b660b` hear calls icc-lib's vWaitFor before it reads, and says
  "not yet, nothing taken". run.sh has a not-yet check.
- `a583bd0` Drop "no abstraction until there are two real callers".
- `1b63c0c`, `d99b36c`, `9165546` Drop "Small" and "No speculative
  work". A "small scopes" rule was added and then removed. The net
  result: none of these rules remain. The moot said to squash these
  commits; not done, since it needs a force-push.
- `d2f81e2` say and hear become skills of their own:
  - `.claude/skills/moot-say/` and `.claude/skills/moot-hear/`, each
    with its SKILL.md and script;
  - moot's SKILL.md keeps the rounds and the table;
  - the brief tells a seat to read all three.
- `1542a59` Fixes from the last moot; see below.
- This summary.

## ICC side (the Auditor wrote these)

- `a294aae` vWaitFor in icc-lib: wait until every read end a seat reads
  has data, taking nothing (`read -t 0`), and give up at 9/10 of
  `BASH_MAX_TIMEOUT_MS` (600000 when unset) with "not yet, nothing
  taken". **On ICC main.**
- `59920b6` The moot's lane fixes: open with `<>` so a lane with no
  holder cannot hang; test `-p` before every look; read the limit with
  nCount, so a leading zero is not octal; new lib.sh cases. **On branch
  claude/charming-cray-74az6g, not on ICC main.** ICC lib.sh and Moot
  run.sh both pass against it here.
- Brian noticed the Auditor had not read ICC's CLAUDE.md. vWaitFor
  crosses three ICC rules:
  - "Nothing is configurable": it reads an environment variable.
  - "Keep the lines sharp": a Claude Code call limit is the session's
    business, and the line was not moved in the open in CLAUDE.md.
  - "Functions are welcome", which means shared by ICC pieces: no ICC
    piece calls vWaitFor.
  Moot's CLAUDE.md also puts timeouts out of scope, so neither repo's
  rules want the timeout as written. Brian's call; not resolved.

## The moot-build draft (`moot-build-draft.md`, repo root)

An add-on skill, moot-build. It uses moot, moot-say, moot-hear and
icc-lock, and has no scripts of its own. A build moot runs:

1. **Plan:** a moot with `ITEM J.k` and `CHECK` lines, every item
   voted.
2. **Build:** one round, in one shared tree the parent checks out at a
   pinned BASE.
   - One plan file, `DIR/plan`, has a line per standing item:
     `free`, `claimed I`, `claimed I waits L.m`, `done I COMMIT`,
     `blocked I why`.
   - Every change to it is one Bash call:
     `ICCLOCK/create DIR/plan && { CHANGE; ICCLOCK/remove DIR/plan; }`.
     CHANGE decides under the lock and changes a line only if it
     still says what it expects.
   - A seat locks every tree file it will edit before editing any, and
     commits each item alone with `git commit -- FILES`.
   - Backing off restores from HEAD:
     `git restore --source=HEAD --staged --worktree`.
   - Nothing runs in TREE: each seat runs in its own
     `git clone --shared` under its work dir.
   - Dependencies are read from the plan file (no AFTER tag). The chain
     of waits is walked and marked in one locked CHANGE.
3. **Check:** a moot again on the finished tree. Every seat runs every
   CHECK.

Every round is sat, with no early exits. The parent sweeps leftover
locks before remove.

Open in the draft:
- **What replaces "first committed wins"** for items that turn out to
  conflict. The moot voted 3-0 that it favors the faster seat. Options:
  both blocked, or the first reverted until the check votes between
  them.
- Rework is left to the parent.
- There is no harness until a build moot has been sat by hand.

Brian's design calls that shaped it:
- one shared tree divided by lock claims, not N trees;
- locks everywhere: a lock on the plan file for status, and locks on
  tree files while they are edited;
- one plan file, whose status is the list;
- two skills: moot-build is an add-on, not a rewrite of moot.

## Findings about Claude Code that matter here

- **A Bash call that reaches its timeout depends on the version.**
  - On 2.1.285 (this container) it is moved to the background and keeps
    running. Its output goes to a file, and the call returns only a
    notice with no output.
  - On 2.1.284 (the Auditor's) it was killed, exit 143.
  - Brian's earlier "p resumes after a cut" was right on the older
    behavior.
  - moot-hear's text says backgrounded only. A one-line fix was
    proposed: "cut off or moved to the background, depending on the
    version". Not done.
- **Output limit.**
  - `BASH_MAX_OUTPUT_LENGTH` defaults to 30000 characters, maximum
    150000; settable in the cloud environment's variables.
  - `bashOutputMaxChars` in settings.json, maximum 128000, overrides it.
  - Past the limit: a 2KB preview plus a file seats may not read.
  - Brian: this is an interface mismatch with the wire, since a say may
    be 524288 bytes. Proposed, not done: raise the variable to 150000,
    and have create size the default BYTES to the reader, about the
    limit divided by N, read like vWaitFor reads the timeout.
- `BASH_MAX_TIMEOUT_MS` (default 600000) caps a single Bash call only,
  not session life. The idle-reclaim time is not documented.
- **Cross-session messaging.**
  - SendMessage does not reach between cloud sessions; ListAgents shows
    nothing.
  - What works is a Routine bound to the other session:
    `create_trigger` with `persistent_session_id`, then `fire_trigger`,
    then `update_trigger enabled=false`.
  - A Routine's prompt can only be edited from the session it posts
    into, so make a new one per message.
  - Arrives as a scheduled-trigger notification; read with
    ReadNotifications.
  - Mine are all disabled: `trig_01RszWhtv48uW6V7Cc83dMBD`,
    `trig_01Lb2an34AeLo4QuqrXKNcog`, `trig_01CQ741ZH1QGDJcnFgagvL2a`,
    `trig_015ZyEQsMdiDZ147ZatG3VBr`, `trig_012gjnsMtEsB8UwEEJStab4k`.
  - Delete them if wanted. Deleting a Routine deletes sessions it
    *started*; these started none.
  - Auditor session: `session_011gJukTnZRcozNx2f8EzB1r`, "ICC lock
    quality assessment".
- Remote Control will not run inside a cloud session.
- Seats spawned from a session in this repo load its CLAUDE.md as
  context. They absorb its values, which is a brief nobody wrote. A
  3-seat test with a neutral brief was proposed; not done.

## First moot (design, morning of 09-29)

3 seats, mesh-p, 1 cycle.

What stood 3-0:
- every seat builds the whole matter in a private clone;
- no plan vote; trees voted whole;
- a hash, not a diff, on the wire;
- mesh, not mesh-p;
- a fixed schedule;
- the `read -t 0` wait before hear;
- a round past about 30KB is lost from view.

The seats bent to CLAUDE.md lines ("The run", "not a shared plan").
Brian cut those lines and the design moved to one tree with locks.
Seat 2 later put the rotation's value in one line: "a table where
everyone argues every side is a good way to find out which positions
survive only because nobody pushed on them."

## Last moot: this session's changes, 09-30

3 seats, mesh-p, 1 cycle. Matter: review e2bc767..d2f81e2 and ICC
a294aae; read the diffs; the Auditor explained. All rounds were sat.
Each seat ran ICC lib.sh and Moot run.sh (both ok) and verified
backgrounding.

**Stood 3-0**
- **Merge state.** ICC main is a294aae; Moot main was b5b660b.
- **Output cap** (ranked first). A round over about 30K characters is
  lost from view, and moot-hear did not say so. Fixed in 1542a59.
- **Backgrounded calls.**
  - moot-say: use the longest timeout, and never say again when a say's
    call went to the background.
  - moot-hear: do not call hear again while a backgrounded one runs.
  - Fixed in 1542a59.
- **vWaitFor lanes.** Open with `<>`, and test `-p` before every look.
  Fixed by the Auditor in ICC 59920b6.
- **Draft: "first committed wins" breaks Favor nothing.** Marked open
  in the draft.
- **Draft: waits walk outside the lock can deadlock; the lock sweep
  misses paths.** Fixed in 1542a59.
- **README line 38 "no shared plan".** Fixed.
- **No test of a seat hear that waits and then gets its round.** Added
  in 1542a59.
- **Squash the branch-only rule commits.** Not done; needs a
  force-push, Brian's call.

**Stood 2-1**
- d2f81e2's reason for the split, "a caller that uses the wire without
  the rounds", names a caller that does not exist.
- CLAUDE.md said "A Claude Code skill". It now opens on the three
  skills.

**Fell**
- vWaitFor should take its deadline as an argument (1-2).
- The draft breaks CLAUDE.md scope and "facts, not recipes" (0-3).
- The plan file breaks "no file holds what is said" (0-3).

**Unargued, not voted**
- 2.11: moot-hear repeats icc-lib's facts.
- 2.12: moot-say dropped "sit again, made for more". Restored in
  1542a59.
- 2.13: check-sitting DELTA numbers collide with ITEM numbers. Fixed in
  the draft.
- 2.14: hear exits 1 for not yet, out of step and no seat alike.

**Agreed by all three, never argued**
- The ICC change, the hear wait and the split are correct.
- Backgrounding is real (on 2.1.285).
- The draft was stale ("four scripts", the wait "being made"); fixed.
- Draft Part 3 was circular; now says "overruled".
- The wait does not protect p: the parent hears as p once the seats
  return. Now in moot's SKILL.md.

## Open, for the next session

1. Merge ICC `59920b6` to ICC main, Brian's. Decide where vWaitFor's
   timeout belongs, given ICC's and Moot's CLAUDE.md.
2. moot-hear: say a timed-out call is cut off or backgrounded,
   depending on the Claude Code version.
3. The interface mismatch: raise `BASH_MAX_OUTPUT_LENGTH` to 150000
   (cloud env settings, Brian), and have create size BYTES to the
   reader.
4. Draft: pick the replacement for "first committed wins"; then sit a
   build moot by hand on something small and disposable.
5. Squash the rule commits (force-push; Brian's call).
6. Unvoted 2.11 and 2.14.
7. Moot's CLAUDE.md lacks ICC's "Bash, and the shebang decides", "Keep
   the lines sharp" and "Functions are welcome". Brian: no call yet.
   Run harnesses by path (`tests/run.sh`), not `bash tests/run.sh`.
8. tests/agents.sh has not been run since the split.
9. Other parked ideas:
   - a step where seats argue against claims every report shares;
   - AI managing a cluster from a tee'd side lane, never the data path;
   - a git transport for cross-machine ICC (DNATools' scratch pads and
     the Grok maildir already do it).
