#!/bin/bash

# source /root/.bashrc

if [ ! -e /root/.aws/config ]; then
    mv /root/.aws/config.default /root/.aws/config
fi

if [ ! -e /root/.aws/credentials ]; then
    mv /root/.aws/credentials.default /root/.aws/credentials
    sed -i "s|<access-key>|$1|g" /root/.aws/credentials
    sed -i "s|<secret-key>|$2|g" /root/.aws/credentials
fi