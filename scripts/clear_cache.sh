#!/bin/bash

rm -rf /dev/shm/nginx/*

# add this line to the cronjob (>sudo crontab -e):
# 0 3 * * 0 /PATH_TO_HERE/scripts/clear_cache.sh
# the cache should be deleted every Sunday at 3am