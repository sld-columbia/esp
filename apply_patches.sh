#!/bin/bash
# Script to apply patches in their corresponding repositories
# Run from the root of the ESP repository.

apply_patch() {
  local patch_path="$1"
  local target_dir="$2"
  local patch_name patch_abs
  patch_name=$(basename "$patch_path")
  patch_abs="$(pwd)/$patch_path"
  if [ -f "$patch_path" ]; then
    echo "Checking $patch_name in $target_dir ..."
    if [ -d "$target_dir" ]; then
      pushd "$target_dir" > /dev/null
      if git apply --check "$patch_abs"; then
        git apply "$patch_abs"
        echo "$patch_name applied successfully."
      else
        echo "$patch_name is already applied or cannot be applied."
      fi
      popd > /dev/null
    else
      echo "Target directory $target_dir does not exist."
    fi
  else
    echo "$patch_name not found at $patch_path"
  fi
}

# Apply patches (relative to repo root)
apply_patch "patches/esp-caches.patch" "rtl/caches/esp-caches"
echo "All patches applied (if they existed)."