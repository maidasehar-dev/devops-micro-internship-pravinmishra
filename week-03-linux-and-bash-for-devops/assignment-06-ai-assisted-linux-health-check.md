# Assignment 6 — Build an AI-Assisted Linux Health Check (AI-Assisted Linux Incident Triage)

Part of the DevOps Micro Internship (DMI) Cohort 3 with Agentic AI

---

## Purpose

In this assignment, you will build a read-only Bash triage script that checks the health of your Ubuntu server and Nginx application, connect it to Claude Code as a reusable `/linux-triage` skill, simulate a controlled Nginx incident, use the skill to gather and analyze evidence, recover the service manually, and verify recovery. The workflow follows the Agentic Loop: Gather → Analyze → Human Act → Verify.

---

# Task 1 — Confirm the Healthy Baseline and Create the Workspace

## Goal

Confirm that Nginx and the React application are healthy before building the automation.

### Evidence

#### Screenshot 1 — Output of `systemctl is-active nginx`, `ss -ltn | grep ':80'`, and `curl -I http://localhost`

Add your screenshot here.
![Screenshot1](<screenshots/Screenshot1 Task1 Assign6.png>)


#### Screenshot 2 — Output of `pwd` and `find . -maxdepth 4 -type d | sort` showing the workspace folder structure

Add your screenshot here.
![Screenshot2](<screenshots/Screenshot2 Task1 Assign6.png>)


### Notes

Answer the following in your own words:

**1. What proves that Nginx is running?**

Add your answer here.

The systemctl is-active nginx command returned active which directly confirms the Nginx service is currently running under systemd's process management. This is the authoritative source of truth for a service's running state on a systemd-based Linux system.

**2. What proves that the server is listening for HTTP traffic?**

Add your answer here.

The ss -ltn | grep ':80' output shows two LISTEN entries on port 80 — one for 0.0.0.0:80 (IPv4, all interfaces) and one for [::]:80 (IPv6, all interfaces). This proves the server has an active process bound to port 80 and is ready to accept incoming HTTP connections. Additionally, curl -I http://localhost returning HTTP/1.1 200 OK confirms the server isn't just listening, but is actually responding correctly to real requests.

**3. Why must you capture a healthy baseline before simulating an incident?**

Add your answer here.

Capturing a healthy baseline establishes a clear "before" reference point so that when an incident is simulated later I can accurately compare the failed state against known-good behavior. Without a baseline it would be impossible to definitively prove that a change in status (like Nginx becoming inactive) actually represents a real failure rather than just normal or ambiguous behavior. This mirrors real-world incident response where understanding "what normal looks like" is essential to detecting and diagnosing abnormal behavior.

# Task 2 — Create Project Context and Safety Rules in CLAUDE.md

## Goal

Tell Claude exactly what this project does and what it is not allowed to do.

### Evidence

#### Screenshot 3 — CLAUDE.md open in VS Code showing all four sections (Project Overview, Incident Workflow, Safety Rules, Output Rules)

Add your screenshot here.
![Screenshot3](<screenshots/Screenshot3 Task2 Assign6.png>)


### Notes

Answer the following in your own words:

**1. Why should Claude receive project-specific operational rules?**

Add your answer here.

Without explicit rules Claude has no way of knowing what's safe or expected in this specific context it might assume it's fine to restart a service or edit a config file the way a general-purpose coding assistant might in other projects. Giving Claude project-specific rules in CLAUDE.md ensures it understands the exact boundaries and expectations for this environment before it ever starts analyzing anything preventing unintended or unsafe actions.

**2. Why is the human required to execute the recovery command?**

Add your answer here.

Requiring a human to execute recovery actions ensures there's always a deliberate decision-making checkpoint before anything changes on a live system. AI analysis can be wrong incomplete, or based on limited evidence having a human review the suggested fix before running it prevents automated systems from taking irreversible or harmful actions based on a misdiagnosis, which is especially critical in production environments.

**3. Which rule prevents Claude from making an unsupported diagnosis?**

Add your answer here.

The Output Rules section specifically states: "Claude must not fabricate log entries, error messages, or system state that wasn't actually captured in the evidence" and that conclusions must be "strictly on the evidence gathered no speculation beyond what the data shows" (from Safety Rules). Together these rules ensure Claude's diagnosis is always grounded in real captured evidence rather than assumptions or hallucinated details.

# Task 3 — Use Agentic AI to Plan Before Writing the Script

## Goal

Use Claude Code to inspect the environment and produce a read-only plan before creating any Bash code.

### Evidence

#### Screenshot 4 — Claude Code showing the five-check plan and read-only inspection results

Add your screenshot here.


![Screenshot4](<screenshots/Screenshot4 Task3 Assign6.png>)
### Notes

Answer the following in your own words:

**1. Which part of this task represents the Gather phase?**

Add your answer here.

The Gather phase is represented by Claude's read-only inspection of the server running commands like systemctl status, checking Nginx config syntax, reviewing logs, and checking memory/disk all before proposing anything. This matches the "Gather" step of the Agentic Loop defined in CLAUDE.md: collecting evidence before any analysis or action happens.

**2. Did Claude follow the instruction not to create files? How did you verify this?**

Add your answer here.

Yes, Claude did not create any files during this task it only ran read-only inspection commands (systemctl, ss, curl, cat/log review) and required my approval before each one, confirming it wasn't silently writing anything. I verified this by watching each individual command approval prompt which only showed inspection commands (not file-write operations), and by checking that no new unexpected files appeared in my working directory afterward.

**3. Why is planning before coding useful in DevOps automation?**

Add your answer here.

Planning first ensures the resulting script is actually well-designed and relevant to the real environment rather than generic or guesswork-based. In this case, Claude's plan was informed by actual server characteristics (like memory being tight) meaning the eventual script targets checks that matter specifically here, not just theoretical "best practices." This mirrors real DevOps practice understanding the system before automating around it prevents building the wrong thing.

# Task 4 — Build the Linux Triage Bash Script

## Goal

Create one Bash script that gathers consistent Linux and Nginx health evidence.

### Evidence

#### Screenshot 5 — Top section of `linux-triage.sh` showing variables, thresholds, and the checks array

Add your screenshot here.
![Screenshot5](<screenshots/Screenshot5 Task4 Assign6.png>)


#### Screenshot 6 — Middle section showing check functions and conditionals

Add your screenshot here.
![Screenshot6](<screenshots/Screenshot6 Task4 Assign6.png>)


#### Screenshot 7 — Bottom section showing the loop, summary function, and exit behavior

Add your screenshot here.
![Screenshot7](<screenshots/Screenshot7 Task4 Assign6.png>)


#### Screenshot 8 — Output of `bash -n scripts/linux-triage.sh` (no syntax errors) and `ls -l scripts/linux-triage.sh` showing executable permission

Add your screenshot here.
![Screenshot8](<screenshots/Screenshot8 Task4 Assign6.png>)


### Notes

Answer the following in your own words:

**1. What is stored in the checks array?**

Add your answer here.

The checks array stores the names of five health check functions as strings: "nginx_status", "port_listen", "http_response", "resource_pressure", and "error_logs". These names correspond to function names (prefixed with check_) that get called dynamically later in the script.

**2. How does the `for` loop use that array?**

Add your answer here.

The for loop (for check in "${checks[@]}") iterates through each string in the array one at a time, storing the current value in the variable check. Inside the loop, check_$check dynamically constructs and calls the matching function name (e.g. check_nginx_status), meaning all five checks run automatically without me having to manually call each function by name.

**3. Why are the health checks separated into functions?**

Add your answer here.

Separating each check into its own function makes the script modular, readable, and easier to maintain — each function has a single, clear responsibility (e.g. check_http_response only checks HTTP status). This also makes it easy to add, remove, or reorder checks by just updating the checks array, without needing to restructure the whole script.

**4. What is the purpose of `$(...)` in this script?**

Add your answer here.

$(...) is command substitution — it runs the command inside the parentheses and captures its output as a string, which can then be stored in a variable. For example, http_code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/) runs curl and stores the resulting HTTP status code in the http_code variable for later comparison.

**5. Why does the script use different exit codes for HEALTHY, WARN, and FAIL?**

Add your answer here.

Different exit codes let other tools, scripts, or automation systems (including Claude Code, in Task 6) programmatically distinguish between a fully healthy system (exit 0), a system with non-critical warnings (exit 1), and a genuine failure (exit 2) — without needing to parse the full text output. This is a standard convention in DevOps automation, since exit codes can trigger different automated responses (e.g. alerting only on FAIL, not WARN).

# Task 5 — Run and Understand the Healthy-State Report

## Goal

Run the Bash script against the healthy server and verify that it creates a report.

### Evidence

#### Screenshot 9 — Output of `./scripts/linux-triage.sh` showing your Full Name and all five check results

Add your screenshot here.

![Screenshot9](<screenshots/Screenshot9 Task5 Assign6 orig.png>)


#### Screenshot 10 — Output showing the captured exit code and final summary

Add your screenshot here.
![Screenshot10](<screenshots/Screenshot10 Task5 Assign.png>)


### Notes

Answer the following in your own words:

**1. What is the overall status of your healthy baseline?**

Add your answer here.

The overall status is HEALTHY with all five checks passing: Nginx service active, listening on port 80, HTTP responding with 200, memory at 64% available, disk at 54% used and no recent errors in the Nginx error log.

**2. Which exact Linux evidence proves the application is serving traffic?**

Add your answer here.

The [PASS] HTTP response OK (200) result, generated from curl -s -o /dev/null -w "%{http_code}" http://localhost/, is the clearest evidence it proves the application actually responds to a real HTTP request with a successful status code not just that a process is technically running.

**3. Did your script return exit code 0 or 1? Explain why.**

Add your answer here.

The script returned exit code 0, because all five checks passed with no warnings or failures meeting the overall_status == "HEALTHY" condition in the print_summary function, which explicitly exits with code 0 in that case.

**4. What is the difference between a warning and a failure in this script?**

Add your answer here.

A warning (exit 1) indicates a non-critical issue like memory or disk usage crossing a threshold that doesn't mean the service is actually broken just that it's worth monitoring. A failure (exit 2) indicates something is definitively broken like Nginx not running or not responding to HTTP requests representing an actual service outage rather than just a risk factor.

# Task 6 — Create and Run the /linux-triage Skill

## Goal

Turn the Bash script into a reusable, manually invoked Agentic AI workflow.

### Evidence

#### Screenshot 11 — `SKILL.md` showing the frontmatter, allowed tool restrictions, and safety rules

Add your screenshot here.
![Screenshot11](<screenshots/Screenshot11 Task6 Assign6.png>)



#### Screenshot 12 — `/linux-triage` output for the healthy server

Add your screenshot here.
![Screenshot12](<screenshots/Screenshot12 Task 6 Assign6.png>)


### Notes

Answer the following in your own words:

**1. Why does this skill have Bash, Read, and Grep, but not Write?**

Add your answer here.

The skill only needs to run the existing script (Bash), read its output (Read), and potentially search through text output (Grep) — none of these require creating or modifying any files. Excluding Write access enforces the safety principle from CLAUDE.md: Claude should be able to investigate and explain but never create or alter files keeping it strictly in a read-only diagnostic role.

**2. Why is `disable-model-invocation: true` useful for this skill?**

Add your answer here.

This setting prevents Claude from automatically triggering the skill on its own based on conversation context it can only be run when I explicitly type /linux-triage. This ensures health checks only happen when I intentionally request them giving me full control over when diagnostic actions occur rather than Claude deciding to run checks unprompted.

**3. What part is performed by Bash, and what part is performed by Claude?**

Add your answer here.

Bash performs the actual evidence gathering running the systemctl, ss, curl, and log-checking commands inside linux-triage.sh and producing raw pass/fail output. Claude performs the analysis and explanation reading that raw output and translating it into a clear human-readable summary (like the table above) without altering or fabricating any of the underlying data.

**4. Why is this better than asking Claude "Is my server healthy?" without giving it evidence?**

Add your answer here.

Without running the actual script Claude would have no real data about my specific server it could only guess or give generic advice with no way to verify anything against reality. By running linux-triage.sh first and having Claude analyze that specific output the answer is grounded in real verifiable evidence from my actual system not speculation this is the core difference between an AI assistant and a proper agentic diagnostic workflow.

# Task 7 — Simulate an Nginx Incident and Let the Skill Diagnose It

## Goal

Create a controlled service failure, gather evidence through Bash, and let Claude analyze the evidence without taking recovery action.

### Evidence

#### Screenshot 13 — Output showing Nginx is inactive and the HTTP request fails

Add your screenshot here.
![Screenshot13](<screenshots/Screenshot13 Task7 Assign6.png>)


#### Screenshot 14 — `/linux-triage` output showing failed evidence, most likely cause, and a suggested recovery command

Add your screenshot here.
![Screenshot14](<screenshots/Screenshot14 Task7 Assign6.png>)


#### Screenshot 15 — `incident-failure-report.txt` showing the failed checks and your Full Name

Add your screenshot here.
![Screenshot15](<screenshots/Screenshot15 Task7 Assign6.png>)


### Notes

Answer the following in your own words:

**1. Which three checks failed?**

Add your answer here.

The three failed checks were: (1) Nginx service is not active, (2) Nginx is not listening on port 80, and (3) HTTP response failed with code 000 (no response received).

**2. What evidence supports the conclusion that Nginx is unavailable?**

Add your answer here.

All three failed checks point to the same root cause: systemctl is-active confirmed the service wasn't running, ss confirmed nothing was bound to port 80, and curl returned code 000 (no response at all, meaning connection refused). Additionally, the Nginx error log showed no recent errors supporting that the service was deliberately stopped rather than crashed since a crash would typically leave error trace entries behind.

**3. Did Claude execute the recovery command? Why is that important?**

Add your answer here.

No, Claude only suggested the recovery command (sudo systemctl start nginx) but explicitly did not execute it correctly stating "not executed by me." This is important because it enforces the safety rules defined in CLAUDE.md and SKILL.md the human operator must review the diagnosis and make the final decision before any system-changing command runs preventing an AI from making unverified changes to a live server.

**4. Which phase of the Agentic Loop is represented by the Bash report?**

Add your answer here.

The Bash report represents the Gather phase it's pure read-only evidence collection (service status, port checks, HTTP response, resource usage, logs) with no interpretation or decision-making involved yet.

**5. Which phase is represented by Claude's explanation?**

Add your answer here.

Claude's explanation represents the Analyze phase taking the raw evidence gathered by Bash and interpreting it into a clear diagnosis (most likely cause) and a suggested next step without taking any action itself.

# Task 8 — Recover Manually, Verify Again, and Write the Incident Summary

## Goal

Recover the service as the human operator and prove that the system is healthy again.

### Evidence

#### Screenshot 16 — Output showing Nginx is active and `curl -I http://localhost` returns 200 OK

Add your screenshot here.
![Screenshot16](<screenshots/Screenshot16 Task8 Assign6.png>)
/

#### Screenshot 17 — Second `/linux-triage` output showing successful recovery with no FAIL results

Add your screenshot here.
![Screenshot17](<screenshots/screenshot17 Task8 Assign6.png>)
![Screenshot17.1](<screenshots/Screenshot17 more Task8 Assign6.png>)



#### Screenshot 18 — Output of `ls -lah reports` showing both `incident-failure-report.txt` and `recovery-report.txt`

Add your screenshot here.
![Screenshot18](<screenshots/Screenshot18 Task8 Assign6.png>)


#### Screenshot 19 — `incident-summary.md` showing all required sections and your Full Name

Add your screenshot here.
![Screenshot19](<screenshots/Screenshot19 Task8 Assign6.png>)


### Notes

Answer the following in your own words:

**1. What action did you execute manually?**

Add your answer here.

I manually executed sudo systemctl start nginx to restart the stopped Nginx service after reviewing Claude's suggested recovery command through the /linux-triage skill.

**2. What evidence proves that the service recovered?**

Add your answer here.

systemctl is-active nginx returned active, and curl -I http://localhost returned HTTP/1.1 200 OK with full response headers. Additionally, re-running the /linux-triage skill confirmed all six checks passed, with an overall status of HEALTHY and exit code 0.

**3. Why is the second triage run necessary?**

Add your answer here.

The second triage run provides independent objective confirmation that recovery actually worked rather than just assuming the fix succeeded because I ran a command. This mirrors real incident response practice: verification must be evidence-based not assumed since a recovery command could fail silently or only partially fix the issue.

**4. What could go wrong if an AI agent automatically restarted every failed service?**

Add your answer here.

Automatically restarting failed services without human review could mask deeper problems for example, if a service is crash-looping due to a bad deployment or corrupted config blindly restarting it repeatedly wouldn't fix the root cause and could even cause additional issues (like repeated downtime, log spam, or resource exhaustion from constant restart attempts). It could also take destructive action based on an incomplete or incorrect diagnosis potentially making an incident worse rather than better. Human review ensures context and judgment are applied before any state-changing action.

**5. In one sentence, explain the difference between using AI as a chatbot and using AI in this agentic workflow.**

Add your answer here.

Using AI as a chatbot means asking questions and getting answers based on general knowledge or assumptions while using AI in this agentic workflow means the AI gathers real verifiable evidence from an actual system reasons over that specific evidence and still leaves all consequential actions to a human  making the process grounded safe  and accountable rather than speculative.

# Incident Summary

Fill in all seven sections below in your own words.

**Full Name:** Maida Sehar

**Date:** 16/07/2026

---

**1. Reported Symptom**

Add your answer here.

Nginx service became inactive and the deployed React application became inaccessible HTTP requests to the server returned no response (connection refused).

**2. Evidence Collected**

Add your answer here.

The linux-triage.sh script and the /linux-triage skill confirmed three failed checks: Nginx service inactive, no listener on port 80, and HTTP response code 000 (no response). Memory, disk, and error logs were all normal, ruling out resource exhaustion or a crash as the cause.

**3. Most Likely Cause**

Add your answer here.

Nginx was stopped (in this case, deliberately, to simulate an incident). The clean error log combined with the simultaneous failure of all three service related checks pointed clearly to the service simply not running rather than a configuration or resource problem.

**4. Human-Approved Recovery Action**

Add your answer here.

I manually executed sudo systemctl start nginx after reviewing Claude's suggested recovery command Claude did not execute this command itself at any point.

**5. Verification**

Add your answer here.

After recovery, I re-ran the triage script and the /linux-triage skill, confirming all six checks passed: Nginx active, port 80 listening, HTTP 200 OK, healthy memory/disk usage, and no errors in the log. Exit code returned to 0 (HEALTHY).

**6. Safety Decision**

Add your answer here.

Throughout this exercise, Claude only gathered evidence and suggested a recovery command it never executed any system changing command itself. This enforced the human in the loop principle defined in CLAUDE.md and SKILL.md ensuring I remained the sole decision maker for any action affecting the live server.

**7. Agentic Loop Mapping**

Add your answer here.

Gather = Bash script execution (linux-triage.sh) collecting read-only evidence; Analyze = Claude's explanation via the /linux-triage skill, interpreting that evidence into a diagnosis; Human Act = my manual execution of sudo systemctl start nginx; Verify = re-running the triage script/skill and confirming HEALTHY status with exit code 0.

# LinkedIn Post (Required)

## Evidence

#### LinkedIn Post URL

Paste your LinkedIn post URL here:

`__________________________`

https://www.linkedin.com/posts/maida-sehar-2ab997263_dmicohort3-devops-agenticai-ugcPost-7483581623951785984-l60R/?utm_source=share&utm_medium=member_desktop&rcm=ACoAAEDAZeMBfFjix-eqjklKqLfUwTxMrs40I1Q

#### Screenshot — Published LinkedIn post

Add your screenshot here.
![Screenshot](<screenshots/Linkedin post Assign6 Week 3.png>)


# GitHub Repository URL

Paste the URL of your GitHub folder or repository containing the assignment files here:

`__________________________`

https://github.com/maidasehar-dev/devops-micro-internship-pravinmishra/tree/main/week-03-linux-and-bash-for-devops

# Submission Instructions

- Add all required screenshots in your submission
- Full Name must be visible in required screenshots and the Bash report
- All written answers must be in your own words
- Do not expose sensitive information (keys, passwords, AWS account IDs, tokens)
- GitHub URL must be included in this document

---

# Completion Checklist

- [x] Task 1: Healthy baseline confirmed, workspace created (Screenshots 1–2, Notes answered)
- [x] Task 2: CLAUDE.md created with all four sections (Screenshot 3, Notes answered)
- [x] Task 3: Five-check plan produced by Claude using read-only tools (Screenshot 4, Notes answered)
- [x] Task 4: `linux-triage.sh` created, syntax validated, executable permission set (Screenshots 5–8, Notes answered)
- [x] Task 5: Healthy-state report generated with no FAIL result (Screenshots 9–10, Notes answered)
- [x] Task 6: `/linux-triage` skill created and run successfully on healthy server (Screenshots 11–12, Notes answered)
- [x] Task 7: Nginx incident simulated, failed evidence captured, Claude did not execute recovery (Screenshots 13–15, Notes answered)
- [x] Task 8: Nginx recovered manually, recovery verified, reports saved, incident summary complete (Screenshots 16–19, Notes answered)
- [x] Incident summary contains all seven required sections
- [x] LinkedIn post published and URL submitted
- [x] Full Name visible in all required screenshots and the Bash report
- [x] Skill does not have Write permission
- [x] Skill did not execute any recovery commands
- [x] No sensitive data exposed

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