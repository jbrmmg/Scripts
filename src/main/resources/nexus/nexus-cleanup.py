#!/usr/bin/env python3
import os
import json
import requests

# Load credentials
creds = {}
with open(os.path.expanduser("~/.nexus-credentials")) as f:
    for line in f:
        line = line.strip()
        if "=" in line:
            key, value = line.split("=", 1)
            creds[key.strip()] = value.strip().strip('"')

NEXUS_HOST = "nexus.jbrmmg.me.uk:8083"
IMAGES = ["backup", "home", "home-dev", "money", "money-dev", "webpage", "wordclue", "wordhelper"]
KEEP = 3
DRY_RUN = False

auth = (creds["NEXUS_USER"], creds["NEXUS_PASSWORD"])
base = f"http://{NEXUS_HOST}/v2"

for image in IMAGES:
    print(f"=== {image} ===")

    r = requests.get(f"{base}/{image}/tags/list", auth=auth)
    tags = [t for t in r.json().get("tags", []) if t != "latest"]

    tags_with_dates = []

    for tag in tags:
        try:
            r = requests.get(
                f"{base}/{image}/manifests/{tag}",
                auth=auth,
                headers={"Accept": "application/vnd.oci.image.index.v1+json"}
            )
            index = r.json()

            # Handle both image index and direct manifest
            if "manifests" in index:
                amd64_digest = None
                for entry in index.get("manifests", []):
                    p = entry.get("platform", {})
                    if p.get("architecture") == "amd64" and p.get("os") == "linux":
                        amd64_digest = entry["digest"]
                        break
                r = requests.get(
                    f"{base}/{image}/manifests/{amd64_digest}",
                    auth=auth,
                    headers={"Accept": "application/vnd.oci.image.manifest.v1+json"}
                )

            config_digest = r.json()["config"]["digest"]
            r = requests.get(f"{base}/{image}/blobs/{config_digest}", auth=auth)
            created = r.json()["created"]
            tags_with_dates.append((created, tag))

        except Exception as e:
            print(f"  WARNING: skipping {tag} ({e})")

            # Sort by date descending (newest first)
    tags_with_dates.sort(key=lambda x: x[0], reverse=True)

    for i, (created, tag) in enumerate(tags_with_dates):
       action = "KEEP" if i < KEEP else "DELETE"

    for i, (created, tag) in enumerate(tags_with_dates):
        if i < KEEP:
            print(f"  KEEP    {created}  {tag}")
        else:
            print(f"  DELETE  {created}  {tag}")
            if not DRY_RUN:
                r = requests.delete(
                    f"{base}/{image}/manifests/{tag}",
                    auth=auth
                )
                if r.status_code == 202:
                    print(f"            -> deleted")
                else:
                    print(f"            -> FAILED ({r.status_code}: {r.text})")
    print()