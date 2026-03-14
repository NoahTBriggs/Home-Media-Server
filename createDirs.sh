#!/bin/bash

# This script creates the necessary directory structure for this media server setup:
# /srv
# ├── torrents             # Active torrent downloads
# │   ├── complete           # Completed Torrents
# │   └── incomplete         # Active Torrents
# ├── transfers            # Clean files ready for import into media library
# ├── media                # Organized media library
# │   ├── movies             # Downloaded Movies
# │   ├── shows              # Downloaded TV Shows
# │   ├── music              # Downloaded Music
# │   └── personal_media     # Downloaded Personal Media (home videos, etc.)
# └── docker               # Internal Docker Container Data
#     └── appdata
#         ├── jellyfin
#         │   └── config
#         ├── sonarr
#         │   └── config
#         ├── radarr
#         │   └── config
#         ├── prowlarr
#         │   └── config
#         ├── bazarr
#         │   └── config
#         └── overseerr
#             └── config

# NOTE: This script should be run with root privileges to ensure that the 
#       created directories have the correct ownership and permissions for the 
#       media server applications. If you run this script without root 
#       privileges, you may encounter permission issues when the applications 
#       try to access these directories.

# Exit Codes:
#   0 - Success
#   1 - Not run as root
#   2 - Error creating directories

if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root. Please run with sudo or as a root user."
  echo "Usage: sudo ./createDirs.sh"
  exit 1
fi

{ mkdir -p "/srv/"{"torrents","transfers","media","docker/appdata"} && \
  mkdir -p "/srv/torrents/"{"complete","incomplete"} && \
  mkdir -p "/srv/media/"{"movies","shows","music","personal_media"} && \
  mkdir -p "/srv/docker/appdata/"{"jellyfin/config","jellyfin/cache","sonarr/config","radarr/config","prowlarr/config","bazarr/config","overseerr/config","qbittorrent/config"} && \
  mv "./docker-compose.yml" "/srv/docker/" && \
  echo "Directories created successfully."; } || \
  echo "An error occurred while creating directories." && exit 2