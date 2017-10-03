#!/bin/bash

set -x

# Setup
VENV="venv6"
PYTHON="python3.6"
FIRST_PKG="pkg1"
SECOND_PKG="pkg4"
virtualenv --python=${PYTHON} ${VENV}
PIP_COMMIT="90f64b41bbb20ebb7143d88052c944b30dbe61ac"
${VENV}/bin/pip \
    install \
    --ignore-installed \
    git+git://github.com/pypa/pip.git@${PIP_COMMIT}#egg=pip
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
ls -1 ${VENV}/lib/${PYTHON}/site-packages/${FIRST_PKG}_ns/
tree -a ${VENV}/lib/${PYTHON}/site-packages/${FIRST_PKG}_ns/
tree -a ${VENV}/lib/${PYTHON}/site-packages/${SECOND_PKG}*.egg/${FIRST_PKG}_ns/
# Try to use the packages
${VENV}/bin/python example06.py
# Cleanup
rm -fr ${VENV}
rm -fr ${SECOND_PKG}-dir/build/
rm -fr ${SECOND_PKG}-dir/dist/
rm -fr ${SECOND_PKG}-dir/src/${SECOND_PKG}.egg-info/
