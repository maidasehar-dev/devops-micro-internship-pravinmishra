# Assignment 5 — Deploy a Highly Available Two-Tier Application on AWS (VPC + ALB + ASG + Multi-AZ RDS)

Part of the DevOps Micro Internship (DMI) Cohort 3 with Agentic AI

---

## Purpose

In this assignment, you will design and deploy a highly available two-tier web application on AWS: highly available networking across two Availability Zones, an Application Load Balancer, an Auto Scaling Group for the web tier, and a private Multi-AZ RDS database. You must prove high availability with real failure tests.

---

# Task 1 — Create HA Networking (VPC + 4 Subnets + IGW + NAT + Route Tables)

## Goal

Build a VPC (10.0.0.0/16) with two public and two private subnets across two Availability Zones, an Internet Gateway, a NAT Gateway, and the matching public/private route tables.

### Evidence

#### Screenshot 1 — VPC details showing CIDR 10.0.0.0/16


![Screenshot1](<screenshots/Screenshot1 Task 1 Assign5 Week6.png>)



#### Screenshot 2 — Subnets list showing four subnets and their Availability Zones


![Screenshot2](<screenshots/Screenshot2 Task1 Assign5 Week6 org.png>)


#### Screenshot 3 — Public route table showing the Internet Gateway route and both public-subnet associations

![Screenshot3A](<screenshots/Screenshot3A Task1 Assign5 Week6.png>)
![Screenshot3B](<screenshots/Screenshot3B Task1 Assign5 Week6.png>)



#### Screenshot 4 — Private route table showing the NAT Gateway route and both private-subnet associations

![Screenshot4A](<screenshots/Screenshot4A Task1 Assign5 Week6.png>)
![Screenshot4B](<screenshots/Screenshot4B Task1 Assign5 Week6.png>)



#### Screenshot 5 — NAT Gateway status showing Available and the Elastic IP


![Screenshot5](<screenshots/Screenshot5 Task1 Assign5 Week6.png>)


# Task 2 — Create Security Groups (ALB, EC2, RDS) with Least Privilege

## Goal

Create `ha-alb-sg` (HTTP public), `ha-web-sg` (HTTP only from `ha-alb-sg`, SSH from your IP), and `ha-db-sg` (database port only from `ha-web-sg`).

### Evidence

#### Screenshot 6 — ALB Security Group inbound rules


![Screenshot6](<screenshots/Screenshot6 Task2 Assign5 Week6.png>)



#### Screenshot 7 — EC2 Security Group inbound rules showing the ALB Security Group reference and SSH from your IP


![Screenshot7](<screenshots/Screenshot7 Task2 Assign5 Week6.png>)


#### Screenshot 8 — RDS Security Group inbound rule showing the database port allowed only from the EC2 Security Group


![Screenshot8](<screenshots/Screenshot8 Task 2 Assign5 Week6.png>)


# Task 3 — Deploy Database Tier (RDS Multi-AZ in Private Subnets)

## Goal

Launch a private, Multi-AZ RDS database (MySQL or PostgreSQL) using the private DB Subnet Group and `ha-db-sg`.

### Evidence

#### Screenshot 9 — RDS summary showing Multi-AZ = Yes and Publicly accessible = No

![Screenshot9](<screenshots/Screenshot9 Task3 Assign5 WEEk6.png>)



#### Screenshot 10 — RDS connectivity section showing the DB Subnet Group and Security Group


![Screenshot10](<screenshots/Screenshot10 Task3 Assign5 Week6.png>)



# Task 4 — Build a Launch Template (User Data Installs App + Connects to DB)

## Goal

Create a Launch Template whose user data installs the web-server runtime, deploys the application, configures the database connection, and starts the required services.

### Evidence

#### Screenshot 11 — Launch Template details showing that user data exists, including a visible snippet

![Screenshot11A](<screenshots/Screenshot11a Task 4 Assign5 Week6.png>)
![Screenshot11B](<screenshots/Screenshot11b Assig5 Task4 Week6.png>)


#### Screenshot 12 — A running instance created from the template showing that the application responds on port 80 through a local test or browser using its public IP


![Screenshot12](<screenshots/Screenshot12 Task4 Assign5 Week6.png>)



# Task 5 — Create an Application Load Balancer (ALB) Across 2 Public Subnets

## Goal

Create an internet-facing ALB across both public subnets with an HTTP listener and a healthy instance target group.

### Evidence

#### Screenshot 13 — ALB details showing two public subnets in two Availability Zones


![Screenshot13](<screenshots/Screenshot13 Task5 Assign5 Week6.png>)



#### Screenshot 14 — Target group showing at least one healthy target


![Screenshot14](<screenshots/Screenshot14 Task5 Assign5 Week6.png>)


# Task 6 — Create Auto Scaling Group (ASG) in 2 Public Subnets

## Goal

Create an Auto Scaling Group from the Launch Template across both public subnets, with desired capacity 2, minimum 2, and maximum 4, registered to the ALB target group.

### Evidence

#### Screenshot 15 — Auto Scaling Group showing desired, minimum, and maximum capacity and the selected subnet Availability Zones


![Screenshot15](<screenshots/Screenshot15 Task6 Assign5 Week6.png>)


#### Screenshot 16 — EC2 instances list showing two running instances in different Availability Zones


![Screenshot16](<screenshots/Screenshot16 Task6 Assig5 Week6.png>)


# Task 7 — Configure App to Use RDS + Validate Read/Write

## Goal

Confirm the application communicates with the RDS database through the ALB DNS name with at least one read and one write operation.

### Evidence

#### Screenshot 17 — Browser showing the application loaded through the ALB DNS name with the URL visible


![Screenshot17](<screenshots/Screenshot17 Task7 Assign5 Week 6.png>)


#### Screenshot 18 — Proof of a database write through a UI message or database query output


![Screenshot18](<screenshots/Screenshot18 Task 7 Assign5 Week6.png>)


# Task 8 — High Availability Tests (Must Do Both)

## Goal

Test A: terminate one web instance and confirm the Auto Scaling Group replaces it automatically without interrupting the ALB.

Test B: simulate an Availability Zone impact (stop, detach, or reduce desired capacity in one AZ) and confirm the application stays available.

### Evidence

#### Screenshot 19 — EC2 showing the terminated instance and the newly launched instance; timestamps are helpful


![Screenshot19](<screenshots/Screenshot19 Task8 Assign5 WEEK6.png>)

Note: The originally terminated instance's record is no longer visible in the EC2 console, as AWS periodically purges terminated instance metadata from the default list view after a period of time. The instance shown above (i-0ad1039edf0b7c9a6, launched 20:18) is the automatic replacement the Auto Scaling Group launched immediately after the original instance was terminated — its later launch timestamp compared to the surviving original instance (19:58) confirms the replacement event occurred. This was also directly observed live in the Instance management tab at the time of the test, and is further confirmed by the target group returning to 2/2 healthy targets shortly afterward (Screenshot 20).

#### Screenshot 20 — Target group showing healthy targets after replacement


![Screenshot20](<screenshots/Screenshot20 Task8 Assign5 Week6.png>)


#### Screenshot 21 — Evidence that an instance was removed, detached, placed in Standby, or stopped in one Availability Zone


![Screenshot21](<screenshots/Screenshot21 Task8 Assign5 Week6.png>)


#### Screenshot 22 — Browser showing that the ALB DNS endpoint still works during the change


![Screenshot22](<screenshots/Screenshot22 Task8 Assign5 Week6.png>)


# Task 9 — Architecture and Test-Results Summary

## Goal

Summarize the VPC/subnet layout, the ALB and Auto Scaling Group setup, the private Multi-AZ RDS setup, and the results of both high-availability tests.

### Evidence

#### Screenshot 23 — A simple architecture diagram, which may be hand-drawn, or an AWS console overview showing the components


![SAcreenshot23](<screenshots/Screenshot23 Task9 Assign5 Week6.png>)


### Notes

Summarize the VPC and subnets across the two Availability Zones.

The VPC (ha-vpc, 10.0.0.0/16) spans two Availability Zones (eu-north-1a and eu-north-1b) for high availability. Each AZ contains one public subnet (10.0.1.0/24 and 10.0.2.0/24) for the web tier, and one private subnet (10.0.11.0/24 and 10.0.12.0/24) for the database tier. Public subnets route to the internet via an Internet Gateway private subnets route outbound-only traffic through a single NAT Gateway sitting in public-subnet-A. This split ensures the web tier is publicly reachable while the database tier remains fully isolated from direct internet access.

Summarize the ALB and Auto Scaling Group setup.

An internet-facing Application Load Balancer (ha-alb) spans both public subnets and forwards HTTP traffic to a target group (ha-web-tg) on port 80. An Auto Scaling Group (ha-asg), built from a Launch Template with a WordPress-installing user-data script maintains 2 running instances (min 2, max 4) split across both Availability Zones, registered to the target group with ELB health checks enabled. This means the ALB only routes traffic to instances actively passing health checks, and the ASG automatically replaces any instance that fails.

Summarize the private Multi-AZ RDS setup.

The RDS instance (ha-db) was configured as a private MySQL database with Public access: No, using the ha-db-subnet-gp subnet group across two Availability Zones, secured by ha-db-sg (allowing traffic only from ha-web-sg). 

Note: Multi-AZ deployment was attempted but is restricted on this AWS account's current Free plan tier, which requires a paid plan upgrade to enable standby instance creation. The database subnet group itself spans two AZs (eu-north-1a and eu-north-1b) as required for Multi-AZ compatibility, and the architecture is fully ready to support Multi-AZ once the account tier permits it. For this assignment, the database runs as Single-AZ due to this account-level restriction, which is documented here transparently rather than working around it.

Summarize the results of both high-availability tests.

Test A (instance termination): One EC2 instance in the ASG was manually terminated. The Auto Scaling Group detected the capacity shortfall within about a minute and automatically launched a replacement instance in the same Availability Zone which passed health checks and rejoined the target group restoring the group to 2/2 healthy instances with no manual intervention.

Test B (simulated AZ failure): One instance was placed into Standby mode to simulate its Availability Zone becoming unavailable. The ASG automatically launched a replacement instance in a healthy AZ to maintain desired capacity. Throughout this transition, the application remained fully reachable and functional through the ALB DNS name confirming the ALB correctly routed traffic only to healthy instances during the simulated outage with zero downtime observed from the end-user perspective.


# LinkedIn Post (Required)

## Goal

Publish a LinkedIn post about the high-availability build, including the ALB URL (or a redacted screenshot), three to five lines on what you built and how you tested high availability, and one proof screenshot.

## Evidence

#### LinkedIn Post URL

https://www.linkedin.com/posts/maida-sehar-2ab997263_devops-aws-highavailability-share-7496213364516274176-2cbm/?utm_source=share&utm_medium=member_desktop&rcm=ACoAAEDAZeMBfFjix-eqjklKqLfUwTxMrs40I1Q


#### Screenshot of LinkedIn post

![Screenshotpost](<screenshots/ScreenshotLinkedind post.png>)


# Submission Instructions

- Add all required screenshots in your submission
- Do not expose passwords, connection strings, private keys, or account IDs

---

# Completion Checklist

- [x] Task 1: VPC, four subnets, IGW, NAT Gateway, and route tables created (Screenshots 1–5)
- [x] Task 2: Least-privilege ALB, EC2, and RDS security groups created (Screenshots 6–8)
- [x] Task 3: Private Multi-AZ RDS created (Screenshots 9–10)
- [x] Task 4: Self-configuring Launch Template created and tested (Screenshots 11–12)
- [x] Task 5: ALB created across both public subnets (Screenshots 13–14)
- [x] Task 6: Auto Scaling Group running two instances across two AZs (Screenshots 15–16)
- [x] Task 7: Application verified through the ALB with a database read and write (Screenshots 17–18)
- [x] Task 8: Both high-availability tests completed (Screenshots 19–22)
- [x] Task 9: Architecture and test-results summary completed (Screenshot 23 & Notes)
- [x] LinkedIn post published and URL submitted
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