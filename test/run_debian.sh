#!/bin/bash
SECONDS=0
ANSIBLE_VERSION="2.18"

# Create a Copy of this Role
WORKDIR=$(mktemp -d)
cp -r ../* $WORKDIR

# Execute Playbook in Copied Directory
# time ansible-playbook --vault-pass-file .ansible-vault -i $WORKDIR/ansible-docker-compose/test/debian_inventory.yml $WORKDIR/ansible-docker-compose/test/debian_playbook.yml $@

# This writes to $WORKDIR on your host
docker run --rm \
           --volume "${WORKDIR}/ansible-docker-compose:/opt/ansible" \
           "ansible:${ANSIBLE_VERSION}" \
           ansible-galaxy collection install -r /opt/ansible/requirements.yml -p /opt/ansible/.ansible/collections

docker run --rm \
           --volume "${WORKDIR}/ansible-docker-compose:/opt/ansible" \
           --volume "/var/run/docker.sock:/var/run/docker.sock" \
           --env "ANSIBLE_FORCE_COLOR=True" \
           --env "REAL_WORK_DIR=${WORKDIR}" \
           --env "ANSIBLE_COLLECTIONS_PATH=/opt/ansible/.ansible/collections:/usr/share/ansible/collections" \
           "ansible:${ANSIBLE_VERSION}" \
           ansible-playbook \
           --vault-password-file "/opt/ansible/.ansible-vault" \
           --inventory "/opt/ansible/test/debian_inventory.yml" \
           "/opt/ansible/test/debian_playbook.yml" $@

# Clean Up
rm -rf $WORKDIR
echo "Total test execution time: $SECONDS sec"
