# Assignment 4 — Building Your AI Team

Part of the DevOps Micro Internship (DMI) Cohort 3 with Agentic AI

---

## Purpose

In this assignment, you will build and configure a set of specialized AI subagents inside your project. You will learn how different models and tool permissions define agent behavior, and you will trigger two real agent delegations to analyze security and cost aspects of your Terraform infrastructure.

---

# Task 1 — Create the Agents Folder and Add Files

## Goal

Create the `.claude/agents/` directory and add all required agent files.

### Evidence

#### Screenshot 1 — VS Code sidebar showing `.claude/agents/` with all 3 files

Add your screenshot here.
![Screenshot1](<screenshots/Screenshot 1 Assignment 4 task 1.png>)


# Task 2 — Compare the Agent Configurations

## Goal

Analyze the configuration differences between the three agents and demonstrate understanding of model and tool selection.

### Written Answers

#### 1. Why does the cost optimizer use Haiku instead of Sonnet?

Add your answer here...

Cost optimization is a fairly mechanical, checklist-style task — matching known patterns like CloudFront price class or S3 storage class against a fixed set of rules. It doesn't require deep reasoning the way a security audit does, so a smaller, faster, cheaper model like Haiku is sufficient and keeps this frequently-run check fast and low-cost.

#### 2. Why does the security auditor NOT have Write in its tools list?

Add your answer here...

An auditor's job is to observe and report, not to make changes — giving it Write access would let it silently modify infrastructure while reviewing it, which blurs the line between "finding issues" and "fixing issues" and removes the human review step in between. Keeping it read-only (Read, Grep, Glob) ensures it can never accidentally alter the very files it's supposed to be objectively assessing.

#### 3. Why does the tf-writer use `inherit` instead of a specific model?

Add your answer here...

`inherit` means tf-writer uses whatever model is currently active in the main session, rather than being locked to one model. Since writing production Terraform code benefits from the strongest reasoning available at the time, inheriting keeps it aligned with whatever model the user has chosen for the session, instead of being stuck on a fixed model that might be weaker or outdated.

### Evidence

#### Screenshot 2 — `security-auditor.md` frontmatter showing model and tools configuration

Add your screenshot here.
![Screenshot2](<screenshots/Screenshot 2 Assignment 4 task 2.png>)


#### Screenshot 3 — `cost-optimizer.md` frontmatter showing the model and tools configuration

Add your screenshot here.
![Screenshot3](<screenshots/Screenshot3 Assignment 4.png>)

# Task 3 — Run the Security Auditor

## Goal

Trigger the security auditor agent and analyze the generated security report for your Terraform infrastructure.

### Evidence

#### Screenshot 4 — The delegation message showing Claude launched the security-auditor

Add your screenshot here.
![Screenshot4](<screenshots/Screenshot4 Assignment 4 task 3.png>)


#### Screenshot 5 — Security audit report output

Add your screenshot here.
![Screenshot5](<screenshots/Screenshot 5Assignment 4 task 3 A.png>)
![Screenshot5](<screenshots/Screenshot 5 Assignment 4 task 3B.png>)



# Task 4 — Run the Cost Optimizer

## Goal

Trigger the cost optimizer agent and review the generated cost optimization report.

### Evidence

#### Screenshot 6 — The full cost optimization report

Add your screenshot here.
![Screenshot6](<screenshots/Screenshot 6 Assignment 4 task 4A.png>)
![Screenshot6](<screenshots/Screenshot 6 Assignment 4 Task 4B.png>)




# Submission Instructions

- Ensure all agent files are committed in `.claude/agents/`
- Complete all written answers in your GitHub Repo
- Push final changes to your forked GitHub repository

---

## GitHub Repository URL

Paste your forked repository URL here:

`https://github.com/maidasehar-dev/Ultimate-Agentic-DevOps-with-Claude-Code`

https://github.com/maidasehar-dev/Ultimate-Agentic-DevOps-with-Claude-Code

# Completion Checklist

- [x] `.claude/agents/` folder contains all 3 agent files
- [x] Screenshot 2 shows correct `security-auditor.md` configuration
- [x] Screenshot 3 shows correct `cost-optimizer.md` configuration
- [x] All 3 written answers completed 
- [x] Security auditor executed successfully
- [x] Cost optimizer executed successfully
- [x] Security report is visible with findings
- [x] Cost report is visible with recommendations
- [x] All required screenshots added
- [x] GitHub repo updated with agents

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