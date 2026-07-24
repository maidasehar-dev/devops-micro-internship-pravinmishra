---
name: pr-ready
description: Reviews staged Git changes and drafts a Pull Request title, description, and a list of items worth a second look — without writing, committing, or pushing anything.
allowed-tools: Bash, Read, Grep
disable-model-invocation: true
---

# PR Ready Skill

## Purpose
This skill reviews the currently staged Git changes and produces a PR-readiness report along with a drafted Pull Request title and description. It never modifies, commits, or pushes anything — it only reads and reports.

## Safety Rules
- This skill must ONLY use read-only commands: `git diff --cached`, `git status`, `git log`, and similar inspection commands.
- This skill must NEVER create, edit, or delete any file.
- This skill must NEVER run `git add`, `git commit`, `git push`, or open a Pull Request.
- All findings must be based strictly on the actual staged diff — no fabricated issues.

## Instructions
1. Run `git status` and `git diff --cached` to see what's currently staged.
2. Review the staged changes for:
   - Possible secrets or credential-like strings
   - Debug statements (e.g., stray `echo`, `print`, `console.log`)
   - TODO/FIXME comments
   - Mixed or unrelated changes bundled together
   - Missing documentation or context
3. Present a clear risk report: what was found, in which file, and why it matters.
4. Draft a suggested Pull Request title and description based on the actual changes.
5. Remind the user that they must review, edit, and personally execute any commit, push, or PR creation — this skill does not do so itself.
