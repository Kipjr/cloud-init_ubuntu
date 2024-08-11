# Ensure script runs as a non-root user
$UUID = (id -u)
if ($UUID -eq 0) {
    Write-Host "Please run as a regular user. Exiting..."
    exit
}
$USERNAME = ${env:USER}

# Set error handling and strict mode
$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3

# Install required packages for Ansible
sudo apt-get update
sudo apt-get install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt-get install -y ansible curl

# Create Ansible playbook directory
$ansiblePlaybookDir = "/home/$USERNAME/ansible-playbook"
mkdir -p $ansiblePlaybookDir

# Download the Ansible playbook
$ansiblePlaybookUrl = "https://example.com/your-ansible-playbook.yml"  # Replace with your actual URL
curl -o "$ansiblePlaybookDir/playbook.yml" $ansiblePlaybookUrl

# Run the Ansible playbook
sudo ansible-playbook "$ansiblePlaybookDir/playbook.yml"
