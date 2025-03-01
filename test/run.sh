#!/bin/bash

source ansible-venv/bin/activate

echo "Destroying"
time molecule destroy

echo "Resetting"
time molecule reset

echo "Testing"
time molecule test
