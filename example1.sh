#!/bin/bash

set -x

# Setup
virtualenv --python=python3.6 venv1
venv1/bin/pip show pip
# pkg1
venv1/bin/pip install pkg1-dir/
venv1/bin/pip freeze
ls -1 venv1/lib/python3.6/site-packages/*pth
ls -1 venv1/lib/python3.6/site-packages/pkg1/
# pkg2
venv1/bin/pip install pkg2-dir/
ls -1 venv1/lib/python3.6/site-packages/pkg2/
venv1/bin/pip freeze
# Cleanup
rm -fr venv1/
