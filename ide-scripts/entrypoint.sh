#!/bin/bash

###########################################################################
# This file is an init script to properly start IDE docker container.
# see https://github.com/ai-traders/ide#entrypoint
###########################################################################

set -e
/usr/bin/ide-setup-identity.sh
/usr/bin/ide-fix-uid-gid.sh

if [ -t 0 ] ; then
    # interactive shell
    echo "ide init finished (interactive shell)"
    set +e
else
    # not interactive shell
    echo "ide init finished (not interactive shell)"
    set -e
fi

sudo -E -H -u ide /bin/bash -lc "$@"
