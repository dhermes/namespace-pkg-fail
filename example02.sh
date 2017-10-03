#!/bin/bash

set -x

# Setup
VENV="venv2"
PYTHON="python3.6"
FIRST_PKG="pkg1"
SECOND_PKG="pkg3"
virtualenv --python=${PYTHON} ${VENV}
${VENV}/bin/pip show pip
# First package (via pip).
${VENV}/bin/pip install ${FIRST_PKG}-dir/
${VENV}/bin/pip freeze
ls -1 ${VENV}/lib/${PYTHON}/site-packages/ | grep -e 'pth$'
ls -1 ${VENV}/lib/${PYTHON}/site-packages/${FIRST_PKG}_ns/
# Second package (via pip).
${VENV}/bin/pip install ${SECOND_PKG}-dir/
${VENV}/bin/pip freeze
ls -1 ${VENV}/lib/${PYTHON}/site-packages/ | grep -e 'pth$'
ls -1 ${VENV}/lib/${PYTHON}/site-packages/${SECOND_PKG}_ns/
# Cleanup
rm -fr ${VENV}
