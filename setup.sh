#!/bin/bash

echo 'Setting up Python environment...'
python3 -m venv venv
echo 'Installing packages...'
venv/bin/pip3 install -r requirements.txt
