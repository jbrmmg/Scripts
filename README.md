# Scripts

Deployment scripts and configuration for the jbrmmg home infrastructure, packaged via Maven and deployed through Jenkins.

## Overview

This project packages a set of bash deployment scripts into a zip artifact. The artifact is published to a Nexus repository and consumed by a Jenkins pipeline that handles automated deployment of services, web applications, and DNS configuration.

## Repository Structure

```
src/main/resources/
├── bash/               # Deployment bash scripts
│   ├── BlankDeploy.sh      # No-op script (used as default pre/post deploy hooks)
│   ├── DeployDNS.sh        # Deploy BIND9 DNS configuration
│   ├── DeployService.sh    # Deploy a Java service jar via systemd
│   ├── DeployWeb.sh        # Deploy a WAR file
│   ├── StartService.sh     # Enable and start a systemd service
│   └── StopService.sh      # Stop a running systemd service
├── config/
│   └── assembly.xml        # Maven Assembly plugin descriptor
├── jenkins/
│   └── Jenkinsfile         # Jenkins pipeline definition
└── other/
    ├── deployment/
    │   ├── development.txt  # Deployment dir for snapshots (/usr/bin/jbr/dev)
    │   └── release.txt      # Deployment dir for releases (/usr/bin/jbr)
    ├── gdfuse/
    │   └── gdfuse           # Google Drive FUSE configuration
    └── SystemD/
        ├── confluence.service
        └── jira.service
```

## Scripts

### DeployService.sh
Deploys a Java service jar from a Nexus artifact zip. Downloads the artifact, extracts the systemd `.service` unit file and the jar, installs them to the appropriate locations, and sets file permissions.

**Required environment variables:** `DeploymentDir`, `Environment`, `ServiceNameTemp`, `BinFile`, `DeployFile`, `Url`, `DeployArtifact`, `DeployVersion`

### DeployWeb.sh
Deploys a WAR file to a web deployment directory. Clears the existing deployment, downloads the WAR from Nexus, and extracts it in place.

**Required environment variables:** `WebDeploymentDir`, `Environment`, `GO_ENVIRONMENT_NAME`, `GO_PACKAGE_*_LOCATION`, `GO_PACKAGE_*_GROUP_ID`, `GO_PACKAGE_*_ARTIFACT_ID`

### DeployDNS.sh
Deploys a BIND9 DNS configuration. Stops the `bind9` service, extracts the new configuration, replaces placeholder DNS server addresses, then restarts the service.

**Required environment variables:** `BindDir`, `Environment`, `MyDNS1`, `MyDNS2`, `GO_PACKAGE_*_LOCATION`, `GO_PACKAGE_*_GROUP_ID`, `GO_PACKAGE_*_ARTIFACT_ID`

### StartService.sh / StopService.sh
Start or stop a named systemd service. Both accept three positional arguments:
1. Repository name (`maven-releases` or `maven-snapshots`)
2. Component name
3. Deployment directory

Service name is derived from the component name; a `-dev` suffix is appended for snapshot deployments.

### BlankDeploy.sh
A no-op script used as the default `pre_deploy.sh` and `post_deploy.sh` in the assembled artifact.

## Build

Requires Maven. The assembly plugin packages the scripts into a zip artifact.

```bash
mvn package
```

Output: `target/Script-<version>.zip`

The zip contains:
- `deploy/*.sh` — the deployment scripts
- `pre_deploy.sh` / `post_deploy.sh` — blank hooks (override per-service as needed)
- `maven-releases-DeploymentDir.txt` — `/usr/bin/jbr`
- `maven-snapshots-DeploymentDir.txt` — `/usr/bin/jbr/dev`

## Jenkins Pipeline

The `Jenkinsfile` is triggered by a Nexus webhook and runs on the appropriate Jenkins agent node. The pipeline stages are:

1. **cleanup** — removes any previous `artifact.zip`, `artifactExtract/`, and `response.xml`
2. **download** — queries the Nexus REST API for the artifact and downloads it (skipped for `JBR`-versioned components or non-`CREATED` events)
3. **extract** — unzips `artifact.zip` into `artifactExtract/`
4. **deploy** — reads the deployment directory from `<repository>-DeploymentDir.txt`, runs `pre_deploy.sh`, copies files, then runs `post_deploy.sh`

**Jenkins SCM configuration:**
- URL: `https://github.com/jbrmmg/Scripts`
- Branch: `Release`
- Script path: `src/main/resources/jenkins/Jenkinsfile`

**Webhook trigger URL:**
```
http://jenkins.jbrmmg.me.uk:8080/generic-webhook-trigger/invoke?token=NEXUS
```

## Deployment Directories

| Repository         | Directory       |
|--------------------|-----------------|
| `maven-releases`   | `/usr/bin/jbr`  |
| `maven-snapshots`  | `/usr/bin/jbr/dev` |
