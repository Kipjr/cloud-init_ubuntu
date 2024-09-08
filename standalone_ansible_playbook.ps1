#!/usr/bin/env pwsh

param (
    [Parameter(Position=0)][string]$GitHubRepoUrl = "https://github.com/Kipjr/cloud-init_ubuntu",
    [Parameter(Position=1)][string]$PlaybookName = "site.yml",
    [Parameter(Position=2)][string]$WorkingDir = "/tmp",
    [Parameter(Position=3)][string]$AnsibleArg
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3

$UUID = (id -u)
if ($UUID -eq 0) {
    Write-Host "Please run as a regular user. Exiting..."
    exit
}

Set-Location -Path $WorkingDir
$TMPDIR = Join-Path -Path $WORKING_DIR -ChildPath ("ansible." + ([System.IO.Path]::GetRandomFileName()).Substring(0,4))
New-Item -Path $TMPDIR -ItemType Directory
Set-Location -Path $TMPDIR

Invoke-WebRequest -Uri "https://bootstrap.pypa.io/get-pip.py" -OutFile "${TMPDIR}/get-pip.py"
python3 "${TMPDIR}/get-pip.py" --user
$env:PATH="/home/adminuser/.local/bin:$env:PATH"
python3 -m pip install --user ansible

git clone $GitHubRepoUrl git_repo
Set-Location -Path "${TMPDIR}/git_repo"

if (Test-Path -Path $PlaybookName) {
    ansible-galaxy install -r collections/requirements.yml
    ansible-playbook -v -i inventory "$AnsibleArg" "$PlaybookName"
} else {
    Write-Output "Playbook $PlaybookName does not exist."
}
Set-Location -Path "$WorkingDir"
