#!/bin/bash

if which python3; then
    python -m venv /tmp/venv
else
    virtualenv /tmp/venv
fi

cd /tmp/venv
./bin/pip install wheel
./bin/pip install pyyaml
./bin/python -c "import yaml; print(yaml.load('hello: world'))"
