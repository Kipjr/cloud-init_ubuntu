#!/bin/bash

# Create a temporary environment file with exported variables
temp_env=$(mktemp)

cd "$(dirname "$0")" || exit 1

# copy template
cp "env.example" "$temp_env"

# edit env
nano "$temp_env"

sed -i 's/^/export /g' "$temp_env"

# Use the temporary environment file to perform envsubst
# shellcheck disable=SC1091
(source "$temp_env" && envsubst < ci-config-userdata.template.yaml > test.txt)

# Clean up temporary environment file
/bin/rm "$temp_env"

cat <<EOF
Move 'ci-config-userdata.yaml' to Proxmox Snippets [local:snippets]
Execute this command in your proxmox shell:
qm set <template_id> --cicustom user=local:snippets/ci-config-userdata.yaml
EOF
