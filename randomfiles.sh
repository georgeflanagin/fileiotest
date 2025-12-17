#!/bin/bash -e

if [ -z "$2" ]; then
    echo "Usage: $0 {numfiles} {user@ipaddress}"
    exit 1
fi

NUM="$1"
DEST="$2"

# Create new files of random data.
/usr/bin/time -v python ./randomfiles.py -n "$NUM"

# Load them into cache
find . -name '*.iotest' -print0 | xargs -0 vmtouch -t


# probably the fastest?
/usr/bin/time -v rsync ./*.iotest "$2:."

# different stats
pv ./*.iotest | "$2" "cat > /dev/null"



