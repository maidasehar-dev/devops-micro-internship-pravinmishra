# Assignment 7 — AI-Assisted AWS Security and Cost Audit

Part of the DevOps Micro Internship (DMI) Cohort 3 with Agentic AI

---

## Purpose

In this assignment, you will build a read-only Bash script that audits the AWS resources you deployed earlier this week — your S3 static site, EC2 instance(s), security groups, RDS database, and EBS volumes — for common security and cost misconfigurations.

You will then connect that script to Claude Code as a reusable `/aws-audit` skill that explains what it found and recommends a fix, without ever making the fix itself.

Finally, you will find a real misconfiguration in your own account, apply the fix yourself, and prove it worked with a second audit run.

---

# Task 1 — Confirm Your AWS Resources and Set Up Your Workspace

## Goal

Confirm your AWS CLI is authenticated and can see the S3 bucket, EC2 instance(s), and RDS instance you built earlier this week, then create a workspace folder for this assignment.

### Evidence

#### Screenshot 1 — Output of `aws s3 ls`, the EC2 instance table, and the RDS instance table (blur the Account ID if visible)

![Screenshot1](<screenshots/Screenshot1 Task1 Assign7 Week6.png>)


#### Screenshot 2 — Output of `pwd` and `find . -maxdepth 4 -type d | sort`


![Screenshot2](<screenshots/Screenshot2 Task1 Assign7 Week6.png>)



### Notes You Must Write (Very Important)

**1. Which resources from this week's earlier assignments did you see in the listings?**

The listings confirmed: one S3 bucket (pravin-portfolio-maidasehar-eu-north-1) from Assignment 2; six EC2 instances total including three stopped from earlier assignments (Mini-Finance-Web-EC2, epicbook-app-server, epicreads-react-server) and three currently running (an untagged instance from Assignment 5's testing plus Book-Review-Web-EC2 and Book-Review-App-EC2 from Assignment 6) and two RDS MySQL instances (epicbook-db and book-review-db).

**2. Why must you confirm your resources exist before writing an audit script against them?**

Confirming resources exist first prevents writing an audit script against assumed or outdated inventory for example, referencing a bucket name or instance ID that no longer exists (or was renamed) would cause the script to silently fail or report false negatives ("no issues found") simply because it never located the resource not because the resource is actually secure. It also surfaces exactly what naming conventions, tags, and regions are actually in use so the script's queries match reality rather than guesswork.


# Task 2 — Define Safety Rules in CLAUDE.md

## Goal

Create a `CLAUDE.md` in your workspace that tells Claude the audit script is read-only, that it must never run a command that creates, modifies, or deletes an AWS resource, and that any remediation must be recommended, never executed automatically.

### Evidence

#### Screenshot 3 — `CLAUDE.md` open in VS Code showing all four sections


![Screenshot3](<screenshots/Screenshot3 Task2 Assign7 Week6.png>)


### Notes You Must Write (Very Important)

**1. Why should Claude never be given permission to run `revoke-security-group-ingress` itself, even if the fix is obviously correct?**

Even when a fix looks obviously correct an AI assistant making an irreversible change to live infrastructure removes the human checkpoint that catches context the AI can't see for example, that "obvious" open port might be intentionally open for a legitimate reason (a third-party integration, a temporary debugging session, a teammate's access), and revoking it automatically could break something the audit script has no way of knowing about. Keeping remediation as a human-approved  human-executed step ensures someone with full context on the account's actual usage makes the final call and it also means every infrastructure change has a clear accountable human author rather than being silently applied by a tool. This mirrors the same principle from the sprint-health skill in Assignment 5 — the AI's job is to surface evidence and recommend not to act.

**2. Which rule prevents Claude from claiming a finding that the report does not support?**

The Safety Rules explicitly state: "Do not claim a finding unless the report contains supporting evidence." This forces every finding Claude reports to be traceable back to actual output from the Bash audit script, rather than Claude inferring, assuming, or hallucinating a security issue based on general AWS knowledge. Combined with the Output Rules requirement to show "exact evidence from the report" for every WARN or FAIL, this makes Claude's analysis fully auditable a human can always check the underlying script output and verify Claude didn't overstate or fabricate a finding.


# Task 3 — Plan the Audit with Claude Code

## Goal

Ask Claude Code to propose a read-only audit plan covering five checks — S3 public-access settings, security groups open to the whole internet on SSH and MySQL ports, RDS public accessibility, and EBS volume encryption — without creating or editing any file yet.

### Evidence

#### Screenshot 4 — Claude Code showing the five-check plan


![Screenshot4.1](<screenshots/Screenshot4 Task3 Assign7 week6.png>)
![Screenshot4.2](<screenshots/Screenshot4.2 task3 Assign7 Week6.png>)


### Notes You Must Write (Very Important)

**1. Which part of this task represents the Gather phase?**

The entire audit plan Claude proposed in this task represents the Gather phase all five checks consist purely of read-only AWS CLI calls (S3 public access block status, security group rules for ports 22 and 3306, RDS PubliclyAccessible status, and EBS encryption status) that collect evidence about the current state of the account. No analysis, risk estimation, or remediation happens yet at this stage that comes later, once the Bash script actually runs and produces a report for Claude to Analyze against CLAUDE.md's defined workflow.

**2. Did every proposed command start with `describe-`, `get-`, or `list-`? Why does that matter?**

Yes — every command Claude proposed uses only inspection verbs: aws s3api get-public-access-block, aws ec2 describe-security-groups, aws rds describe-db-instances, and (for the EBS check) aws ec2 describe-volumes. This matters because these verbs are structurally incapable of changing anything in the AWS account they only retrieve and display existing state. This is a concrete verifiable way to confirm the plan actually honors CLAUDE.md's read-only safety rule, rather than just trusting Claude's stated intent; anyone reviewing the plan can check each command against this pattern before it's ever run.



# Task 4 — Build the AWS Audit Script

## Goal

Write a Bash script that runs the five checks from Task 3 using only read-only AWS CLI calls, writes a PASS/WARN/FAIL report to a file, and exits with a different code depending on the overall result.

Make it executable and confirm it has no syntax errors.

### Evidence

#### Screenshot 5 — Top section of `aws-audit.sh` showing the variables and the checks array

![Screenshot5](<screenshots/Screenshot5 Task4 Assign7 Week6.png>)


#### Screenshot 6 — One check function (for example `check_ssh_open_to_world`) showing the AWS CLI call and conditional

![Screenshot6](<screenshots/Screenshot6 Task4 Assign7 Week6.png>)


#### Screenshot 7 — Output of `bash -n scripts/aws-audit.sh` and `ls -l scripts/aws-audit.sh`

![Screenshot7](<screenshots/Screenshot7 Task4 Assign7 Week.png>)


### Notes You Must Write (Very Important)

**1. What is stored in the checks array, and how does the loop use it?**

The checks array stores five colon-separated pairs, each combining a human-readable check name (e.g., "SSH Port 22 Open to 0.0.0.0/0") with the actual Bash function name that implements it (e.g., "check_ssh_open_to_world"). The loop iterates over the array, splits each entry on the colon to extract the name and function separately, calls the function by name, captures both its printed output and its exit code, writes the output into the report with the check's number and name as a header, and tracks the highest exit code seen across all checks to determine the script's final overall exit status.

**2. Why does every AWS CLI call in this script use `--query` and `--output text` instead of parsing raw JSON?**

Using --query filters the AWS CLI's response server-side (via JMESPath) down to only the specific fields the check actually needs, and --output text renders that result as plain tab-separated values instead of a JSON object. This means the script's Bash logic can compare and loop over the results directly with simple string tests (like [ -z "$var" ] or a while read loop) without needing a separate JSON parser like jq, which keeps the script portable and dependency-free while also making each command's output far shorter and easier to read directly in the audit report.

**3. Why does the script use different exit codes for HEALTHY, WARN, and FAIL?**

Distinct exit codes (0 = HEALTHY, 1 = WARN, 2 = FAIL) let the script communicate severity, not just pass/fail, to anything that calls it — a CI pipeline, a cron job, or Claude Code reading the script's result could treat a WARN (like an unencrypted EBS volume) differently from a FAIL (like a database open to the internet), for example by only alerting on FAIL but logging WARN silently. Tracking the highest exit code across all five checks also means the overall script exit code always reflects the single worst finding, so a caller checking only the final exit code still gets an accurate summary of the account's overall risk level without having to parse the full report.


# Task 5 — Run the Baseline Audit

## Goal

Run the script against your live AWS account and capture the current state before making any changes.

### Evidence

#### Screenshot 8 — Output of `./scripts/aws-audit.sh` showing your Full Name and all five checks


![Screenshot8](<screenshots/Screenshot8 Task5 Assign7 Week6.png>)



#### Screenshot 9 — Output showing the captured exit code and final summary


![Screenshot9](<screenshots/Screenshot9 Task5 Assign7 Week6.png>)



### Notes You Must Write (Very Important)

**1. What is the overall status of your baseline audit?**

The overall status is FAIL (exit code 2), the most severe of the three possible outcomes, driven by two FAIL-level findings: SSH open to 0.0.0.0/0 on five security groups, and the book-review-db RDS instance being publicly accessible.

**2. Did any check return FAIL or WARN? If so, which one, and what evidence did it show?**

Yes — three of the five checks returned non-PASS results:
- FAIL: SSH (port 22) is open to 0.0.0.0/0 on five security groups, including sg-0b7dc8b403c190e05 (launch-wizard-1), sg-067f5168550ae5898 (Book-Review-Web-SG), sg-0efa555968fe74ba7 (launch-wizard-3), sg-0ab01f954ddf99370 (epicbook-ec2-sg), and sg-0d81f3179451b650b (launch-wizard-2).
- FAIL: The book-review-db RDS instance shows PubliclyAccessible: true, despite having been configured with Public access: No during Assignment 6 — this needs further investigation, since it contradicts the original setup.
- WARN: The S3 bucket pravin-portfolio-maidasehar-eu-north-1 has all four public access block settings set to false (expected for a static website hosting bucket, but worth scoping/documenting).
- WARN: All six EBS volumes are unencrypted.

**3. If every check passed, what does that tell you about the security posture of your account so far?**

Not applicable in this case — the baseline audit did not pass every check. If it had, that would indicate the account's currently-deployed resources follow the specific security practices this script checks for (restricted SSH access, no public MySQL exposure, private RDS, encrypted EBS volumes), though it would still only reflect these five specific checks, not a complete security posture — other misconfigurations outside this script's scope could still exist.


# Task 6 — Build and Run the /aws-audit Skill

## Goal

Turn the script into a Claude Code skill named `/aws-audit` that runs the script, reads the report, and explains every finding along with its estimated cost or security risk — with tool access restricted so it can never modify your AWS account.

### Evidence

#### Screenshot 10 — `SKILL.md` showing the frontmatter, tool restrictions, and safety rules


![Screenshot10](<screenshots/Screenshot10 Task6 Assign7 Week6.png>)



#### Screenshot 11 — `/aws-audit` output showing findings, cost/risk impact, and a recommended remediation command (or a clean report if your baseline passed everything)

![Screenshot11a](<screenshots/Screenshot11a Task6 Assign7 Week6.png>)
![Screenshot11b](<screenshots/Screenshot11b Task6 Assign7 Week6.png>)
![Screenshot11c](<screenshots/Screenshot11c Assign7 Week6 Task6.png>)



### Notes You Must Write (Very Important)

**1. Why does this skill have Bash, Read, and Grep, but not Write?**

The skill only needs to run the audit script (Bash), read the resulting report file (Read), and search within it (Grep) none of which requires creating or modifying any file. Deliberately excluding Write from allowed-tools means Claude is structurally incapable of editing the script, the report, CLAUDE.md, or any other file in this workspace, regardless of what a prompt asks it to do this is a stronger guarantee than just an instruction saying "don't edit files," since it's enforced at the tool-permission level rather than relying on Claude choosing to follow a rule.

**2. What part is performed by Bash, and what part is performed by Claude?**

Bash performs the Gather phase entirely: it runs the five read-only AWS CLI calls, evaluates each result against a healthy/unhealthy condition, and writes plain PASS/WARN/FAIL lines with supporting evidence into the report file this is deterministic, scriptable logic with no judgment involved. Claude performs the Analyze phase: reading that report, explaining what each finding means in plain language, estimating the cost or risk impact of each WARN/FAIL, prioritizing which findings matter most, and drafting (but never running) a specific remediation command this is the interpretive, human-facing work that a fixed script can't do on its own.

**3. Why is estimating cost/risk impact something the AI adds on top of a plain PASS/FAIL script?**

A plain PASS/FAIL script can tell you *that* something is misconfigured, but not *how much it matters* a Bash script has no way to reason about severity, business context, or what could actually go wrong (brute-force attacks, a leaked snapshot, an inflated bill from a compromised instance). Claude adds this layer by translating a bare technical fact ("5 security groups allow 0.0.0.0/0 on port 22") into something a human can prioritize against for example, correctly identifying the SSH finding as the highest-severity item in the report even though the script itself just prints five equally weighted FAIL lines with no ranking between them.


# Task 7 — Fix a Real Finding and Re-Verify

## Goal

Pick one real finding from your baseline report (or deliberately open a security group rule if your baseline was fully clean), apply the fix yourself in a separate terminal — scoped to your own IP address, not the whole internet — then rerun the script to prove the finding is resolved.

### Evidence

#### Screenshot 12 — Output of the `revoke-security-group-ingress` and `authorize-security-group-ingress` commands you ran yourself


![Screenshot12](<screenshots/Screenshot12 Task7 Assign7 Week6.png>)


#### Screenshot 13 — Rerun of `./scripts/aws-audit.sh` showing the finding is now PASS

![Screenshot13](<screenshots/Screenshot13 Task 7 Assign7 Week6.png>)


### Notes You Must Write (Very Important)

**1. Which exact finding did you fix, and what command did you run?**

I fixed the "SSH Port 22 Open to 0.0.0.0/0" finding on two security groups: launch-wizard-2 (sg-0d81f3179451b650b) and launch-wizard-3 (sg-0efa555968fe74ba7). For each, I ran aws ec2 revoke-security-group-ingress with --protocol tcp --port 22 --cidr 0.0.0.0/0 to remove the open-to-the-world rule, then aws ec2 authorize-security-group-ingress with --protocol tcp --port 22 --cidr 185.229.152.181/32 to re-add SSH access scoped to only my current public IP.

**2. Why did you scope the new rule to your own IP address instead of leaving it open to `0.0.0.0/0`?**

Scoping the rule to a single /32 CIDR (my own public IP) means only my specific machine can even attempt to connect on port 22 — anyone else on the internet, including automated scanners and brute-force bots, is rejected at the network level before ever reaching SSH's authentication step. This still lets me do legitimate administration of the instance while eliminating the much larger attack surface of the entire internet being able to attempt logins, which was the actual risk the audit flagged.

**3. Did Claude execute the remediation command, or did you? Why does that matter?**

I ran both the revoke and authorize commands myself, directly in my own terminal — Claude only ever proposed the remediation command as text for me to review, exactly as CLAUDE.md's safety rules require ("Recommend a remediation command, but do not execute it"). This matters because it keeps a human as the final decision-maker on any change to live infrastructure — I could review the exact command, confirm the correct security group ID and CIDR before running it, and remain fully accountable for the change, rather than an AI silently modifying my AWS account based on its own interpretation of what "obviously" needed fixing.

**4. Which phase of the Agentic Loop does the Bash script represent? Which phase does Claude's explanation represent? Which phase is you running the fix?**

The Bash script (scripts/aws-audit.sh) represents the Gather phase — it collects raw, read-only evidence from AWS via CLI calls and writes it to the report, with no interpretation or judgment involved. Claude's explanation via the /aws-audit skill represents the Analyze phase — reading that evidence, explaining what it means, estimating risk/cost impact, and drafting a specific remediation command, without taking any action itself. Me manually running the revoke and authorize commands represents the Human Act phase — the actual, irreversible change to live infrastructure, made by a person after reviewing the evidence and the proposed fix. Re-running the audit script afterward and confirming PASS represents the Verify phase, closing the loop by proving the fix actually worked rather than just assuming it did.


# LinkedIn Post (Required)

## Goal

Create a LinkedIn post including:

- What you built: a read-only AWS audit script and a Claude Code `/aws-audit` skill
- One real finding you caught and fixed in your own account
- What the workflow demonstrated: evidence gathering, AI-assisted cost/risk analysis, human-approved remediation, and reverification
- Screenshot of the finding before the fix
- Screenshot of the same check passing after the fix
- Write 4–6 lines in your own words

Suggested tags:

`#DMIByPravinMishra #AWS #AgenticAI #ClaudeCode #DevOps`

### Evidence

#### LinkedIn Post URL

https://lnkd.in/p/eNuc3bME


#### Screenshot of Published LinkedIn Post

![Screenshot](<screenshots/Screenshot linkedind post for week6 assign7.png>)


# Submission Instructions

Complete all tasks in sequence.

Your submission must include:

- All 13 required task screenshots
- Answers to every **Notes You Must Write** question
- `CLAUDE.md`
- `scripts/aws-audit.sh`
- `.claude/skills/aws-audit/SKILL.md`
- `reports/aws-audit-report.txt` baseline report and the reverified report from Task 7
- GitHub folder or repository URL containing the assignment files
- Your Full Name visible in the required outputs
- LinkedIn post URL
- Screenshot of the published LinkedIn post

Submit only a Google Doc link.

Add the GitHub URL inside the Google Doc.

Follow the Assignment Submission Guidelines.

---

# Completion Checklist

- [x] Task 1: AWS resources confirmed and workspace created (Screenshots 1–2)
- [x] Task 2: `CLAUDE.md` created with project context and safety rules (Screenshot 3)
- [x] Task 3: Claude produced a read-only five-check audit plan before any script existed (Screenshot 4)
- [x] Task 4: `aws-audit.sh` built, executable, and passes `bash -n` (Screenshots 5–7)
- [x] Task 5: Baseline audit captured and saved with Full Name visible (Screenshots 8–9)
- [x] Task 6: `/aws-audit` skill loads and runs successfully with no Write permission (Screenshots 10–11)
- [x] Task 7: A real finding was fixed by you and reverified as PASS (Screenshots 12–13)
- [x] Skill never executed a remediation command
- [x] New security group rule is scoped to your own IP, not `0.0.0.0/0`
- [x] All 13 required task screenshots are included
- [x] All "Notes You Must Write" questions are answered in your own words
- [x] No AWS credentials or unblurred account IDs exposed
- [x] LinkedIn post published and URL submitted
- [x] GitHub URL included in the Google Doc
- [x] Google Doc is accessible
- [x] Link tested in incognito mode

---

# Final Submission

Submit only your Google Doc link.

### Question

Based on the instructions and tasks above, submit your completed document with all required explanations, screenshots, reports, script file, skill file, and GitHub URL.

`Add your Google Doc link here`

---

## 📌 About DMI & CloudAdvisory

DevOps Micro Internship (DMI) is a project-based DevOps program run by Pravin Mishra (The CloudAdvisory) focused on real-world execution, systems thinking, and career readiness.

It helps learners build strong DevOps foundations with hands-on experience.

---

## 📌 Resources

- 🌐 DMI Official Website: https://dmi.pravinmishra.com?utm_source=github&utm_medium=readme  
- 🎓 University: https://university.pravinmishra.com?utm_source=github&utm_medium=readme  
- 💬 Discord Community: https://discord.pravinmishra.com?utm_source=github&utm_medium=readme  
- 📝 Blog: https://dmi.pravinmishra.com/blog?utm_source=github&utm_medium=readme  
- ▶️ YouTube Playlist: https://www.youtube.com/playlist?list=PLFeSNDtI4Cho  
- 🔗 Pravin Mishra (LinkedIn): https://www.linkedin.com/in/pravin-mishra-aws-trainer/  
- 🏢 CloudAdvisory (LinkedIn): https://www.linkedin.com/company/thecloudadvisory/

---

*This submission is part of DevOps Micro Internship (DMI) Cohort 3 — Agentic AI Track.*