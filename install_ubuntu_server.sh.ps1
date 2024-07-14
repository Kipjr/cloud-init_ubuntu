# NOT AS ROOT

##
## requirements: Network & Ubuntu-Minimal
## optional: 
##   - Partioned:
##     > /      = ext4 = 16GB
##     > /var   = ext4 = 8 GB
##     > ~/.local/share/docker = xfs = 32GB | /var/lib/docker = xfs = 32GB
##     
##


$ErrorActionPreference = "Stop"
Set-StrictMode –version 3

$UUID = (id -u)
if ( $UUID -eq 0) {
    Write-Host "Please run as a regular user. Exiting..."
    exit
}
$USERNAME = ${env:USER}

# Prepare docker for alternative filesystem
sudo mkdir -p /mnt/disk2/docker
if(-Not(Test-Path -Path "/home/${USERNAME}/.local/share/docker")){
    sudo /usr/bin/ln -s /mnt/disk2/docker /home/${USERNAME}/.local/share/docker
}

# disable interactive mode
$autorestart=@'
$nrconf{restart} = 'a';
'@
"$autorestart" | sudo tee /etc/needrestart/conf.d/90-autorestart.conf

$DEBIAN_FRONTEND="noninteractive"
sudo apt-get update
sudo apt-get full-upgrade -y

# Install required packages
$packages = @(
    "ufw", "ethtool", "htop", "lshw", "screen", "open-vm-tools",
    "nano", "net-tools", "dnsutils", "openssl", "ufw"
    "build-essential", "p7zip-full", "hw-probe", "snmpd", "snmp-mibs-downloader",
    "curl", "gnupg", "apt-transport-https", "ca-certificates", "libssl-dev", "git",
    "software-properties-common", "openssh-server", "uidmap", "dbus-user-session", "docker-ce-rootless-extras", "sscep"
)

foreach ($package in $packages) {
    sudo apt-get install -y $package
}

# Configure Webmin
Write-Output "Installing Webmin..."
curl -o setup-repos.sh https://raw.githubusercontent.com/webmin/webmin/master/setup-repos.sh
sudo sh setup-repos.sh
sudo apt-get update
sudo apt-get install -y webmin --install-recommend
# Install Docker
## Add Docker's official GPG key:
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
sudo echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |  tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 

# Configure Docker (rootless)
Write-Output "Installing Docker (rootless)..."
sudo systemctl disable --now docker.service docker.socket
sudo rm /var/run/docker.sock
dockerd-rootless-setuptool.sh install
echo 'export PATH=/usr/bin:$PATH' >> /home/${USERNAME}/.bashrc
echo "export DOCKER_HOST=unix:///run/user/$(id -u ${USERNAME})/docker.sock" >> /home/${USERNAME}/.bashrc
systemctl --user start docker
systemctl --user enable docker
sudo loginctl enable-linger $(whoami)

# Routing ping packets & Exposing privileged ports
echo "net.ipv4.ping_group_range = 0 2147483647" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.ip_unprivileged_port_start = 0" | sudo tee -a /etc/sysctl.conf
sudo sysctl --system

# Configure Portainer
Write-Output "Installing Portainer..."
mkdir -p /home/${USERNAME}/docker/portainer

$dockerComposeContent = @"
volumes:
    portainer_data:

services:
  portainer:
    image: portainer/portainer-ee:latest
    container_name: portainer
    restart: always
    security_opt:
      - no-new-privileges:true
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - portainer_data:/data
    ports:
      - 9000:9000

  portainer_agent:
    image: portainer/portainer-agent:latest
    container_name: portainer_agent
    restart: always
    security_opt:
      - no-new-privileges:true
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /run/user/$(id -u ${USERNAME})/docker.sock:/var/run/docker.sock
      - /home/${USERNAME}/.local/share/docker/volumes:/var/lib/docker/volumes
    ports:
      - 9001:9001
"@

$dockerComposeContent | Out-File -FilePath "/home/${USERNAME}/docker/portainer/docker-compose.yml" -Force
