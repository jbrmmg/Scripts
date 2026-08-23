# Objective

Create a script that can regenerate the docker containers for my github runners.  If possible would like to run it as though it's a command on my linux desktop.

# Requirements

Create the script in src/main/resources/github, if possible the script should be self-contained.

The script should take two parameters:

+ `RepoName` (case-sensitive) - name of the repo that the runner is for.
+ `Environment` - name of the environment - prod or dev
+ `Token` - used as the token for the runner to connect.

Process:

- Determine the lower case RepoName - call this RepoNameLowercase
- Determine the directory to use this will be ~/docker/<RepoNameLowercase>-docker
- If the directory already exists then run the command 'docker compose down -v' in that directory, then delete the contents of the directory.
- If the directory does not exist then create it.
- Create a file called .env.secrets in the directory that contains the line 'ACCESS_TOKEN=<Token>'
- Create a file called .env in the directory with the following lines:
        CONTAINER_NAME=<RepoNameLowercase>-runner
        REPO_NAME=<RepoName>
        RUNNER_NAME=<RepoNameLowercase>-<Environment>-runner
        LABELS=self-hosted,<RepoNameLowercase>-<Environment>
- Create a file called docker-compose.yml which has the contents from src/main/resources/github/base-docker-compose.yml
- Pull the latest image by running 'docker compose pull' in the directory
- Start the container by running 'docker compose up -d' in the directory
