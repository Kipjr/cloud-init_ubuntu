#!/bin/bash

cd $(dirname $0)

# copy template
cp -v "env.example" "env"

# edit env
vi "env"

# Setting temporary Env vars
export $(grep -v '^#' env | xargs)

# filling template and export to yaml
envsubst < ci-config-userdata.template.yaml > ci-config-userdata.yaml

#Removing temporary Env vars
unset $(grep -v '^#' .env | xargs)

#Remove env
rm -vi "./env"

cat <<EOF
Move 'ci-config-userdata.yaml' to Proxmox Snippets [local:snippets]
Execute this command in your proxmox shell:
qm set <template_id> --cicustom user=local:snippets/ci-config-userdata.yaml
EOF
