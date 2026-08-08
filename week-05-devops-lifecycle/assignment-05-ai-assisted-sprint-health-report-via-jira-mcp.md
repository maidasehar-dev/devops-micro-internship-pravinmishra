# Assignment 5 — AI-Assisted Sprint Health Report via Jira MCP

Part of the DevOps Micro Internship (DMI) Cohort 3 with Agentic AI

---

## Purpose

In this assignment, you will connect Claude Code to your Jira board through an MCP server, the same way you connected it to GitHub in Week 2, and build a read-only `/sprint-health` skill. The skill reads your current sprint through Jira's API and reports sprint velocity, stories at risk of missing the sprint, and items missing an estimate — but it must never create, edit, comment on, or transition a single ticket itself. You will prove that boundary holds by making a real change on the board yourself and confirming the skill only ever reports, never acts.

---

# Task 1 — Create a Jira API Token

## Goal

Generate an API token from your Atlassian account that the MCP server will use to authenticate with your Jira site. Do not screenshot the token value itself.

### Evidence

#### Screenshot 1 — Jira API token creation confirmation page showing the token name, with the token value not visible

![Screenshot1](<screenshots/Screenshot1 Task1 Assign5 Week5.png>)


### Notes You Must Write (Very Important):

Why does the MCP server need your site URL and account email in addition to the token?

Jira's REST API authenticates using Basic Auth, which requires both a username (the account email) and a secret (the API token) together the token alone doesn't identify which Atlassian account it belongs to. Additionally, Atlassian hosts many separate Jira instances so the site URL specifies exactly which instance to connect to (e.g., my-site.atlassian.net, not someone else's). In short: the token proves "this really is me," the email says "acting on behalf of this specific account," and the URL says "talk to this specific Jira site."

# Task 2 — Create .mcp.json at the Project Root

## Goal

Create or update `.mcp.json` at your project root with a Jira MCP server block, following the same shape as the GitHub MCP server you configured in Week 2.

### Evidence

#### Screenshot 2 — `.mcp.json` open in VS Code showing the Jira server configuration

![Screenshot2](<screenshots/Screenshot2 Task2 Assign5 Week5.png>)


### Notes You Must Write (Very Important):

Compare this jira block to the github block from Week 2 Assignment 5. The GitHub server ran via npx (a Node.js package); this one runs via uvx (a Python package) — what stays exactly the same shape despite that difference, and why doesn't Claude Code care which language a given MCP server is written in?

Even though the GitHub server runs via npx (Node.js) and the Jira server runs via uvx (Python) the overall structure of the config block stays identical: a "command" field (the program that launches the server), an "args" array (what package to run), and an "env" object (environment variables, left empty here since credentials live separately in settings.local.json). Claude Code doesn't need to know or care which language a given MCP server is implemented in, because MCP itself is a standardized protocol Claude Code just launches the specified command and communicates with it over that same protocol format. As long as the server correctly speaks MCP, the underlying implementation language is irrelevant, in the same way that a taxi service doesn't need to know what engine is under the hood, only that the vehicle can safely take a rider to their destination.


# Task 3 — Add Your Credentials to settings.local.json

## Goal

Add your Jira site URL, account email, and API token to `.claude/settings.local.json`, and confirm that file is listed in `.gitignore` so it is never committed.

### Evidence

#### Screenshot 3 — `settings.local.json` open in VS Code showing the `env` section, with the actual token value blurred or covered

![Screenshot3](<screenshots/Screenshot3 orig Task3 Assign5 Week5.png>)


### Notes You Must Write (Very Important):

Why must JIRA_API_TOKEN live in settings.local.json and never in .mcp.json?

JIRA_API_TOKEN must live in settings.local.json because .mcp.json is meant to be committed to the repository it only defines which MCP servers exist and how to launch them, not sensitive credentials. settings.local.json, by contrast is gitignored and stays purely local to each developer's machine. If the token were placed in .mcp.json instead it would get pushed to GitHub the moment that file was committed exposing the credential publicly (or to anyone with repo access) defeating the entire purpose of using a revocable, scoped API token rather than a hardcoded secret.


# Task 4 — Verify the Connection with /mcp

## Goal

Restart Claude Code and confirm the Jira MCP server shows as connected.

### Evidence

#### Screenshot 4 — `/mcp` output showing `jira: connected`

![Screenshot4](<screenshots/Screenshot4 Task4... Assign5 Week5.png>)


# Task 5 — Run a Live Query to Prove Real Board Data

## Goal

Ask Claude to list the issues in your current active sprint through the Jira MCP connection, and confirm the result matches what you see on your live board in the browser.

### Evidence

#### Screenshot 5 — Claude's response showing the live sprint issue list retrieved via Jira MCP

![screenshot5](<screenshots/Screenshot 5 Task5 Assign5 Week5.png>)


### Notes You Must Write (Very Important):

How did you confirm this was real board data and not something Claude guessed?

I confirmed this was real, live board data (not hallucinated) in several ways: the issue keys (GJMS-8, GJMS-5, GJMS-2) exactly match the actual Stories I created in Jira during Assignment 4; the returned data included clickable links directly to my real Jira instance (maidasehar2014.atlassian.net/browse/GJMS-X); the sprint dates (2026-08-08 → 2026-08-15) and Sprint Goal text matched exactly what I had set in Jira; and the assignee name (Maida sehar) matched my actual account. Additionally, I cross-checked this response against my live Jira Backlog/Board view in the browser and confirmed the same 3 issues, statuses, and labels appeared there too — the two sources were identical, confirming the MCP connection was pulling genuine live data rather than Claude generating a plausible-looking but fabricated response.


# Task 6 — Build the /sprint-health Skill

## Goal

Create a `/sprint-health` skill restricted to read-only Jira tools plus `Read`, with no issue-mutating tools and no `Write`. Run it and confirm it produces a report covering sprint velocity, at-risk stories, and items missing an estimate.

### Evidence

#### Screenshot 6 — `SKILL.md` frontmatter showing `allowed-tools` limited to read-only Jira tools plus `Read`, with `disable-model-invocation: true`

![Screenshot6](<screenshots/Screenshot6 Task6 Assign5 Week5.png>)


#### Screenshot 7 — `/sprint-health` output showing the full triage report against your real sprint

![Screenshot7](<screenshots/Screenshot7 Task6 Assign5 Week5.png>)

### Notes You Must Write (Very Important):

1. Which Jira MCP tools does this skill's allowed-tools list include, and which mutating tools (create issue, update issue, transition issue, add comment) does it deliberately exclude?

The skill's allowed-tools list includes only read-only Jira MCP tools: mcp__jira__jira_search, mcp__jira__jira_get_issue, mcp__jira__jira_get_sprint, mcp__jira__jira_get_board, and Read. It deliberately excludes any mutating tools — such as tools that would create an issue, update/edit an issue, transition an issue's status, add a comment, assign an issue, or delete an issue. By only listing read tools in allowed-tools, the skill is structurally incapable of taking any action on the board, regardless of what the retrieved data suggests should happen next.

2. Why does a Scrum Master need this restriction more than almost any other role in this course?

A Scrum Master's core responsibility is process facilitation and reporting — surfacing risks, tracking velocity, and prompting the team to make decisions — not unilaterally acting on the board themselves. If an AI assistant helping a Scrum Master had write access, it could silently reassign issues, change statuses, or edit descriptions based on its own interpretation of "what should happen," removing the human judgment and team discussion that Scrum ceremonies are built around. Restricting the skill to read-only ensures the AI's role stays exactly where it should: surfacing information and evidence, while every actual decision and board change remains in human hands — preserving the Scrum principle that the team, not a tool, owns and controls its own board.


# Task 7 — Prove the Skill Never Mutates the Board

## Goal

Manually update one ticket on your board in the browser (for example, move a story to "Done" or add a missing estimate), then run `/sprint-health` again and confirm the new report reflects your change — proving the skill only ever reads live state and never wrote to the board itself.

### Evidence

#### Screenshot 8 — Second `/sprint-health` run showing the report now reflects your manual board change

![Screenshot8](<screenshots/Screenshot8 Task7 Assign5 Week5.png>)

### Notes You Must Write (Very Important):

Map this assignment to Gather → Analyze → Human Act → Verify from Week 3 Assignment 6. Which step did you perform manually in the browser, and why must that step stay human?

This assignment maps cleanly onto the Gather → Analyze → Human Act → Verify cycle:

- Gather: The /sprint-health skill used read-only Jira MCP tools to pull live sprint data (issues, statuses, story points, timestamps) directly from the board.
- Analyze: The skill calculated velocity, flagged at-risk stories, identified missing estimates, and generated a report with evidence for each finding.
- Human Act: I performed this step manually in the browser — moving DMIWMS-16 from "To Do" to "In Progress" myself, directly in Jira's UI. This is the step that must stay human, because deciding to actually start work on a ticket, reassign it, or change its status is a judgment call about real progress and priorities — not something an AI should infer or execute on someone's behalf, even if the data suggests it "should" happen. The skill can surface that a ticket looks stalled, but only a person can decide whether to actually pick it up.
- Verify: Running /sprint-health a second time confirmed the report accurately reflected my manual change — proving the tool's read-only boundary held even after a real change occurred on the board, and that Gather/Analyze stayed correctly separated from Human Act throughout.



# Submission Instructions

Complete all tasks in sequence.

Your submission must include:
- All 8 required screenshots
- All the required notes

---

# Completion Checklist

- [x] Task 1: Jira API token created, value never screenshotted (Screenshot 1)
- [x] Task 2: `.mcp.json` has the Jira server block (Screenshot 2)
- [x] Task 3: Credentials stored in `settings.local.json`, token blurred, file gitignored (Screenshot 3)
- [x] Task 4: `/mcp` shows the Jira server connected (Screenshot 4)
- [x] Task 5: Live query returned real sprint data, verified against the browser (Screenshot 5)
- [x] Task 6: `/sprint-health` skill created with correct read-only `allowed-tools`, and produced a full report (Screenshots 6–7)
- [x] Task 7: A manual board change was reflected in a second `/sprint-health` run (Screenshot 8)
- [x] Skill never created, edited, transitioned, or commented on any issue
- [x] Reflection answered (Notes)
- [x] No API token value exposed

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
