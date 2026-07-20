#!/bin/bash

WORK_DIR=$( cd -- "$(dirname "${0}")" > /dev/null 2>&1 || exit ; pwd -P )
PROJECT_DIR=$(echo $WORK_DIR | rev | cut -d'/' -f2- | rev)

# Create the python env if it is missing
if [ ! -d "ansible-venv" ]; then
	echo "No Python virtual environment found. Will generate one. This takes some time."
	python3 -m venv ansible-venv
fi

# Activate the venv and install needed stuff in it
source ansible-venv/bin/activate
python -m pip install -q --upgrade pip setuptools wheel
python -m pip install -q -r molecule/requirements.txt

# Fix ansible modules paths to only look inside the venv
export PROJECT_DIR=$PROJECT_DIR
export ANSIBLE_COLLECTIONS_PATH="$PROJECT_DIR/ansible-venv/ansible_collections"
export ANSIBLE_ROLES_PATH="$PROJECT_DIR/ansible-venv/ansible_roles"
mkdir -p $ANSIBLE_COLLECTIONS_PATH
mkdir -p $ANSIBLE_ROLES_PATH

# Install all Ansible collections and requirements
ansible-galaxy collection install -r molecule/default/requirements.yml -p "$ANSIBLE_COLLECTIONS_PATH"
ansible-galaxy role install -r molecule/default/requirements.yml -p "$ANSIBLE_ROLES_PATH"

echo "### Collection list"
ansible-galaxy collection list
echo "### Roles list"
ansible-galaxy role list
echo "### Ansible version"
ansible --version
echo "### Python pip modules"
python -m pip list
# echo "### ENV"
# env

time molecule test -- $@
