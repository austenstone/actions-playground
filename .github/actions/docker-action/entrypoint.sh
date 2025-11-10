#!/bin/sh -l

greeting="Hello $1"
echo "$greeting"

# Output for use in subsequent steps
echo "greeting=$greeting" >> $GITHUB_OUTPUT
