#!/usr/bin/env pwsh

param (
    [Parameter(Position=0)][string]$GitHubRepoUrl = $(throw "First argument, GitHub repo URL, cannot be empty"),
    [Parameter(Position=1)][string]$PlaybookName = "playbook.yml",
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

sudo apt-get update -y
sudo apt-get install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt-get install -y ansible git

# Create working directory and clone the repository
if (-not (Test-Path -Path $WorkingDir)) {
    New-Item -Path $WorkingDir -ItemType Directory
}
Set-Location -Path $WorkingDir
git clone $GitHubRepoUrl git_repo
Set-Location -Path "$WorkingDir/git_repo"

# Check if the playbook file exists and run it
if (Test-Path -Path $PlaybookName) {
    ansible-playbook "$AnsibleArg" $PlaybookName
} else {
    Write-Output "Playbook $PlaybookName does not exist."
}
