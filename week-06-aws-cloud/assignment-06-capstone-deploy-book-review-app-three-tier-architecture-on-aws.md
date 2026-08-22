# Assignment 6 — Capstone Assignment — Deploy Book Review App (Three-Tier Architecture) on AWS

Part of the DevOps Micro Internship (DMI) Cohort 3 with Agentic AI

---

## Purpose

This is the most important assignment of the course. You will deploy the Book Review App in a fully production-style three-tier architecture on AWS: a Next.js Web Tier behind Nginx and a public ALB, a private Node.js/Express App Tier behind an internal ALB, and a private Multi-AZ MySQL RDS database with a read replica. You are expected to design, deploy, isolate, debug, and document the result independently.

---

# Task 1 — Architecture Diagram

## Goal

Create an architecture diagram showing the custom VPC (10.0.0.0/16), the six subnets across two Availability Zones (two public Web Tier, two private App Tier, two private Database Tier), the public ALB, Web Tier EC2/Nginx, internal ALB, private App Tier EC2, private Multi-AZ RDS with its read replica, and the permitted traffic flow.

### Evidence

#### Diagram image or link


![Diagra Image](<screenshots/book_review_three_tier_architecture Assign6 Week6.png>)

Note: This diagram reflects what was actually deployed. A Multi-AZ standby and a read replica for RDS were designed for and attempted but both are blocked on this AWS account's current Free plan tier (see Task 5 for details) the database subnet group and security groups are fully compatible with both features once the account tier permits it.


# Task 2 — AWS Region & Services Used

## Goal

Record the AWS Region used and list every AWS service used across networking, compute, load balancing, security, and the database.

### Notes

**Region:**

eu-north-1 (Stockholm)

**Services:**

Networking: VPC, 6 Subnets (2 public, 2 private-App, 2 private-DB), Internet Gateway, NAT Gateway, 3 Route Tables
Compute: 2 EC2 instances (Web tier running Nginx + Next.js, App tier running Node.js/Express)
Load Balancing: 2 Application Load Balancers (public-facing for the Web tier, internal for the App tier), 2 Target Groups
Security: 3 Security Groups (Web-SG, App-SG, DB-SG) chained in least-privilege order
Database: Amazon RDS for MySQL, private subnet group across 2 AZs


# Task 3 — Public Entry Point

## Goal

Confirm the Book Review App loads through the public ALB DNS name.

### Evidence

#### Public ALB DNS

http://book-review-web-alb-2072336848.eu-north-1.elb.amazonaws.com


# Task 4 — Evidence Screenshots

## Goal

Capture visual proof of every tier and load balancer.

### Evidence

#### Web EC2

![Screenshot1](<screenshots/Screenshot1 Task4 Assign6 Week6.png>)


#### App EC2

![Screenshot2](<screenshots/Screenshot2 task4 Assign6 Week6.png>)


#### Public ALB

![Screenshot3](<screenshots/Screenshot3 TASK4 Assign6 Week6.png>)


#### Internal ALB

![Screenshot4](<screenshots/Screenshot4 task4 Assign6 Week6.png>)


#### RDS + Replica

![Screenshot5](<screenshots/Screenshot5 task4 ASsign6 Week6.png>)


#### App UI proof


![Screenshot6](<screenshots/Screenshot6 Task4 Assign6 Week 6.png>)


# Task 5 — Summary

## Goal

Summarize what worked in the final deployment, the issues encountered and how each was fixed, and the tools or sources used to research and debug.

### Notes

**What worked:**

The full three-tier chain works end-to-end: the Public ALB correctly routes to the Web tier (Nginx reverse-proxying to Next.js) the frontend calls the App tier through the Internal ALB and the App tier (Node.js/Express via Sequelize) reads and writes to RDS over SSL. The bastion-host SSH pattern through the Web EC2 successfully reached the private App EC2 with no direct public exposure. Both services run persistently under PM2 and survived reconnects after a multi-hour break.


**Issues + fixes:**

1. Backend .env showed old placeholder values (DB_HOST=localhost) even after editing in nano fixed by clearing the file completely with Ctrl+K and retyping all values fresh then verifying with cat before proceeding.

2. Database authentication failed ("Access denied for user 'admin'") even with the correct password confirmed via the mysql CLI the .env value needed to be wrapped in double quotes because the password contained a special character that dotenv was truncating.

3. The frontend's API client explicitly warned not to include /api in the base URL but the backend's actual routes are registered under /api/* — set NEXT_PUBLIC_API_URL to the internal ALB DNS with /api appended to avoid a 404/routing mismatch.

4. Both true RDS Multi-AZ (automatic standby) and a read replica were attempted but are blocked on this AWS account's Free plan tier: Multi-AZ requires a paid upgrade to enable standby creation  and attempting the read replica hit a separate hard cap ("You reached the maximum number of instances available with free plan accounts"). Both are account-tier restrictions rather than architectural gaps the DB subnet group and security groups are fully compatible with both features and are documented transparently here rather than worked around consistent with the same Multi-AZ limitation hit in the previous assignment.

5. Reaching the private App EC2 instance (no public IP) required setting up a bastion-host SSH pattern: the private key was copied onto the public Web EC2 then used to SSH from there into the App EC2's private IP. This also required adding an explicit SSH rule to Book-Review-App-SG allowing traffic from Book-Review-Web-SG, since the initial "SSH from My IP" rule only covered direct connections from my own machine, not the hop through the Web tier.

6. The frontend showed "No books available" even after fixing the CORS/routing architecture because a hardcoded fetch in page.js appended its own /api/books directly to NEXT_PUBLIC_API_URL independently of the shared api.js helper once NEXT_PUBLIC_API_URL was set to /api (to route through Nginx's reverse proxy instead of the unreachable internal ALB directly) this hardcoded line produced /api/api/books and a 404. Fixed by removing the duplicate /api segment from that specific call and rebuilding.


**Tools/sources used:**

Write your answer here.

AWS Console documentation the app's own source code (server.js, config/db.js, services/api.js) to determine exact environment variable names and API path conventions and a web search to locate the canonical book-review-app repository (pravinmishraaws/book-review-app) since the solution guide referenced a co-mentor's personal fork.

# LinkedIn Post (Required)

## Goal

Publish a LinkedIn post sharing the capstone deployment, including the public ALB DNS (or a redacted screenshot), three to five lines on what you built and why it is production-style, and one proof screenshot.

## Evidence

#### LinkedIn Post URL

https://lnkd.in/p/eHrsjn9B


#### Screenshot of LinkedIn post


![Screenshot](<screenshots/Screenshot7 Linkedind Post Assign6 Week6.png>)


# Submission Instructions

- Add all required screenshots and links in your submission
- Do not expose passwords, RDS credentials, connection strings, private keys, or account IDs

---

# Completion Checklist

- [x] Task 1: Architecture diagram completed
- [x] Task 2: AWS Region and services documented
- [x] Task 3: Public ALB DNS confirmed working
- [x] Task 4: All six evidence screenshots captured (Web Tier, App Tier, both ALBs, RDS + replica, app UI)
- [x] Task 5: Deployment summary completed (what worked, issues/fixes, tools/sources)
- [x] LinkedIn post published and URL submitted
- [x] App Tier and Database Tier confirmed not publicly accessible
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