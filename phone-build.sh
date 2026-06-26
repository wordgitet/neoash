#!/bin/sh
# Sync source to phone and build neoash there.
# Usage: ./phone-build.sh

PHONE="192.168.1.170"
PORT=8022
PHONE_DIR="~/neoash"
PASS="claude"

echo "==> Syncing source to phone..."
sshpass -p "$PASS" rsync -az --exclude='.git' \
  --exclude='**/*.o' --exclude='**/*.Po' --exclude='**/*.Tpo' \
  --exclude='src/neoash' --exclude='src/mknodes' --exclude='src/mksyntax' \
  --exclude='src/nodes.c' --exclude='src/nodes.h' \
  --exclude='src/syntax.c' --exclude='src/syntax.h' \
  --exclude='src/builtins.c' --exclude='src/builtins.h' \
  --exclude='src/token.h' \
  -e "ssh -p $PORT -o StrictHostKeyChecking=no" \
  ./ u0_a432@$PHONE:$PHONE_DIR/

echo "==> Building on phone..."
sshpass -p "$PASS" ssh -p $PORT -o StrictHostKeyChecking=no $PHONE \
  "cd $PHONE_DIR && autoreconf -fi 2>&1 | tail -3 && \
   CC=gcc-15 LDFLAGS='-L/system/lib64 -L/data/data/com.termux/files/usr/lib' \
   ./configure 2>&1 | grep -E '(checking for|error|warning)' | tail -20 && \
   make -j4 2>&1 | tail -30"
