#!/bin/sh
echo -ne '\033c\033]0;pomodorot\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/pomodorot.x86_64" "$@"
