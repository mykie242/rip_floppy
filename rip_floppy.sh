#!/bin/bash

# Function to get the epoch time
get_epoch_time() {
  date +%s
}

# Default path to the floppy disk
DEFAULT_DISK_PATH="/dev/disk8"

# Check for command-line argument and set DISK_PATH
if [ -z "$1" ]; then
  DISK_PATH=${DEFAULT_DISK_PATH}
else
  DISK_PATH="$1"
fi

# Function to get the disk label
get_disk_label() {
  local mount_point=$(diskutil info "${DISK_PATH}" | grep 'Mount Point' | awk -F ':' '{print $2}' | xargs)
  if [ -z "${mount_point}" ]; then
    echo "Failed to get mount point. Please check the disk."
    return 1
  fi
  diskutil info "${DISK_PATH}" | grep 'Volume Name' | awk -F ':' '{print $2}' | xargs
}

# Function to check if the floppy disk is ready
is_disk_ready() {
  local mount_point=$(diskutil info "${DISK_PATH}" | grep 'Mount Point' | awk -F ':' '{print $2}' | xargs)
  [ ! -z "${mount_point}" ]
}

# Function to check if the floppy disk is empty, ignoring hidden system files
is_disk_empty() {
  local mount_point=$(diskutil info "${DISK_PATH}" | grep 'Mount Point' | awk -F ':' '{print $2}' | xargs)
  rm -rf "${mount_point}/.{,_.}{fseventsd,Spotlight-V*,Trashes}"
  file_count=$(find "${mount_point}" -type f ! -path "${mount_point}/.fseventsd/*" ! -path "${mount_point}/.Spotlight-V*" ! -path "${mount_point}/.Trashes/*" 2>/dev/null | wc -l | tr -d ' ')
  [ "${file_count}" -eq 0 ]
}

# Function to rip the floppy disk and write directly to a DMG
rip_floppy() {
  local epoch_time=$(get_epoch_time)
  local disk_label=$(get_disk_label)
  
  # Use "floppy" if the disk label is empty or "NO NAME"
  if [ -z "$disk_label" ] || [ "$disk_label" == "NO NAME" ]; then
    disk_label="floppy"
  fi
  
  local output_file="${disk_label}-${epoch_time}.dmg"
  
  echo "Checking if the floppy disk is empty..."
  if is_disk_empty; then
    echo "The floppy disk is empty. Please insert a new disk."
    return
  fi
  
  echo "Found ${file_count} visible files on the disk."
  
  echo "Unmounting floppy disk..."
  diskutil unmountDisk "${DISK_PATH}"
  echo "Ripping floppy disk to ${output_file}..."
  dd if="${DISK_PATH}" of="${output_file}" bs=512 conv=noerror,sync
  if [ $? -ne 0 ]; then
    echo "Error: The 'dd' command failed. Please check the disk and try again."
    return
  fi
  echo "DMG created as ${output_file}"
}

# Function to wait for floppy disk removal
wait_for_removal() {
  while [ -e "${DISK_PATH}" ]; do
    echo -ne "Please remove the floppy disk... \r"
    sleep 1
  done
  echo "Floppy disk removed.                     "
}

# Function to wait for a new floppy disk insertion and check if it's not empty
wait_for_new_insertion() {
  while true; do
    if [ -e "${DISK_PATH}" ]; then
      if is_disk_ready && ! is_disk_empty; then
        echo "New floppy disk detected.                   "
        return
      fi
    fi
    echo -ne "Waiting for a new floppy disk insertion... \r"
    sleep 1
  done
}

# Main loop to monitor floppy disk insertion and handle the initial state
while true; do
  if [ -e "${DISK_PATH}" ]; then
    rip_floppy
    wait_for_removal
  else
    wait_for_new_insertion
  fi
done
