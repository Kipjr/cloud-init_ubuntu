#!/usr/bin/env pwsh

param (
    [Parameter(Position=0)][string]$GitHubRepoUrl = "https://github.com/Kipjr/cloud-init_ubuntu",
    [Parameter(Position=1)][string]$PlaybookName = "site.yml",
    [Parameter(Position=2)][string]$WorkingDir = "/run/user/1000/tmp",
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

# Create working directory 
if (-not (Test-Path -Path $WorkingDir)) {
    New-Item -Path $WorkingDir -ItemType Directory
}
Set-Location -Path $WorkingDir
Invoke-WebRequest -Uri "https://bootstrap.pypa.io/get-pip.py" -OutFile "get-pip.py"
python3 get-pip.py --user
$env:PATH="/home/adminuser/.local/bin:$env:PATH"
python3 -m pip install --user ansible

# clone the repository
git clone $GitHubRepoUrl git_repo
Set-Location -Path "$WorkingDir/git_repo"

# Check if the playbook file exists and run it
if (Test-Path -Path $PlaybookName) {
    ansible-galaxy install -r collections/requirements.yml
    ansible-playbook -v -i inventory "$AnsibleArg" "$PlaybookName"
} else {
    Write-Output "Playbook $PlaybookName does not exist."
}
