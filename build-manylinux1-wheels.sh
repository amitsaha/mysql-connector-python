#!/bin/bash
# Script modified from https://github.com/pypa/python-manylinux-demo
set -e -x

# Install a system package required by our library
yum install -y libmysqlclient-devel protobuf-devel protobuf-compiler python-devel gcc

cd /workspace

# Compile wheels
for PYBIN in /opt/python/*/bin; do
    ls
    MYSQLXPB_PROTOBUF_INCLUDE_DIR=/usr/include/google/protobuf MYSQLXPB_PROTOBUF_LIB_DIR=/usr/local/lib/python3.6/site-packages/google/protobuf MYSQLXPB_PROTOC=/usr/bin/protoc ${PYBIN}/python setup.py bdist_wheel --with-mysql-capi=$(which mysql_config) --dist-dir=wheelhouse/
done

# Bundle external shared libraries into the wheels
#ls wheelhouse/*
for whl in wheelhouse/*linux*.whl; do
    auditwheel repair $whl -w /workspace/wheelhouse/
done

# Install packages and test
for PYBIN in /opt/python/*/bin/; do
    ${PYBIN}/pip install mysql-connector-python -f /workspace/wheelhouse
    ${PYBIN}/python -c "import mysql.connector; print mysql.connector.HAVE_CEXT"
done
