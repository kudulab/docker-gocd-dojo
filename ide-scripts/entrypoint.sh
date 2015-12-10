#!/bin/bash

###########################################################################
# This file is an init script to properly start docker container.
###########################################################################

set -e

if [ -t 0 ] ; then
    # interactive shell

    /usr/bin/ide-setup-identity.sh
    /usr/bin/ide-fix-uid-gid.sh
    echo "ide init finished (interactive shell)"

    # No "set -e" here, you don't want to be logged out when sth returns not 0
    # in interactive shell. Example:
    # ide@d5daccdfcd04:~$ exec su - ide
    # Password:
    # su: Authentication failure
    # # here logged out
    set +e
    # No "-c" option
    su - ide
else
    # not interactive shell

    /usr/bin/ide-setup-identity.sh
    /usr/bin/ide-fix-uid-gid.sh
    echo "ide init finished (not interactive shell)"

    su - ide -c "$@"
fi
