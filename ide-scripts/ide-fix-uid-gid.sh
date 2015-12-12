#!/bin/bash

###########################################################################
# This file ensures that ide user has the same uid and gid as
# /ide/work directory.
# Used as fix-uid-gid solution in docker, almost copied from:
# https://github.com/tomzo/docker-uid-gid-fix/blob/master/fix-uid-gid.sh
###########################################################################

# This is the directory we expect to be mounted as docker volume.
# From that directory we know uid and gid.
if [ -f "/ide/work/.ide-mark" ]; then
  # /ide/work is not mounted as docker volume, so its uid and gid hasn't changed
  # then we can assume that user is building from remote sources
  # and he will want proper owner in output
  DIRECTORY=/ide/output
else
  DIRECTORY=/ide/work
fi
OWNER_USERNAME=ide
OWNER_GROUPNAME=ide

if [ -z "$DIRECTORY" ]; then
  echo "Directory not specified"
  exit 1;
fi

if [ -z "$OWNER_USERNAME" ]; then
  echo "Username not specified"
  exit 1;
fi
if [ -z "$OWNER_GROUPNAME" ]; then
  echo "Groupname not specified"
  exit 1;
fi
if [ ! -d "$DIRECTORY" ]; then
  echo "$DIRECTORY does not exist, expected to be mounted as docker volume"
  exit 1;
fi

ret=false
getent passwd $OWNER_USERNAME >/dev/null 2>&1 && ret=true

if ! $ret; then
    echo "User $OWNER_USERNAME does not exist"
    exit 1;
fi
ret=false
getent passwd $OWNER_GROUPNAME >/dev/null 2>&1 && ret=true
if ! $ret; then
    echo "Group $OWNER_GROUPNAME does not exist"
    exit 1;
fi

NEWUID=$(ls --numeric-uid-gid -d $DIRECTORY | awk '{ print $3 }')
NEWGID=$(ls --numeric-uid-gid -d $DIRECTORY | awk '{ print $4 }')

usermod -u $NEWUID $OWNER_USERNAME
groupmod -g $NEWGID $OWNER_GROUPNAME
# Might be needed if the image has files which should be owned by
# this user and group. When we know more about user and group, then
# this find might be at smaller scope.
# In this case, image has only /home/ide owned by 1000
# find /home/ide -user 1000 -exec chown -h $NEWUID {} \;
# find /home/ide -group 1000 -exec chgrp -h $NEWGID {} \;
chown $NEWUID:$NEWGID -R /home/ide

# do not chown the /ide/work directory, it already has proper uid and gid,
# besides, when /ide/work is very big, chown would take much time
# unless it is not mounted and uid has changed to match with identity or output directory
if [ -f "$DIRECTORY/.ide-mark" ]; then
  echo "$DIRECTORY is not mounted as docker volume. Fixing current content owner"
  chown $NEWUID:$NEWGID -R /ide/work
fi

# ensure that ide will be able to copy packages in the end
chown $NEWUID:$NEWGID /ide/output
