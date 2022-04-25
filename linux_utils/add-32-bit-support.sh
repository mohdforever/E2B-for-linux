#!/bin/bash
# Bash Script for adding 32-bit executable support to linux 64-bit systems
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386
