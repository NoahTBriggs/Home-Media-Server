#!/bin/bash

function get_render_GID() {
  echo $(getent group render | grep -oP '(?<=render:x:)(\d+)')
}

function get_video_GID() {
  echo $(getent group video | grep -oP '(?<=video:x:)(\d+)')
}

function get_UID() {
  echo "$(id -u)"
}

function set_PGID() {
  sed -i "s/^ENV_GROUP_ID=\"[0-9]*\"/ENV_GROUP_ID=\"$1\"/" .env
}

function set_PUID() {
  sed -i "s/^ENV_USER_ID=\"[0-9]*\"/ENV_USER_ID=\"$1\"/" .env
}

function set_IDs() {
  local LOCAL_UID=$(get_UID);
  local LOCAL_GID=$(get_render_GID);
  
  # If the user's UID cannot be found use the default of 1000
  if [ -z "$LOCAL_UID" ]; then
    echo "  Warning: Could not determine current user's UID. Defaulting to 1000."
    LOCAL_UID=1000;
  fi

  # If the render group GID cannot be found, attempt to retrieve the video group GID
  if [ -z "$LOCAL_GID" ]; then
    echo "  Warning: Could not determine render group GID. Attempting to retrieve video group GID..."
    LOCAL_GID=$(get_video_GID)
  fi

  # If the video group GID cannot be found, use the UID
  if [ -z "$LOCAL_GID" ]; then
    echo "  Warning: Could not determine video group GID. Setting PGID to match PUID..."
    LOCAL_GID=$LOCAL_UID
  fi

  set_PUID "$LOCAL_UID";
  set_PGID "$LOCAL_GID";
}