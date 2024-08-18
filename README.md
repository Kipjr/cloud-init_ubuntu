# cloud-init_ubuntu
Cloud-Init for Ubuntu Server

# Usage

### Use standalone (Installs Ansible and executes playbook)
- Bash `standalone_ansible_playbook.sh` 
- Powershell Core: `standalone_ansible_playbook.ps1`

### Use with Proxmox Cloud-Init: 
- Use `https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img` as base image.
- Execute somewhere `./proxmox/new_ci-config.sh`
- Store 'ci-config-userdata.yaml' in Proxmox Snippets
- Update your template VM: `qm set <vmid> --cicustom "user=local:snippets/ci-config-userdata.yaml"`

### Use Raw:
- `https://raw.githubusercontent.com/Kipjr/cloud-init_ubuntu/master/site.yml`


