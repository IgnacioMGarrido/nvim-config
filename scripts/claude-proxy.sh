#!/bin/bash
# Proxy script for Avante to use Claude CLI

# Read the prompt from stdin or arguments
if [ -p /dev/stdin ]; then
    prompt=$(cat)
else
    prompt="$*"
fi

# Call Claude CLI with streaming JSON output
claude --print --output-format stream-json "$prompt"
