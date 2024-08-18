#!/bin/bash
set -e
set -o pipefail

UUID=$(id -u)
if [ "$UUID" -eq 0 ]; then
    echo "Please run as a regular user. Exiting..."
    exit 1
fi


GITHUB_REPO_URL="${1:?First argument, Github repo URL, cannot be empty}"
PLAYBOOK_NAME="${2:-playbook.yml}"
WORKING_DIR="${3:-/tmp/ansible}"
ANSIBLE_ARG="${4}"

sudo apt-get update -y
sudo apt-get install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt-get install -y ansible git

mkdir -p "${WORKING_DIR}" && cd "${WORKING_DIR}"
git clone "${GITHUB_REPO_URL}" git_repo && cd ./git_repo
if [ -f "${PLAYBOOK_NAME}.yaml" ]; then
    ansible-playbook "${ANSIBLE_ARG}" "${PLAYBOOK_NAME}"
else
    echo "Playbook ${PLAYBOOK_NAME} does not exist."
fi
