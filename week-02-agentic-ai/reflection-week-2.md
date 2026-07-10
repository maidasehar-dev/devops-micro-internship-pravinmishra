# Reflection – Week 2
*by Maida Sehar*

## 1. Biggest technical insight I got this week

The biggest shift in understanding for me was realizing that Claude Code isn't just a chatbot that answers questions — it follows a real Agentic Loop: Gather, Act, Verify. Watching it read files before answering, run shell commands to check its own work, and analyze error output instead of just guessing made the whole idea of "agentic AI" click. I also understood why CLAUDE.md matters so much — before I added it, Claude gave generic answers about my portfolio site; after adding it, the same question got answers that correctly referenced S3, CloudFront, and Terraform, and it actively refused to add React because of a rule I'd written. That was the moment I understood CLAUDE.md isn't documentation for humans — it's a steering wheel for the AI's behavior.

## 2. Biggest insight I got about myself this week

I learned that I tend to move fast without fully separating "where am I right now" — several times this week I confused my two project folders (the submission repo and the starter repo) because I didn't check which VS Code window or terminal path I was actually in before running a command. I also learned I do better when I test things step by step and verify output before moving on, rather than assuming a command worked just because it didn't show an obvious error.

## 3. My biggest weakness or loop I noticed

My repeated loop this week was creating files in the wrong location — I accidentally created a nested `.claude/.claude/settings.json` folder, and separately renamed downloaded skill files with mangled prefixed names because I didn't check the exact path before moving them. Both times, the fix was the same: stop, run `dir` or `ls` to actually see where I was, and only then proceed.

## 4. One system I will implement from this week

Before creating or moving any file, I will run `pwd` (or `dir`) first to confirm my exact working directory, every single time, without exception. I'll do this at the start of every terminal session, not just when something breaks. This will stop me from creating misplaced files and wasting time debugging "why can't Claude find this file" problems that are really just "I was in the wrong folder."

## 5. What I learned about Agentic AI and DevOps

I used to think DevOps automation meant writing more scripts. This week showed me it also means designing *permission boundaries* for AI the same way you'd design IAM roles — deciding exactly which tools an agent can use, and why. Seeing `tf-plan` restricted to read-only tools while `tf-writer` had write access made this concrete: the goal isn't giving AI more power, it's giving it the *right* power for the job. Hooks reinforced this even harder — watching a `terraform destroy` command actually get blocked before execution, because a script checked it first, made "safety rails" feel like a real engineering practice, not just a nice idea.

## 6. My Week 2 highlight

My highlight was debugging the hooks assignment. My PreToolUse and PostToolUse hooks kept failing with "file not found" errors, and I eventually figured out it was because Claude had changed its working directory (`cd terraform`) before the hook ran, breaking the relative file paths. Fixing it by switching to `$CLAUDE_PROJECT_DIR` absolute paths, and then actually seeing `terraform destroy` get blocked and a log entry appear in `deploy.log`, felt like real engineering — not just following steps, but diagnosing why something broke and fixing the root cause.

---

*This reflection is part of the DevOps Micro Internship (DMI) Cohort 3 — Agentic AI Track.*