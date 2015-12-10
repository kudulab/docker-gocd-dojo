#!/bin/bash

###########################################################################
# This file ensures files are mapped from /ide/identity into /home/ide.
# Fails if any required secret or configuration file is missing.
###########################################################################

# This is the directory we expect to be mounted as docker volume.
# From that directory we mapt configuration and secrets files.
DIRECTORY=/ide/identity

if [ ! -d "$DIRECTORY/.ssh" ]; then
  echo "WARNING: $DIRECTORY/.ssh does not exist"
else
  cp -avR $DIRECTORY/.ssh /home/ide/.ssh
  # TODO fix key paths
  cat $DIRECTORY/.ssh/config | sed -E 's/IdentityFile.*/IdentityFile \/home\/ide\/.ssh\/id_rsa/g' >> /home/ide/.ssh/config
fi

if [ ! -f "$DIRECTORY/.gitconfig" ]; then
  echo "WARNING: $DIRECTORY/.gitconfig does not exist"
else
  cp $DIRECTORY/.gitconfig /home/ide/
fi

touch /home/ide/.profile
echo "cd /ide/work" > /home/ide/.profile
