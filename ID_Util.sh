#!/bin/bash

function get_render_GID() {
  echo $(getent group render | grep -oP '(?<=render:x:)(\d+)')
}

function get_video_GID() {
  echo $(getent group video | grep -oP '(?<=video:x:)(\d+)')
}

function get_UID() {
  echo "${SUDO_USER:=$(whoami)}"
}

function set_PGID() {
  sed -i "s/^PGID=\"[0-9]*\"/PGID=\"$1\"/" .env
}

function set_jellyfin_PGID() {
  sed -i "s/^JELLYFIN_PGID=\"[0-9]*\"/JELLYFIN_PGID=\"$1\"/" .env
}

function set_PUID() {
  sed -i "s/^PUID=\"[0-9]*\"/PUID=\"$1\"/" .env
}

function set_IDs() {
  local PUID=$(get_UID);
  local PGID=$PUID;
  local JELLYFIN_PGID=$(get_render_GID);
  
  # If the user's UID cannot be found use the default of 1000
  if [ -z "$PUID" ]; then
    echo "  Warning: Could not determine current user's UID. Defaulting to 1000."
    PUID=1000;
  fi

  # If the render group GID cannot be found, attempt to retrieve the video group GID
  if [ -z "$JELLYFIN_PGID" ]; then
    echo "  Warning: Could not determine render group GID. Attempting to retrieve video group GID..."
    JELLYFIN_PGID=$(get_video_GID)
  fi

  # If the video group GID cannot be found, use the UID
  if [ -z "$JELLYFIN_PGID" ]; then
    echo "  Warning: Could not determine video group GID. Setting PGID to match PUID..."
    JELLYFIN_PGID=$PUID
  fi

  set_PUID "$PUID";
  set_PGID "$PGID";
  set_jellyfin_PGID "$JELLYFIN_PGID";
}