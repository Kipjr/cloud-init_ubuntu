#!/bin/bash
set -e
set -o pipefail

UUID=$(id -u)
if [ "$UUID" -eq 0 ]; then
    echo "Please run as a regular user. Exiting..."
    exit 1
fi


GITHUB_REPO_URL="${1:-https://github.com/Kipjr/cloud-init_ubuntu}"
PLAYBOOK_NAME="${2:-site.yml}"
WORKING_DIR="${3:-/tmp/ansible}"
ANSIBLE_ARG="${4}"

curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3 get-pip.py --user
export -p PATH=/home/${USER}/.local/bin:$PATH
python3 -m pip install --user ansible

mkdir -p "${WORKING_DIR}" && cd "${WORKING_DIR}"
git clone "${GITHUB_REPO_URL}" git_repo && cd ./git_repo
if [ -f "${PLAYBOOK_NAME}" ]; then
    ansible-galaxy install -r collections/requirements.yml
    ansible-playbook "${ANSIBLE_ARG}" "${PLAYBOOK_NAME}"
else
    echo "Playbook ${PLAYBOOK_NAME} does not exist."
fi
