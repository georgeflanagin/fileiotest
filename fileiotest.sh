#!/bin/bash -e

# Best to [re]build vmtouch for this distro. It is not in
# the core OS.
if ! command -v vmtouch >/dev/null 2>&1; then
    echo "vmtouch not installed. Installing it"
    sudo dnf install -y gcc make git
    git clone https://github.com/hoytech/vmtouch.git
    cd vmtouch
    make
    sudo install -m 0755 vmtouch /usr/local/bin/
fi

# pv has the same limitation.
if ! command -v pv >/dev/null 2>&1; then
    echo "pv not installed. Installing it."
    dnf -y install pv
fi

if [ -z "$2" ]; then
    echo "Usage: $0 {numfiles} {user@ipaddress}"
    exit 1
fi

NUM="$1"
DEST="$2"

# Create new files of random data.
/usr/bin/time -v python ./randomfiles.py -n "$NUM"

# Load them into cache
find . -type f -name '*.iotest' -print0 | xargs -0 vmtouch -t
# find . -type f -name '*.iotest' -print0 | xargs -0 vmtouch



# Stats.
/usr/bin/time -v find . -type f -name '*.iotest' -print0 \
    | sort -z \
    | xargs -0 pv -ra8tpe -i 1 \
    | ssh -T -o BatchMode=yes "$2" "cat > /dev/null"


rm -fr *.iotest
