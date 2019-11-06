#!/usr/bin/env bash

watch -n 30 'git pull >> pull.log' &>/dev/null &
#ps aux | grep 'watch -n 30 git pull'

