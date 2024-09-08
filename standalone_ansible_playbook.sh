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
WORKING_DIR="${3:-/tmp}"
ANSIBLE_ARG="${4}"

cd "${WORKING_DIR}"
TMPDIR=$(mktemp -d -p "${WORKING_DIR}"  ansible.XXXX)
cd "${TMPDIR}"

curl https://bootstrap.pypa.io/get-pip.py -o "${TMPDIR}/get-pip.py"
python3 "${TMPDIR}/get-pip.py" --user
export -p PATH=/home/${USER}/.local/bin:$PATH
python3 -m pip install --user ansible

git clone "${GITHUB_REPO_URL}" git_repo
cd "${TMPDIR}/git_repo"
if [ -f "$PWD/${PLAYBOOK_NAME}" ]; then
    ansible-galaxy install -r collections/requirements.yml
    # shellcheck disable=SC2086 # Intended non-quoted var. Will break if quoted
    ansible-playbook -v -i inventory ${ANSIBLE_ARG} "${PLAYBOOK_NAME}"
else
    echo "Playbook ${PLAYBOOK_NAME} does not exist."
fi
cd "${WORKING_DIR}"
