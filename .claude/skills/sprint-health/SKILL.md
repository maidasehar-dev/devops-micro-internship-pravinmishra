\---

name: sprint-health

description: Reads the current active sprint via Jira MCP and produces a read-only triage report — velocity so far, at-risk stories, and items missing estimates. Never creates, edits, comments on, or transitions a Jira issue.

allowed-tools: mcp\_\_jira\_\_jira\_search, mcp\_\_jira\_\_jira\_get\_issue, mcp\_\_jira\_\_jira\_get\_sprint, mcp\_\_jira\_\_jira\_get\_board, Read

disable-model-invocation: true

\---



\# Sprint Health Skill



When `/sprint-health` is invoked:



1\. Use the Jira MCP read tools to find the current active sprint on the project's Scrum board.

2\. Retrieve every issue in that sprint: status, assignee, story points, and last-updated timestamp.

3\. Calculate:

&#x20;  - Sprint velocity so far: story points in "Done" versus total points committed

&#x20;  - Days remaining in the sprint

&#x20;  - Stories at risk: still "To Do" or "In Progress" with few days remaining, or with no update in several days

&#x20;  - Items with no story point estimate, or with no acceptance criteria in the description

4\. Report in this order:

&#x20;  - Sprint name and days remaining

&#x20;  - Velocity so far (points done / points committed)

&#x20;  - At-risk stories, with the exact evidence (status, last update, points) for each

&#x20;  - Items missing an estimate or acceptance criteria

&#x20;  - One suggested talking point for standup — phrased as a question for the human Scrum Master to raise, not an instruction to act

5\. Do not call any Jira MCP tool that creates, edits, comments on, or transitions an issue.

6\. Do not use `Write`.

7\. Never take an action on the board. Only report. The Scrum Master decides and acts manually.

