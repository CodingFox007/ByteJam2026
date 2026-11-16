#!/bin/sh
printf '\033c\033]0;%s\a' ByteJam26
base_path="$(dirname "$(realpath "$0")")"
"$base_path/ByteJam26" "$@"
