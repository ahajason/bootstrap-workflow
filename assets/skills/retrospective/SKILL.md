---
name: retrospective
description: Use when closing a task, version, or shipping a milestone — or when user later questions a decision already shipped. Captures lessons that prevent the same systematic blind spot from recurring.
---

# Retrospective

## Overview

A retrospective turns a shipped decision into a future-recallable lesson. Without it, the same root cause produces the same symptoms again.

## When to Use

- Just shipped a task / version / PR
- User later asks "why did we do X that way" and the answer reveals gaps
- Closing a version branch (before merge to main)
- Introduced a system-level API and only verified the happy path

Skip for: single-line fixes, mechanical refactors, doc-only changes.

## The 4-Section Output

Every retro has exactly these sections, in order. Each is a structural slot — fill every one.

1. **Initial decision** — Goal / scope / how verification was scoped
2. **Unidentified at decision time** — Which layer was skipped:
   - L1: official docs warning that wasn't read
   - L2: project spec that didn't cover this case
   - L3: user-facing interaction side effects that weren't enumerated
3. **Later exposure** — Symptoms + true root cause (often NOT in original L3 list)
4. **Generalized lesson** — One sentence that applies to future similar scenarios. If you can't generalize, section 4 isn't done.

## Quick Reference

| Symptom in retro | Layer skipped | Prevention |
|---|---|---|
| "Only verified happy path" | L3 | Enumerate user-facing interactions BEFORE commit |
| "Official docs warned about it" | L1 | Quote relevant docs warning in commit body |
| "Spec didn't cover this" | L2 | Add spec section + retro example |
| "User said 'fine' so we shipped" | L3 | Define pass/fail contract before acceptance |

## Output Path

`docs/reports/<version>-retrospective.md` — one file per closure, git tracked.

## Common Rationalizations

| Excuse | Reality |
|---|---|
| "Smoke passed = done" | Smoke tests happy path. Failures live in side effects. |
| "User accepted = closed" | Acceptance is one signal, not a contract. Define pass/fail first. |
| "It's just one line" | One-line system API changes have full-stack consequences. |
| "I'll remember the lesson" | Without written retro, the lesson doesn't propagate to other agents or future code. |
| "Skip section 4, nothing to generalize" | If you can't generalize, you didn't actually learn — work is incomplete. |

## Cross-References

- [[three-layer-decision-method]] — Layer 1/2/3 framework that retro closes
- [[exhaust-layers-before-fix]] — Fix all root causes at once, not one at a time
