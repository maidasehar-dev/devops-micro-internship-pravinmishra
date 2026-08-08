# Assignment 4 — Gotto Job: Backlog Refinement & Sprint 1 in Jira

Part of the DevOps Micro Internship (DMI) Cohort 3 with Agentic AI

---

## Purpose

In this 90-minute, time-boxed exercise, you will act as a Scrum team — or run in Solo Mode, playing every role yourself — to turn the Gotto Job template into a value-ordered backlog, estimate the work in story points, plan Sprint 1, open the burndown chart, and ship one small UI-only increment (text, color, spacing, a label, or a CTA — no backend changes).

---

# Task 1 — Roles & Mode Setup (Team vs Solo)

## Goal

Choose Team Mode or Solo Mode, and document how each Scrum role (Product Owner, Scrum Master, Dev Lead, DevOps Lead) was handled.

### Evidence

#### Screenshot 1 — Jira "Create project" screen, or the project sidebar after creation

![Screenshot1](<screenshots/Screenshot1 Task 1 Assign4 Week5.png>)


### Notes

Write one line for each role: PO (what you prioritized), SM (how you ensured process), Dev Lead (what you built), DevOps Lead (how you shipped).

PO (Product Owner): I prioritized the backlog by ranking Stories based on visible user impact and trust-building value placing the highest-value UI improvements at the top of the backlog.

SM (Scrum Master): I timeboxed the exercise followed Scrum ceremonies (backlog refinement, sprint planning, retrospective) and kept myself accountable to completing each step in sequence.

Dev Lead: I implemented the chosen UI Story (hero tagline update) by editing the HTML directly in the Gotto Job template.

DevOps Lead: I committed the change via Git deployed it to AWS EC2 using scp/ssh and verified it was live on the public URL.

# Task 2 — Create the Jira Project (Team-managed → Scrum)

## Goal

Create a Team-managed Scrum project named `Gotto Job – Team <#>` (Team Mode) or `Gotto Job – <YourName>` (Solo Mode).

### Evidence

#### Screenshot 2 — Project created page showing the project name and key

![Screenshot2](<screenshots/Screenshot2 Task2 Assign4 Week5.png>)


# Task 3 — Create the Epic

## Goal

Create the Epic `Improve Gotto Job UI discoverability & trust` to group the UI improvement initiative.

### Evidence

#### Screenshot 3 — Backlog showing the Epic panel with the Epic visible

![Screenshot3](<screenshots/Screenshot3 Task3 Assign4 Week5.png>)


# Task 4 — Seed the Product Backlog (6–8 Stories + Fibonacci Points + Ranking)

## Goal

Create at least six Stories under the Epic, estimate each with 1, 2, or 3 story points, and rank them by value.

### Evidence

#### Screenshot 4 — Backlog showing the Epic and at least six Stories under it

![Screenshot4](<screenshots/Screenshot4 Task4 Assign4 Week5.png>)


#### Screenshot 5 — One Story opened showing its Story Points and acceptance criteria filled in

![Screenshot5](<screenshots/Screenshot5 Task4 Assign4 Week5.png>)


# Task 5 — Planning Poker (Estimate + Debate Notes)

## Goal

Confirm the Story Points (1, 2, or 3) for each Story and record brief reasoning for each estimate.

### Evidence

#### Screenshot 6 — Backlog showing Story Points visible, or two or three Stories opened showing their points

![Screenshot6](<screenshots/Screenshot6 Task5 Assign4 Week5.png>)


### Notes

For each story, explain in one or two lines why it is a 1, 2, or 3 (mention any debate, even in Solo Mode).

S1 – Hero tagline (1 point): This only requires changing one heading, so it is a small, straightforward task.

S2 – Button colour (1 point): Only the button colour needs to be updated. I briefly considered 2 points since it affects multiple buttons across the site, but kept it at 1 since it's a simple CSS change.

S3 – Job card typography (2 points): Requires changing font size and weight, then checking the layout still holds up correctly across different screen sizes.

S4 – REMOTE badge (2 points): Involves adding a new badge element and conditionally displaying it only for remote jobs, making it slightly more complex than a simple text change.

S5 – Posted on date (1 point): A simple text addition with no extra logic.

S6 – Search labels (2 points): Several labels and placeholders need to be updated and tested across both the simple and advanced search forms, so it requires more work than a single text change.

S7 – Job Detail "Apply Now" Button (1 point): Adds a single button linking to an email/placeholder. Simple change with no additional logic.

S8 – Footer Trust Links (1 point): Adds two footer links ("About" and "Contact"). Only a small HTML update with no complex functionality.

Total backlog points across all 8: 1+1+2+2+1+2+1+1 = 11 points


# Task 6 — Sprint Planning: Create Sprint 1 + Sprint Goal + Scope

## Goal

Create Sprint 1, move three or four Stories into it (approximately 3–6 points), set the Sprint Goal, and break each selected Story into Build, Verify, Deploy, and Screenshot Sub-tasks.

### Evidence

#### Screenshot 7 — Sprint 1 with the selected Stories inside it

![Screenshot7](<screenshots/Screenshot7 Task6 Assign4 Week5.png>)


#### Screenshot 8 — One Story showing the Sub-tasks created

![Screenshot8](<screenshots/Screenshot8 Task6 Assign4 Week5.png>)


# Task 7 — Reports: Open Burndown Chart

## Goal

Open the Burndown Chart and confirm it exists for Sprint 1. It is acceptable if the chart is not yet populated.

### Evidence

#### Screenshot 9 — Burndown Chart page opened, even if empty

![Screenshot9](<screenshots/Screenshot9 Task7 Assign4 Week5.png>)


# Task 8 — Ship One Small Increment (Build + Deploy + Proof)

## Goal

Implement one small UI-only Story from Sprint 1, commit it, deploy it live, and move the Story and its Sub-tasks to Done in Jira.

### Evidence

#### Screenshot 10 — Jira board showing the Story moved to Done

![Screenshot10](<screenshots/Screenshot10 Task8 Assign4 Week5.png>)


#### Screenshot 11 — Git commit output

![Screenshot11](<screenshots/Screenshot11 Task8 Assign4 Week5.png>)


#### Screenshot 12 — Live URL in the browser showing the UI change, with the URL visible

![Screenshot12](<screenshots/Screenshot12 Task8 Assign4 Week5.png>)


# Task 9 — Retro Notes (Scrum Pillar + Value)

## Goal

Add a retro comment covering what went well, what to improve, one Scrum pillar observed (Transparency, Inspection, or Adaptation), and one Scrum value (Openness, Focus, Commitment, Courage, or Respect).

### Evidence

#### Screenshot 13 — Jira retro comment visible

![Screenshot13](<screenshots/Screenshot13 Task9 Assign4 Week5.png>)


# Task 10 — LinkedIn Post (Mandatory)

## Goal

Publish a LinkedIn post about what you delivered, including your live URL, three to five lines on what you did and learned, and one screenshot (Burndown Chart, Sprint board, or the live UI change).

## Evidence

#### LinkedIn Post URL

https://www.linkedin.com/posts/maida-sehar-2ab997263_devops-agile-scrum-share-7491854268983910400-7D9j/?utm_source=share&utm_medium=member_desktop&rcm=ACoAAEDAZeMBfFjix-eqjklKqLfUwTxMrs40I1Q


#### Screenshot 14 — Published LinkedIn post

![Screenshot14](<screenshots/Linkedind post screenshot for Assign4 week5.png>)


# Submission Instructions

- Add all 14 required screenshots
- Full name must be visible in required screenshots
- Do not expose sensitive information (keys, passwords, account IDs)

---

# Completion Checklist

- [x] Task 1: Team Mode or Solo Mode selected and all four roles documented (Screenshot 1 & Notes)
- [x] Task 2: Team-managed Scrum project created with the required name (Screenshot 2)
- [x] Task 3: UI improvement Epic created (Screenshot 3)
- [x] Task 4: 6–8 Stories added under the Epic and ranked by value (Screenshots 4 & 5)
- [x] Task 5: Story Points set (1, 2, or 3) with reasoning recorded (Screenshot 6 & Notes)
- [x] Task 6: Sprint 1 created with Sprint Goal, 3–4 Stories, and Sub-tasks (Screenshots 7 & 8)
- [x] Task 7: Burndown Chart opened (Screenshot 9)
- [x] Task 8: One UI-only increment implemented, committed, deployed, and verified (Screenshots 10–12)
- [x] Task 9: Retro comment with one Scrum pillar and one Scrum value (Screenshot 13)
- [x] Task 10: Mandatory LinkedIn post published with the live URL, backlog refinement, Sprint planning, one shipped increment, proof, and Screenshot 14
- [x] Full Name visible in required screenshots
- [x] No sensitive data exposed

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
