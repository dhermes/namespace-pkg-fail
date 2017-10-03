#!/bin/bash

set -x

virtualenv --python=python3.6 venv1
venv1/bin/pip show pip
venv1/bin/pip install pkg1-dir/
venv1/bin/pip freeze
ls -1 venv1/lib/python3.6/site-packages/*pth
venv1/bin/pip install pkg2-dir/
venv1/bin/pip freeze

rm -fr venv1/
