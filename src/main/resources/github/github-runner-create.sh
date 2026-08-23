#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 3 ]]; then
    echo "Usage: $(basename "$0") <RepoName> <Environment> <Token>" >&2
    exit 1
fi

REPO_NAME="$1"
ENVIRONMENT="$2"
TOKEN="$3"

if [[ "${ENVIRONMENT}" != "prod" && "${ENVIRONMENT}" != "dev" ]]; then
    echo "Error: Environment must be 'prod' or 'dev'" >&2
    exit 1
fi
REPO_NAME_LOWER="${REPO_NAME,,}"
RUNNER_DIR="${HOME}/docker/${REPO_NAME_LOWER}-docker"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_COMPOSE="${SCRIPT_DIR}/base-docker-compose.yml"

if [[ ! -f "${BASE_COMPOSE}" ]]; then
    echo "Error: base-docker-compose.yml not found at ${BASE_COMPOSE}" >&2
    exit 1
fi

if [[ -d "${RUNNER_DIR}" ]]; then
    echo "Directory exists, tearing down existing container..."
    (cd "${RUNNER_DIR}" && docker compose down -v)
    echo "Clearing directory contents..."
    rm -rf "${RUNNER_DIR:?}"/*
    rm -f "${RUNNER_DIR}"/.*  2>/dev/null || true
else
    echo "Creating directory ${RUNNER_DIR}..."
    mkdir -p "${RUNNER_DIR}"
fi

cat > "${RUNNER_DIR}/.env.secrets" <<EOF
ACCESS_TOKEN=${TOKEN}
EOF

cat > "${RUNNER_DIR}/.env" <<EOF
CONTAINER_NAME=${REPO_NAME_LOWER}-runner
REPO_NAME=${REPO_NAME}
RUNNER_NAME=${REPO_NAME_LOWER}-${ENVIRONMENT}-runner
LABELS=self-hosted,${REPO_NAME_LOWER}-${ENVIRONMENT}
EOF

cp "${BASE_COMPOSE}" "${RUNNER_DIR}/docker-compose.yml"

echo "Pulling latest image..."
(cd "${RUNNER_DIR}" && docker compose pull)

echo "Starting runner container..."
(cd "${RUNNER_DIR}" && docker compose up -d)

echo "Done. Runner '${REPO_NAME_LOWER}-${ENVIRONMENT}-runner' is starting for repo '${REPO_NAME}'."