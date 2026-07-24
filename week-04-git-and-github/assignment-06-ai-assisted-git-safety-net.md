# Assignment 6 — Building an AI-Assisted Git Safety Net (PR Ready Check)

Part of the DevOps Micro Internship (DMI) Cohort 3 with Agentic AI

---

## Purpose

In Week 2 you built Claude Code hooks that block a dangerous action *before* it happens (`PreToolUse`), and a restricted skill that could look but not touch (`allowed-tools` without `Write`). In this assignment you will discover that Git has the exact same idea, decades older: a **pre-commit hook** that blocks a commit before it's created.

You will build both halves of a real "PR Ready" workflow:

1. A **Git hook that follows fixed rules** — scans staged changes for hardcoded secrets and oversized files and refuses the commit. No AI involved, no guessing, just a rule that gives the same answer every time.
2. A **restricted Claude Code skill** (`/pr-ready`) that reads your staged diff and drafts a Pull Request title, description, and a short list of things worth a second look — the kind of judgment a fixed rule can't make (mixed changes, missing context, unclear intent). The skill never commits, pushes, or opens the PR. You do that yourself, using its draft as a starting point.

This mirrors the Agentic Loop from Week 3's Linux triage assignment: **Gather → Analyze → Human Act → Verify**. The hook and the skill both gather and analyze; only you act.

---

# Task 0 — Confirm Your Fork and Create a Feature Branch

## Goal

Confirm you are working in your own fork, then create a dedicated branch for this assignment.

### Evidence

#### Screenshot 1 — Output of git remote -v and git branch showing the new branch

![Screenshot1](<screenshots/Screenshot1 Task0 Assign6 Week4.png>)


### Notes

**1. Why create a dedicated branch instead of doing this work on main?**

Creating a dedicated branch keeps this assignment's demonstration files (the intentionally risky test script, the pre-commit hook, and the Claude Code skill) completely isolated from my main branch, which contains my actual completed DMI coursework. This means my main branch stays clean and stable throughout this exercise, and if anything goes wrong while testing the hook or skill, it can't accidentally affect my submitted assignments. It also mirrors real-world practice feature work always happens on its own branch before being reviewed and merged.



# Task 1 — Stage a Change With Realistic Risk

## Goal

On your own fork of this repository (the one you've been submitting your DMI work in since onboarding), create a new branch and stage a change that a real reviewer should catch: a hardcoded-looking secret and a leftover debug statement.

### Evidence

#### Screenshot 1 — Output of  `git status` showing the staged file on feature/ai-pr-ready

![Screenshot1](<screenshots/Screenshot1 Task1 Assign6 Week4.png>)




### Notes

**1. Why does this assignment use an obviously fake key instead of a real one?**

Using an obviously fake key (AKIA-IOSFODNN7-EXAMPLE, a well-known AWS documentation example key) lets us safely demonstrate and test secret-detection tooling both the pre-commit hook and the /pr-ready skill without ever risking exposing a real credential. If this fake key accidentally ended up committed to a public repository, it poses zero actual security risk, since it was never a valid, active credential. This is a standard practice in security tooling demonstrations and testing.



# Task 2 — Write a Real Git Pre-Commit Hook

## Goal

Create a tracked, shareable pre-commit hook that blocks a commit containing secret-like patterns or files over 1MB.

### Evidence

#### Screenshot 2 — `hooks/pre-commit` open in VS Code showing the full script

![Screenshot2](<screenshots/Screenshot2 Task2 Assign6 Week4.png>)




#### Screenshot 3 — Output of `git config core.hooksPath` confirming it points to `hooks`

![Screenshot3](<screenshots/Screenshot3 Task2 Assign6 Week4.png>)



### Notes

**1. Why is `hooks/pre-commit` tracked in the repo instead of living only in `.git/hooks/`?**

Files inside .git/hooks/ are local-only they never get committed or pushed, since .git/ is Git's internal metadata folder, not part of the tracked project. If the hook lived only there, every teammate would need to manually recreate it themselves, and it could easily be forgotten or lost. By placing the hook in a regular tracked folder (hooks/) and pointing core.hooksPath at it, the hook becomes a real, shareable, version-controlled part of the project anyone who clones the repo and runs git config core.hooksPath hooks gets the exact same safety net.

**2. Compare this to `PreToolUse` from Week 2 Assignment 6. What does each one intercept, and what do they have in common?**

PreToolUse intercepts Claude Code's own actions before they execute for example, blocking Claude from running a dangerous Bash command before it happens. The Git pre-commit hook intercepts a human's Git action blocking a git commit before it's created. Both share the same core principle: a fixed, automatic check that runs before a risky action completes, with the power to stop it entirely if a rule is violated. Neither relies on judgment or context they're deterministic gates that give the same answer every time, regardless of who or what triggered the action.



# Task 3 — Prove the Hook Blocks the Risky Commit

## Goal

Attempt to commit the staged file from Task 1 and show the hook rejecting it.

### Evidence

#### Screenshot 4 — Terminal showing `git commit` rejected with the hook's "BLOCKED" message naming the exact file

![Screenshot4](<screenshots/Screenshot4 Task3 Assign6 Week4.png>)



### Notes

**1. Which line in `hooks/pre-commit` matched your fake key, and why did it match?**

The line that matched was the secret-detection regex: grep -qE 'AKIA[0-9A-Z]{16}|-----BEGIN (RSA|OPENSSH|PRIVATE) KEY-----'. My fake key, AKIA-IOSFODNN7-EXAMPLE, starts with the exact prefix AKIA followed by 16 uppercase letters/numbers, which precisely matches the pattern AKIA[0-9A-Z]{16} — this is the standard format for AWS Access Key IDs, so the hook correctly flagged it as a likely secret.



**2. Could this hook have caught a poorly-named variable that stores a secret without the `AKIA` prefix? What does that tell you about the limits of a fixed rule like this?**

No — if the secret didn't match the specific AKIA... pattern or the private key header pattern (for example, a generic API key, a database password, or a secret stored under a vague variable name like x = "mysecretvalue123"), the hook would completely miss it, since it only checks for these two specific, predefined patterns. This reveals the fundamental limitation of fixed-rule detection: it can only catch what it's explicitly programmed to recognize. It has no actual understanding of meaning it can't infer that a suspicious-looking string assigned to a variable named password or secret_token is risky unless that exact pattern was anticipated in advance. This is precisely why a second layer — the AI-assisted /pr-ready review in Task 4 — adds value: it can use contextual judgment to catch things a fixed pattern-matcher would miss entirely.



# Task 4 — Build the `/pr-ready` Skill

## Goal

Create a manually invoked Claude Code skill that reads your staged changes and produces a PR-readiness report and a draft PR description — without writing, committing, or pushing anything itself.

### Evidence

#### Screenshot 5 — `SKILL.md` frontmatter showing `allowed-tools: Bash, Read, Grep` (no `Write`) and `disable-model-invocation: true`

![Screenshot5](<screenshots/Screenshot5 Task4 Assign6 Week4.png>)


#### Screenshot 6 — `/pr-ready` output while the risky file is still staged, showing it flagged the secret and/or debug statement

![Screenshot6](<screenshots/Screenshot6 Task4 Assign6 Week4.png>)


### Notes

**1. Why does `/pr-ready` have `Bash` and `Read` but not `Write`?**

The skill only needs to inspect the repository running git status and git diff --cached (Bash) and reading file contents (Read) to produce its analysis. It never needs to create, modify, or delete any file, so excluding Write access enforces the core safety principle of this assignment: the skill can look and report, but it physically cannot touch anything, no matter what it's asked to do.



**2. The pre-commit hook and `/pr-ready` both looked at the same staged diff. Did they flag the same things? What did one catch that the other didn't?**

Both correctly caught the hardcoded AWS key, since it matched the hook's exact regex pattern. However, /pr-ready caught significantly more than the hook did: it also flagged the debug echo statement that would print the credential to logs (Medium severity) and noted the missing documentation context (Low severity) — neither of which the hook's fixed rule was designed to detect at all. This demonstrates the real difference between the two: the hook only catches what it's explicitly pattern-matched to look for, while the AI skill can reason about why something is risky, even when it doesn't match a predefined regex.



# Task 5 — Fix the Issues and Re-Verify

## Goal

Remove the secret and debug statement, then prove both gates now pass clean.

### Evidence

#### Screenshot 7 — `git commit` succeeding after the fix (no BLOCKED message)

![Screenshot7](<screenshots/Screenshot7 Task5 Assign6 Week4.png>)




#### Screenshot 8 — Second `/pr-ready` run showing a clean risk report and a drafted PR title + description

![Screenshot8](<screenshots/Screenshot8 Task5 Assign6 Week4.png>)



### Notes

**1. What exactly did you change to satisfy the pre-commit hook?**

I rewrote scripts/notify.sh to remove both flagged issues: I deleted the hardcoded AWS_ACCESS_KEY="AKIA-IOSFODNN7-EXAMPLE" variable entirely, and removed the echo "Using key: $AWS_ACCESS_KEY" line that would have printed the credential. The replacement script is a minimal placeholder that only prints a generic status message ("Notification script running"), with a comment clarifying it's a demo-only file with no real credentials — satisfying both the hook's regex check and /pr-ready's broader review.



# Task 6 — Push and Open a Pull Request Using the AI Draft

## Goal

Push your branch and open a real Pull Request, using `/pr-ready`'s drafted title and description as your starting point — read it critically and edit before you use it.

**Important:** Open this Pull Request with base repository set to **your own fork** — not the shared upstream `pravinmishraaws/devops-micro-internship-pravinmishra` repository. This assignment's hook and skill files are your own practice work, not a change meant for the shared class repo.

### Evidence

#### Screenshot 9 — Your Pull Request showing the base repository is your own fork, plus the title and description, with the `/pr-ready` draft visible for comparison (paste it in the PR conversation or your notes below)

Add your screenshot here.

---

#### PR Link

Add your PR URL here...

---

### Notes

**1. What, if anything, did you edit in the AI's drafted PR description before using it? Why?**

Add your answer here.

---

**2. If you had blindly copy-pasted the AI's draft without reading it, what could go wrong?**

Add your answer here.

---

**3. Why does this PR need to target your own fork instead of the shared upstream repository?**

Add your answer here.

---

# Task 7 — Map the Workflow to the Agentic Loop

## Goal

Explain this assignment's workflow using the same Gather → Analyze → Human Act → Verify structure from Week 3.

### Notes

**1. Which step(s) represent Gather?**

Add your answer here.

---

**2. Which step(s) represent Analyze?**

Add your answer here.

---

**3. Which step is Human Act, and why must a human — not Claude — run `git commit`, `git push`, and open the PR?**

Add your answer here.

---

**4. Which step is Verify?**

Add your answer here.

---

**5. In one or two sentences: why do you need *both* the fixed-rule pre-commit hook and the AI skill? Isn't one enough?**

Add your answer here.

---

# Task 8 — LinkedIn Post

## Goal

Publish a LinkedIn post summarizing what you built and what you learned about combining fixed-rule safety checks with AI-assisted review.

### Evidence

#### LinkedIn Post URL

Add your LinkedIn post URL here...

---

## Key Learnings

Add 3-5 bullet points on what you learned this week.

-
-
-

---

# Submission Instructions

- Ensure `hooks/pre-commit` and `.claude/skills/pr-ready/SKILL.md` are committed to your GitHub repository
- Add all required screenshots to your submission
- All written answers must be in your own words
- Do not use a real secret or credential anywhere in your submission — the fake key in Task 1 is intentional and must stay clearly fake
- Open your Pull Request against your own fork, not the shared upstream repository
- Push your final changes to your forked repository
- Include your PR link and LinkedIn post URL

---

## GitHub Repository URL

Paste your forked repository URL here:

`Add your URL here`

---

# Completion Checklist

- [ ] Branch `feature/ai-pr-ready` created with a staged file containing a fake secret and a debug statement
- [ ] `hooks/pre-commit` created and tracked in the repo (not only in `.git/hooks/`)
- [ ] `core.hooksPath` configured to point at `hooks/`
- [ ] Pre-commit hook shown blocking the risky commit
- [ ] `.claude/skills/pr-ready/SKILL.md` created with correct `allowed-tools` (no `Write`) and `disable-model-invocation: true`
- [ ] `/pr-ready` run against the risky diff and shown flagging issues
- [ ] Risky file fixed; `git commit` succeeds cleanly
- [ ] `/pr-ready` re-run showing a clean report and drafted PR title/description
- [ ] Pull Request opened using the AI draft as a starting point, with your own fork as the base repository (not upstream), PR link included
- [ ] Agentic Loop mapping (Task 7) completed in your own words
- [ ] LinkedIn post published and URL submitted
- [ ] All required screenshots added
- [ ] GitHub repository URL provided

---

## 📌 About DMI & CloudAdvisory

DevOps Micro Internship (DMI) is a project-based DevOps program run by Pravin Mishra (The CloudAdvisory) focused on real-world execution, systems thinking, and career readiness.

It helps learners build strong DevOps foundations with hands-on experience.

---

## 📌 Resources

- 🌐 DMI Official Website: https://pravinmishra.com/dmi  
- 🎓 DevOps for Beginners (Udemy): https://www.udemy.com/course/devops-for-beginners-docker-k8s-cloud-cicd-4-projects/  
- 🎓 Agentic AI DevOps with Claude Code: https://www.udemy.com/course/ultimate-agentic-ai-devops-with-claude-code/  
- 🎓 DevOps with Claude Code: Terraform, EKS, ArgoCD & Helm: https://www.udemy.com/course/devops-with-claude-code-terraform-eks-argocd-helm/  
- ▶️ YouTube Playlist: https://www.youtube.com/playlist?list=PLFeSNDtI4Cho  
- 🔗 Pravin Mishra (LinkedIn): https://www.linkedin.com/in/pravin-mishra-aws-trainer/  
- 🏢 CloudAdvisory (LinkedIn): https://www.linkedin.com/company/thecloudadvisory/

---

*This submission is part of DevOps Micro Internship (DMI) Cohort 3 — Agentic AI Track.*
