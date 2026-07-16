# Assignment 3 — Production Maintenance Drill (OPS Checklist)

Part of the DevOps Micro Internship (DMI) Cohort 3 with Agentic AI

---

## Purpose

In this assignment, you will treat your already deployed React application (on Ubuntu VM with Nginx) as a live production system. You will perform structured operational checks covering network validation, service health, log analysis, resource monitoring, configuration verification, and incident simulation with recovery — mirroring real on-call DevOps responsibilities.

---

# Task 1 — Server Access & Networking Validation

## Goal

Verify that the deployed React application is reachable from the browser and confirm basic network connectivity of the Ubuntu VM.

### Evidence

#### Screenshot 1 — Browser showing the React app with your Full Name visible on the UI

![Screenshot1](<screenshots/Screenshot 1 Task 1 Assign 3.png>)


#### Screenshot 2 — Output of `ip a`

![Screenshot2](<screenshots/Screenshot2 Task 1Assign 3.png>)


#### Screenshot 3 — Output of `sudo ss -tulpen`

![Screenshot3](<screenshots/Screenshot3 Task 1 Assign 3.png>)


#### Screenshot 4 — Output of `sudo ufw status`

![Screenshot4](<screenshots/Screenshot4 Task 1 Assign3.png>)


### Notes

Answer the following in your own words:

**1. What proves Nginx is listening on 0.0.0.0:80?**

In the sudo ss -tulpen output, I can see a line showing 0.0.0.0:80 with the process listed as nginx. This confirms Nginx is actively listening for connections on port 80 across all network interfaces.

**2. What proves SSH is active on port 22?**

Similarly, the ss -tulpen output shows 0.0.0.0:22 with the process sshd, confirming SSH is listening on port 22 across all interfaces, allowing remote connections.

**3. Did you find any unexpected open ports? Explain briefly.**

No unexpected open ports were found. Besides SSH (22) and Nginx (80), which are intentionally exposed, the only other listening ports were 53 (DNS resolution via systemd-resolved), 323 (time synchronization via chrony), and 68 (DHCP client via systemd-networkd). Importantly, all of these additional services are bound only to localhost addresses (127.0.0.1, 127.0.0.53, 127.0.0.54) or the internal network interface, not to 0.0.0.0, meaning they aren't accessible from the public internet — only SSH and Nginx are externally reachable. This is a healthy, expected configuration for a basic web server.

# Task 2 — Service Health & Systemd Validation (Nginx)

## Goal

Verify that Nginx is properly installed, running, enabled at boot, and safely configured.

### Evidence

#### Screenshot 1 — Output of `systemctl status nginx --no-pager`

![Screenshot1](<screenshots/Screenshot1 Task2 Assign 3.png>)


#### Screenshot 2 — Output of `sudo nginx -t`

![Screenshot2](<screenshots/Screenshot2 Task2 Assign3.png>)


#### Screenshot 3 — Output of `sudo ss -lptn '( sport = :80 )'`

![Screenshot3](<screenshots/Screenshot3 Task2 Assign3.png>)


### Notes

Answer the following in your own words:

**1. What happens if Nginx fails to restart in production?**

If Nginx fails to restart, the server would stop responding to HTTP requests entirely, meaning the React app becomes completely inaccessible to users — resulting in downtime. In a real production environment, this could mean lost revenue, broken user experience, or failed health checks that could trigger alerts or even auto-scaling/replacement actions if using tools like AWS Auto Scaling or Kubernetes.

**2. What's your basic rollback plan?**

My rollback plan would be: (1) check sudo nginx -t to see if there's a configuration syntax error, (2) if the config is broken, restore the last known-good config file (ideally from a backup or version control), (3) run sudo systemctl restart nginx again, and (4) verify recovery with curl -I http://<public-ip> to confirm a 200 OK response. If Nginx itself is corrupted, reinstalling it (sudo apt install --reinstall nginx) would be the next step.

# Task 3 — Logs & Request Trace

## Goal

Verify real traffic flow and analyze logs to understand system behavior and errors.

### Evidence

#### Screenshot 1 — Output of `sudo tail -n 30 /var/log/nginx/access.log`

![Screenshot1](<screenshots/Screenshot1 Task3 Assign3.png>)


#### Screenshot 2 — Output of `sudo tail -n 30 /var/log/nginx/error.log`

![Screenshot2](<screenshots/Screenshot2 Task3 Assign3.png>)


#### Screenshot 3 — Output of `sudo journalctl -u nginx --no-pager -n 50`

![Screenshot3](<screenshots/Screenshot3 Task3 Assign3.png>)


### Notes

Answer the following in your own words:

**1. Were there any errors in the logs?**

- If yes, mention 1–2 example error lines from the logs and explain what each one means in simple terms.
- If no, explain what it means if the error log is empty or shows no recent errors during your check.

No errors were found in the error log. The only entry present was a routine startup notice ("using inherited sockets from '5;6;'"), which simply indicates Nginx reused existing network sockets during a restart — this is normal operational behavior, not an error.

**2. If there were no errors, what does that indicate about the system?**

An empty (or error-free) error log indicates the system is stable and healthy — Nginx has not encountered any issues serving requests, handling configuration, or with permissions/file access. It suggests the server is operating exactly as expected with no unresolved problems.

**3. Based on the access logs, were your curl requests visible in the log entries? What does that prove about traffic flow?**

Yes, my curl request was clearly visible in the access log, showing my server's own IP address and the user-agent curl/8.18.0, distinguishing it from browser-based traffic. This confirms that all HTTP traffic — regardless of source (browser or command-line tool) — is being logged and processed correctly by Nginx, proving the full request pipeline (client → Nginx → response) is functioning as expected. Interestingly, the access log also revealed automated bot traffic attempting a known router exploit against my server, which is normal background noise for any public-facing web server and reinforces the importance of keeping only necessary ports open (Task 8 discusses this further).

# Task 4 — System Resource Health Check (Capacity Red Flags)

## Goal

Assess server capacity and detect potential performance or failure risks.

### Evidence

#### Screenshot 1 — Output of `uptime`

![Screenshot1](<screenshots/Screenshot1 Task4 Assign3.png>)


#### Screenshot 2 — Output of `free -h`

![Screenshot2](<screenshots/Screenshot2 Task 4 Assign3.png>)


#### Screenshot 3 — Output of `df -h`

![Screenshot3](<screenshots/Screenshot3 Task4 Assign3.png>)


#### Screenshot 4 — Output of `sudo du -sh /var/* | sort -h`

![Screenshot4](<screenshots/Screenshot4 Task4 Assign3.png>)


### Notes

Answer the following in your own words:

**1. Which resource looks most critical right now? (CPU/load, memory, or disk) Explain why.**

Right now, none of the resources are in a critical state load average is at 0.00 (essentially idle), memory usage is around 38% with healthy availability, and disk usage is at 50% with 3.4GB still free. If I had to flag one to watch going forward, it would be disk usage, since it's already at the halfway mark on a small 6.7GB volume as more logs, builds, or dependencies accumulate over time, this could become a real constraint faster than CPU or memory would, given the server is a small t3.micro instance with limited storage.

**2. What happens if disk becomes 100% full in a production server?**

If disk usage reaches 100%, the server can no longer write new data — this can cause several cascading failures: the application may crash or fail to log errors, Nginx may be unable to write access/error logs, database writes (if any) would fail, and even basic system operations like package updates or temp file creation could break. In severe cases, the OS itself can become unstable if critical system logs or temp directories can't be written to. This is why monitoring disk usage and setting up alerts before reaching capacity is a standard production practice.

# Task 5 — Configuration & Deployment Verification

## Goal

Ensure the correct React build is deployed and Nginx is serving it properly.

### Evidence

#### Screenshot 1 — Output of `ls -lah /var/www/html | head -n 20`

![Screenshot1](<screenshots/Screenshot1 Task5 Assign3.png>)


#### Screenshot 2 — Output of `grep -R "Deployed by" -n /var/www/html 2>/dev/null | head`

![Screenshot2](<screenshots/Screenshot2 Task5 Assign3.png>)


#### Screenshot 3 — Output of `grep -n "try_files" /etc/nginx/sites-available/default`

![Screenshot3](<screenshots/Screenshot3 Task5 Assign3....png>)

### Notes

Answer the following in your own words:

**1. How do you confirm that the correct version of the application is deployed?**

To confirm the correct version is deployed, I checked multiple layers: first, ls -lah /var/www/html confirmed the build files (index.html, static assets, manifest.json) were present with the correct ownership (www-data). 
Second, since this is a React app, the actual personalized content ("Deployed by: Maida Sehar") isn't in the raw index.html  it's compiled into the JavaScript bundle so I searched the minified JS file directly (grep -o "Deployed by..." static/js/main.*.js) and confirmed my name appeared correctly, proving the personalized build (not a stale or default one) was deployed. 
Finally, I verified this visually by loading the app in the browser and seeing my name and date rendered on the page. Together, these three checks file presence, embedded content, and visual confirmation prove the correct version is live.
# Task 6 — Nginx Configuration Failure Simulation

## Goal

Simulate a real-world Nginx misconfiguration and recover the service safely.

### Evidence

#### Screenshot 1 — Output of `sudo nginx -t` showing the syntax error (broken config)

![Screenshot1](<screenshots/Screenshot1 Task6 Assign3.png>)


#### Screenshot 2 — Output of `sudo nginx -t` showing syntax ok (fixed config)

![Screenshot2](<screenshots/Screenshot2 Task6 Assign3.png>)


#### Screenshot 3 — Output of `curl -I http://<public-ip>` confirming recovery (200 OK)

![Screenshot3](<screenshots/Screenshot3 task6 Assign3.png>)


### Notes

Answer the following in your own words:

**1. What caused the configuration failure?**

The failure was caused by a syntax error in the Nginx configuration file — specifically, a missing semicolon at the end of the server_name _; directive. When I first tried to fix it, I accidentally introduced a second error (a stray character before the directive), which caused a different but related syntax failure. This demonstrates how even small, easy-to-miss typos in configuration files can bring down a web server entirely.

**2. How did you fix the issue?**

I used sudo nginx -t to test the configuration before reloading this is critical because it validates syntax without actually restarting the service, avoiding unnecessary downtime from a bad config. The error message pointed to the exact line and file, which let me open the file with nano, correct the missing semicolon (and the accidental stray character), and re-run nginx -t until it reported "syntax is ok." Only then did I reload Nginx with sudo systemctl reload nginx and verified recovery with curl -I, which returned a 200 OK.

**3. How can you avoid this kind of issue in real production systems?**

Several practices would help prevent this in production: 
(1) always run nginx -t before reloading or restarting Nginx never apply changes blindly.
(2) keep configuration files under version control (e.g. Git) so changes are tracked and can be rolled back instantly.
(3) take a backup before editing (as I did with default.backup).
(4) use configuration management tools like Ansible or Terraform to apply changes in a repeatable, tested way rather than manual edits.
(5) implement automated health checks or monitoring that alert immediately if a service goes down, rather than relying on manual discovery.

# Task 7 — Web Application Failure Simulation

## Goal

Simulate missing deployment content and recover the application safely.

### Evidence

#### Screenshot 1 — Output of `curl -I http://<public-ip>` showing failure (non-200 response)

![Screenshot1](<screenshots/Screenshot1 task7 Assign3.png>)


#### Screenshot 2 — Output of `curl -I http://<public-ip>` confirming recovery (200 OK)

![Screenshot2](<screenshots/Screenshot2 Task7 Assign3.png>)


### Notes

Answer the following in your own words:

**1. What caused the application to break in this scenario?**

The application broke because I deliberately deleted all the deployed build files from the Nginx web root (/var/www/html/*), simulating a scenario like an accidental rm -rf command, a failed deployment script, or a misconfigured cleanup job. With no files left to serve, Nginx returned a 500 Internal Server Error — since my custom config's fallback (try_files $uri /index.html;) also couldn't find index.html to serve, resulting in an internal error rather than a simple 404.

**2. How did you fix the issue and restore the application?**

Since I had proactively created a backup of the web root (/var/www/html_backup) before simulating the failure, recovery was straightforward — I simply copied the backup files back into /var/www/html/ using sudo cp -r /var/www/html_backup/* /var/www/html/, then verified recovery with curl -I, which confirmed a 200 OK response.

**3. What steps would you take to prevent this kind of issue in real production systems?**

To prevent this in real production: 
(1) never manually delete deployment directories without a backup or version control safety net.
(2) use automated CI/CD deployment pipelines instead of manual file copying, so deployments are consistent, tested, and reversible.
(3) keep the build artifacts in a versioned storage location (like S3 or a Git-based artifact repo) so any deployment can be instantly re-deployed if files are lost.
(4) implement monitoring/alerting (e.g. uptime checks) that immediately flags when the app returns non-200 responses.
(5) use blue-green or rolling deployments so a broken deployment never fully replaces a working one before being verified.

# Task 8 — Security & Reliability Review

## Goal

Review and reflect on the security and reliability practices applied during this assignment.

### Security & Reliability Notes

Answer the following in your own words:

**1. Why is SSH key-based authentication more secure than sharing passwords?**

SSH key-based authentication uses a cryptographic key pair (public and private) instead of a password. The private key never leaves my local machine, so even if someone intercepts network traffic, they can't extract a password to reuse. Passwords, by contrast, can be guessed, brute-forced, phished, or reused across multiple services, making them far more vulnerable. In my setup, only someone with my exact .pem file could authenticate to the server a much stronger guarantee than any password could provide.

**2. Why should only required ports be open on a production server?**

Every open port is a potential attack surface. During this assignment, I confirmed only ports 22 (SSH) and 80 (HTTP) were exposed to the internet — exactly what's needed for remote access and serving the web app. Opening unnecessary ports increases the risk of unauthorized access, misconfigured services being exploited, or automated bots scanning for vulnerabilities (as I actually observed in my Nginx access logs, where a bot attempted a known router exploit). Keeping the attack surface minimal is a core security principle.

**3. Why is it important for Nginx to be enabled on boot?**

If Nginx isn't enabled on boot, the application would go down after any server restart (e.g. due to maintenance, a crash, or an AWS instance reboot) and stay down until someone manually starts it again. Since we confirmed Nginx was enabled via systemctl status, it will automatically restart with the server, minimizing downtime and reducing dependency on manual intervention critical for production reliability.

**4. What are the risks of sharing secrets, keys, or credentials publicly?**

If secrets like SSH private keys, AWS credentials, or passwords are exposed (e.g. accidentally committed to a public GitHub repo), anyone could use them to access, modify, or destroy resources potentially deploying malicious code, stealing data, or racking up massive cloud costs. This is why I made sure to blur AWS account details in screenshots and never included the .pem key file in my git repository throughout this assignment.

**5. Why should cloud resources be stopped or terminated when they are no longer needed?**

Leaving cloud resources running unnecessarily wastes money (even within free tier, credits get consumed) and increases the attack surface an idle but running server is still a live target for attackers. That's why I stopped my EC2 instance overnight between assignments, only restarting it when I needed to continue work, following good cost and security hygiene practices.

# LinkedIn Post (Required)

## Evidence

#### LinkedIn Post URL

Paste your LinkedIn post URL here:

``

https://www.linkedin.com/posts/maida-sehar-2ab997263_devops-cloudcomputing-aws-ugcPost-7483176417392943104-Pm6r/?utm_source=share&utm_medium=member_desktop&rcm=ACoAAEDAZeMBfFjix-eqjklKqLfUwTxMrs40I1Q

#### Screenshot — Published LinkedIn post

![Screenshot](<screenshots/Linedind postshot For Assign3.png>)


# Submission Instructions

- Add all required screenshots in your submission
- Full name must be visible in required screenshots
- Do not expose sensitive information (keys, passwords, account IDs)

---

# Completion Checklist

- [x] Task 1: Screenshots (browser, ip a, ss -tulpen, ufw status) + Notes answered
- [x] Task 2: Screenshots (nginx status, nginx -t, ss port 80) + Notes answered
- [x] Task 3: Screenshots (access log, error log, journalctl) + Notes answered
- [x] Task 4: Screenshots (uptime, free -h, df -h, du -sh) + Notes answered
- [x] Task 5: Screenshots (ls html, grep deployed by, grep try_files) + Notes answered
- [x] Task 6: Screenshots (nginx -t fail, nginx -t pass, curl recovery) + Notes answered
- [x] Task 7: Screenshots (curl failure, curl recovery) + Notes answered
- [x] Task 8: Security & Reliability Notes answered
- [x] LinkedIn post published and URL submitted
- [x] Full Name visible in all required screenshots
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