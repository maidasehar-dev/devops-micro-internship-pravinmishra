# Assignment 5 — Bash Script Automation Drill (OPS Checklist)

Part of the DevOps Micro Internship (DMI) Cohort 3 with Agentic AI

---

## Purpose

In this assignment, you will practice Bash scripting by building a series of small automation scripts covering environment setup, variables, arrays, loops, file conditionals, if-else logic, and functions. These scripts form the foundation of real-world Linux automation used in DevOps, cloud, and production support environments.

---

# Task 1 — Bash Environment & Workspace Setup

## Goal

Verify that Bash is available on your system and create a clean workspace for this assignment.

### Evidence

#### Screenshot 1 — Output of `echo $SHELL` and `bash --version`

Add your screenshot here.
![Screenshot1](<screenshots/Screenshot1 Task1 Assignment5.png>)


#### Screenshot 2 — Output of `pwd` and `ls -lah` showing the scripts directory

Add your screenshot here.
![Screenshot2](<screenshots/Screenshot2 Task1 Assignment5.png>)


### Notes

Answer the following in your own words:

**1. What is Bash?**

Add your answer here.

Bash (Bourne Again SHell) is a command-line interpreter and scripting language used in Linux and Unix-based systems. It allows users to interact with the operating system by typing commands, and also allows those commands to be combined into scripts to automate repetitive tasks.

**2. What is the difference between shell and Bash?**

Add your answer here.

"Shell" is a general term for any program that provides a command-line interface to interact with the operating system there are many different shells (sh, zsh, ksh, Bash, etc.). Bash is one specific widely used implementation of a shell. So Bash is a type of shell not a separate concept similar to how "car" is a general category and "Toyota Corolla" is one specific model.

**3. Why is it important to confirm the Bash version before writing scripts?**

Add your answer here.

Different Bash versions support different features and syntax some newer scripting features (like certain array operations or string manipulations) only work on newer Bash versions and would fail or behave unexpectedly on older ones. Confirming the version upfront (as I did with bash --version, showing 5.3.9) ensures the scripts I write will actually work correctly on this specific server avoiding compatibility issues later.

# Task 2 — Your First Bash Script

## Goal

Create your first Bash script, make it executable, and run it from the terminal.

### Evidence

#### Screenshot 1 — Content of `first-script.sh`

Add your screenshot here.
![Screenshot1](<screenshots/Screenshot1 Task2 Assign5.png>)


#### Screenshot 2 — Output of `./first-script.sh`

Add your screenshot here.
![Screenshot2](<screenshots/Screenshot2 Task2 Assign5.png>)


#### Screenshot 3 — Output of `ls -l first-script.sh` showing executable permission

Add your screenshot here.
![Screenshot3](<screenshots/Screenshot3 Task2 Assign5.png>)


### Notes

Answer the following in your own words:

**1. What is the purpose of `#!/bin/bash`?**

Add your answer here.

This is called a "shebang" line. It tells the operating system which interpreter should be used to run the script in this case /bin/bash. Without it the system wouldn't know whether to treat the file as a Bash script, a Python script, or something else, and might fail to execute it correctly.

**2. Why do we use `chmod +x` before running a script?**

Add your answer here.

By default newly created files don't have execute permission they're just readable/writable text files. chmod +x adds the execute permission which is required before the operating system will allow the file to be run directly as a program (via ./script.sh). Without it trying to run the script would return a "Permission denied" error.

**3. What is the difference between running a script using `./script.sh` and `bash script.sh`?**

Add your answer here.

./script.sh runs the script as an executable file directly relying on the shebang line (#!/bin/bash) to determine which interpreter to use this requires the execute permission to be set. bash script.sh explicitly tells the system to run the file using Bash regardless of whether it has execute permission or even a shebang line at all. Both usually produce the same result for a Bash script, but bash script.sh is more forgiving of missing permissions.

# Task 3 — Variables: User Information Script

## Goal

Use variables to store and display user-related information.

### Evidence

#### Screenshot 1 — Content of `user-info.sh`

Add your screenshot here.
![Screenshot1](<screenshots/Screenshot1 task3 Assign5.png>)


#### Screenshot 2 — Output of `./user-info.sh`

Add your screenshot here.
![Screenshot2](<screenshots/Screenshot2 Task3 Assign5.png>)


### Notes

Answer the following in your own words:

**1. What is a variable in Bash?**

Add your answer here.

A variable in Bash is a named container used to store a piece of data like text, numbers, or command output so it can be reused throughout a script instead of repeating the same value multiple times. In my script, name="Maida Sehar" stores my name in a variable called name which I can then reference anywhere in the script.

**2. Why should we avoid spaces around the `=` sign when creating variables?**

Add your answer here.

In Bash spaces around = cause a syntax error because Bash interprets name = "Maida Sehar" as trying to run a command called name with arguments = and "Maida Sehar" rather than assigning a value. The correct syntax name="Maida Sehar" (no spaces) tells Bash this is a variable assignment not a command.

**3. How do you access the value stored inside a Bash variable?**

Add your answer here.

You access a variable's value by prefixing its name with a dollar sign like $name or ${name}. In my script I used echo "Name: $name" to print the stored value. The dollar sign tells Bash to substitute the variable's actual value in that spot rather than printing the literal word "name".

# Task 4 — Arrays & Loops: Tools Checklist Script

## Goal

Use arrays and loops to print a checklist of tools used in Bash scripting.

### Evidence

#### Screenshot 1 — Content of `tools-checklist.sh`

Add your screenshot here.
![Screenshot1](<screenshots/Screenshot1 Task4 Assign5.png>)


#### Screenshot 2 — Output of `./tools-checklist.sh`

Add your screenshot here.
![Screenshot2](<screenshots/Screenshot2 Task4 Assign5.png>)


### Notes

Answer the following in your own words:

**1. What is an array in Bash?**

Add your answer here.

An array in Bash is a variable that can hold multiple values (a list) instead of just one, indexed by position starting at 0. In my script, tools=("Git" "Bash" "Nginx" "AWS CLI" "VS Code" "SSH") creates an array containing six different tool names all stored under one variable name.

**2. Why are arrays useful in scripts?**

Add your answer here.

Arrays let you group related data together and process it efficiently especially with loops. Instead of writing six separate variables and six separate echo statements I can store all six tools in one array and loop through them with just a few lines of code making the script shorter, cleaner and easier to update (e.g. adding a 7th tool just means adding it to the array, not writing new code).

**3. What does `"${tools[@]}"` mean?**

Add your answer here.

This syntax expands to all the elements in the tools array treating each one as a separate item. The @ symbol specifically means "all elements" and wrapping it in quotes ensures that array elements containing spaces (like "AWS CLI" or "VS Code") are treated as single items rather than being split apart.

**4. What is the purpose of the `for` loop in this script?**

Add your answer here.

The for loop iterates through each item in the tools array one at a time storing the current item in the variable tool and running the echo command for each one. This lets me print every tool in the list without manually writing a separate echo line for each one.

# Task 5 — Loops: Number Counter Script

## Goal

Use loops to repeat a task multiple times.

### Evidence

#### Screenshot 1 — Content of `counter.sh`

Add your screenshot here.
![Screenshot1](<screenshots/Screenshot1 Task5 Assign5.png>)


#### Screenshot 2 — Output of `./counter.sh`

Add your screenshot here.
![Screenshot2](<screenshots/Screenshot2 Task5 Assign5.png>)


### Notes

Answer the following in your own words:

**1. What is a loop?**

Add your answer here.

A loop is a programming construct that repeats a block of code multiple times either a fixed number of times or until a certain condition is met instead of writing the same code manually over and over.

**2. Why do we use loops in Bash scripting?**

Add your answer here.

Loops save time and reduce repetitive code instead of writing five separate echo statements to count from 1 to 5 a loop lets me write the logic once and have it automatically repeat for each value making scripts shorter cleaner and easier to maintain or modify.

**3. How many times did the loop run in your script?**

Add your answer here.

The loop ran 5 times once for each number in the sequence 1 through 5 printing "Count: 1" through "Count: 5".

**4. What would you change if you wanted the loop to run 10 times?**

Add your answer here.

I would either list out the numbers explicitly (for i in 1 2 3 4 5 6 7 8 9 10) or more efficiently use a range syntax like for i in {1..10} which automatically generates the sequence from 1 to 10 without manually typing each number.

# Task 6 — Files & Conditionals: File Validation Script

## Goal

Use file checks and conditionals to verify whether files and directories exist.

### Evidence

#### Screenshot 1 — Output of `ls -lah ../test-folder`

Add your screenshot here.
![Screenshot1](<screenshots/Screenshot1 Task6 Assign5.png>)


#### Screenshot 2 — Content of `file-check.sh`

Add your screenshot here.
![Screenshot2](<screenshots/Screenshot2 Task6 Assign 5.png>)
![Screenshot2.1](<screenshots/Screenshot2 more Task6 Assign5.png>)




#### Screenshot 3 — Output of `./file-check.sh`

Add your screenshot here.
![Sxcreenshot3](<screenshots/Screenshot3 Task6 Assign5.png>)


### Notes

Answer the following in your own words:

**1. What does `-d` check in Bash?**

Add your answer here.

The -d flag checks whether a given path exists and is a directory. It returns true only if the path points to a folder not a regular file.

**2. What does `-f` check in Bash?**

Add your answer here.

The -f flag checks whether a given path exists and is a regular file (not a directory). It returns true only if the path points to an actual file.

**3. Why should file and directory paths be stored in variables?**

Add your answer here.

Storing paths in variables (like dir_path and file_path) makes scripts easier to maintain and less error-prone if the path ever changes I only need to update it in one place (the variable definition) rather than searching through the entire script for every occurrence of that path.

**4. What happens if the file does not exist?**

Add your answer here.

If the file doesn't exist the -f check returns false and the script's else branch runs instead printing "File does not exist" rather than the script crashing or behaving unpredictably. This is exactly why conditional checks are important they let scripts handle missing files gracefully instead of failing.

# Task 7 — Conditionals: Pass or Retry Script

## Goal

Use if-else conditionals to make decisions based on a variable value.

### Evidence

#### Screenshot 1 — Content of `score-check.sh` with `score=85`

Add your screenshot here.
![Screenshot1](<screenshots/Screenshot1 Task7 Assign5.png>)
![Screenshot2.1](<screenshots/Screenshot1 more Task7 Assign5.png>)



#### Screenshot 2 — Output showing `Result: Pass`

Add your screenshot here.
![Screenshot2](<screenshots/Screenshot2 Task7 Assign5.png>)


#### Screenshot 3 — Content of `score-check.sh` with `score=55`

Add your screenshot here.
![Screenshot3](<screenshots/Screenshot3 Task7 Assign5.png>)
![Screenshot3.1](<screenshots/Screenshot3 more Task7 Assign5.png>)



#### Screenshot 4 — Output showing `Result: Retry`

Add your screenshot here.
![Screenshot4](<screenshots/Screenshot4 Task7 Assign5.png>)


### Notes

Answer the following in your own words:

**1. What is the purpose of if-else in Bash?**

Add your answer here.

If-else lets a script make decisions and take different actions depending on whether a condition is true or false. In my script it checks whether the score meets a passing threshold and prints a different result depending on the outcome without if-else the script could only ever do one thing regardless of the input.

**2. What does `-ge` mean?**

Add your answer here.

-ge stands for "greater than or equal to." It's used to numerically compare two values in my script[ "$score" -ge 60 ] checks whether the score is 60 or higher.

**3. Why should conditions be tested with different values?**

Add your answer here.

Testing with different values (like 85 and 55) confirms that both branches of the conditional actually work as expected a script that only prints "Pass" regardless of the input would look correct on the surface but actually be broken. Testing both the true and false paths verifies the logic handles all realistic scenarios correctly.

**4. How can conditionals help in automation scripts?**

Add your answer here.

Conditionals let automation scripts respond intelligently to different situations for example, checking if a service is running before restarting it verifying disk space before deploying a new build or validating input before processing it. Without conditionals scripts would run the same steps blindly regardless of context which could cause failures or unintended consequences in real production systems.

# Task 8 — Functions: Final Bash Automation Script

## Goal

Create a final Bash script using functions to organize reusable code.

### Evidence

#### Screenshot 1 — Content of `final-automation.sh`

Add your screenshot here.
![Screenshot1](<screenshots/Screenshot1 Task8 Assign5.png>)
![Screenshot1.1](<screenshots/Screenshot1 more task8 Assign5.png>)



#### Screenshot 2 — Output of `./final-automation.sh`

Add your screenshot here.
![Screenshot2](<screenshots/Screenshot2 Task8 Assign 5.png>)


#### Screenshot 3 — Output of `ls -lah` showing all created scripts

Add your screenshot here.
![Screenshot3](<screenshots/Screenshot3 Task8 Assign5.png>)


### Notes

Answer the following in your own words:

**1. What is a function in Bash?**

Add your answer here.

A function in Bash is a named reusable block of code that performs a specific task. Instead of writing the same logic repeatedly throughout a script you define it once inside a function and can call it by name whenever needed like greet_user() or check_directory() in my final script.

**2. Why are functions useful in scripts?**

Add your answer here.

Functions make scripts more organized readable and maintainable by breaking complex logic into smaller named self-contained pieces. They also avoid code duplication if I need to check a directory in multiple places I can just call check_directory instead of rewriting the same if-statement each time. This also makes debugging easier since each function can be tested and understood independently.

**3. Which functions did you create in this script?**

Add your answer here.

I created four functions: greet_user (prints a welcome message) check_directory (verifies whether the test folder exists) list_tools (loops through and prints an array of DevOps tools) and evaluate_score (checks a score against a passing threshold using if-else logic).

**4. How does this final script combine variables, arrays, loops, conditionals, files, and functions?**

Add your answer here.

This script brings together everything from the earlier tasks into one cohesive program it uses variables (dir_path, score) to store data, an array (tools) to hold a list of values, a for loop to iterate through that array and print each tool, an if-else conditional to check the directory's existence and evaluate the score, a file/directory check (-d) to validate the file system, and functions to organize all of this logic into clean, reusable, independently callable blocks demonstrating how these individual Bash concepts combine to build a real structured automation script.

# LinkedIn Post (Required)

## Evidence

#### LinkedIn Post URL

Paste your LinkedIn post URL here:

`__________________________`

https://www.linkedin.com/posts/maida-sehar-2ab997263_devops-linux-bashscripting-share-7483513621604540418-A4PK/?utm_source=share&utm_medium=member_desktop&rcm=ACoAAEDAZeMBfFjix-eqjklKqLfUwTxMrs40I1Q

#### Screenshot — Published LinkedIn post

Add your screenshot here.
![Screenshot](<screenshots/Linkedin post for assign5 week3.png>)


# Submission Instructions

- Add all required screenshots in your submission
- Full name must be visible in required screenshots
- All script files must be created and run successfully
- Required notes must be answered clearly for every task
- Do not expose sensitive information (keys, passwords, credentials)

---

# Completion Checklist

- [ ] Task 1: Environment setup verified, workspace created (Screenshots 1–2, Notes answered)
- [ ] Task 2: First script created, executed, permissions verified (Screenshots 1–3, Notes answered)
- [ ] Task 3: Variables script created and run (Screenshots 1–2, Notes answered)
- [ ] Task 4: Arrays and loops script created and run (Screenshots 1–2, Notes answered)
- [ ] Task 5: Counter loop script created and run (Screenshots 1–2, Notes answered)
- [ ] Task 6: File validation script created and run (Screenshots 1–3, Notes answered)
- [ ] Task 7: Pass/Retry conditional script tested with both values (Screenshots 1–4, Notes answered)
- [ ] Task 8: Final automation script created and run (Screenshots 1–3, Notes answered)
- [ ] All scripts run without errors
- [ ] Full Name visible in all required screenshots
- [ ] LinkedIn post published and URL submitted
- [ ] No sensitive data exposed

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