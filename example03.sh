#!/bin/bash

set -x

# Setup
VENV="venv3"
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
# Second package (via setuptools).
(cd ${SECOND_PKG}-dir/ && \
    ../${VENV}/bin/python setup.py install)
${VENV}/bin/pip freeze
ls -1 ${VENV}/lib/${PYTHON}/site-packages/ | grep -e 'pth$'
ls -1 ${VENV}/lib/${PYTHON}/site-packages/${SECOND_PKG}*.egg/${SECOND_PKG}_ns/
# Cleanup
rm -fr ${VENV}
rm -fr ${SECOND_PKG}-dir/build/
rm -fr ${SECOND_PKG}-dir/dist/
rm -fr ${SECOND_PKG}-dir/src/${SECOND_PKG}.egg-info/
