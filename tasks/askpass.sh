#!/bin/sh
# Do not change to /bin/bash; bash isn't installed on the build container
echo "Private keys with passphrases are not supported." >&2
exit 1