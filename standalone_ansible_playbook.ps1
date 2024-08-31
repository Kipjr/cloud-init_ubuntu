#!/usr/bin/env pwsh

param (
    [Parameter(Position=0)][string]$GitHubRepoUrl = "https://github.com/Kipjr/cloud-init_ubuntu",
    [Parameter(Position=1)][string]$PlaybookName = "site.yml",
    [Parameter(Position=2)][string]$WorkingDir = "/tmp/ansible",
    [Parameter(Position=3)][string]$AnsibleArg
)
# Set error handling and strict mode
$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3

# Ensure script runs as a non-root user
$UUID = (id -u)
if ($UUID -eq 0) {
    Write-Host "Please run as a regular user. Exiting..."
    exit
}

Invoke-WebRequest -Uri "https://bootstrap.pypa.io/get-pip.py" -OutFile "get-pip.py"
python3 get-pip.py --user
$env:PATH="/home/adminuser/.local/bin:$env:PATH"
python3 -m pip install --user ansible

# Create working directory and clone the repository
if (-not (Test-Path -Path $WorkingDir)) {
    New-Item -Path $WorkingDir -ItemType Directory
}
Set-Location -Path $WorkingDir
git clone $GitHubRepoUrl git_repo
Set-Location -Path "$WorkingDir/git_repo"

# Check if the playbook file exists and run it
if (Test-Path -Path $PlaybookName) {
    ansible-galaxy install -r collections/requirements.yml
    ansible-playbook -v -i inventory "$AnsibleArg" "$PlaybookName"
} else {
    Write-Output "Playbook $PlaybookName does not exist."
}




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

