#!/bin/bash
# Script to apply patches in their corresponding repositories
# Run from the root of the ESP repository.

set -e

ROOT_DIR=$(git rev-parse --show-toplevel)

apply_patch() {
  local patch_path="$1"
  local target_dir="$2"
  local patch_name patch_abs target_abs
  patch_name=$(basename "$patch_path")
  patch_abs="${ROOT_DIR}/${patch_path}"
  target_abs="${ROOT_DIR}/${target_dir}"

  if [ -f "$patch_abs" ]; then
    echo "Checking $patch_name in $target_dir ..."
    if [ -d "$target_abs" ]; then
      if git -C "$target_abs" apply --reverse --check "$patch_abs" 2>/dev/null; then
        echo "$patch_name is already applied."
      elif git -C "$target_abs" apply --check "$patch_abs" 2>/dev/null; then
        git -C "$target_abs" apply "$patch_abs"
        echo "$patch_name applied successfully."
      else
        echo "$patch_name cannot be applied."
      fi
    else
      echo "Target directory $target_dir does not exist."
    fi
  else
    echo "$patch_name not found at $patch_path"
  fi
}

# Apply patches (relative to repo root)
apply_patch "patches/cva6.patch" "rtl/cores/cva6/cva6"
apply_patch "patches/esp-fpga.patch" "soft/cva6/opensbi"
apply_patch "patches/esp-caches.patch" "rtl/caches/esp-caches"
echo "All patches applied (if they existed)."
