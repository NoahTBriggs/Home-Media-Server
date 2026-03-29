#!/bin/bash

# This script: 
# - Checks for root privileges and exits if not run as root
#
# - Optionally automatically configures PUID and PGIDs in the .env file
#
# - Validates the SRV_DIR and SRV_USER variables from the .env file to prevent 
#   critical system directories or users from being used
#
# - Performs a backup of the existing SRV_DIR if it exists and is not empty, 
#   then clears it for new directory structure creation
#   - Otherwise it creates the SRV_DIR if it doesn't already exist
#
# - Creates the necessary directory structure and permissions for this media
#   server setup:
# /$SRV_DIR
# ├── media                # Organized media library
# │   ├── movies             # Downloaded Movies
# │   ├── shows              # Downloaded TV Shows
# │   ├── music              # Downloaded Music
# │   └── personal_media     # Downloaded Personal Media (home videos, etc.)
# └── docker               # Internal Docker Container Data
#     └── appdata
#         └── jellyfin
#             ├── config
#             └── cache
#
# - Modifies ownership and permissions of the created directories
#
# - Copies the docker-compose.yml and .env files to the $SRV_DIR/docker/ 
#   directory for use by the media server applications

# NOTE: This script must be run with root privileges to ensure that the created
#       directories have the correct ownership and permissions for the media
#       server applications. If you run this script without root privileges, 
#       you may encounter permission issues when the applications try to access 
#       these directories.

# Exit Codes:
#   0 - Success
#   1 - Root privilege check failed
#   2 - .env file failed to import
#   3 - Validation of .env variables failed (SRV_DIR or SRV_USER)
#   4 - SRV_DIR is not writable
#   5 - Backup of existing SRV_DIR failed or subsequent clearing of SRV_DIR failed
#   6 - Directory creation failed
#   7 - Creation of SRV_USER failed or adding existing SRV_USER to docker group failed
#   8 - Setting ownership and permissions failed

source ./ID_Util.sh

echo "Performing Root Privilege Check..."
if [ "$EUID" -ne 0 ]; then
  echo "  This script must be run as root. Please run with sudo or as a root user."
  echo "  Usage: sudo ./createDirs.sh"
  exit 1
fi
echo "Root Privilege Check Passed."
echo ""

echo "Starting Media Server Directory Setup..."
echo "Importing .env configuration..."
echo "  Checking For .env File..."
if [ -f ".env" ]; then
  echo "  .env file Found..."
else
  echo "  No .env file found. Creating one with default values..."
  cat > .env << EOF
###############################################################################
## USER CONFIGURATION - MODIFY AS NEEDED                                      #
###############################################################################

# Desired Media Server Directory 
# (Will be created if it doesn't already exist)
# (example: "/srv", "/media", "/data", etc.)
SRV_DIR="/srv" 

# Desired User Name For Media Server Ownership 
# (Will be created if it doesn't already exist)
# (example: "media-srv", "home-srv", "media", etc.)
SRV_USER="docker" 

# Specific User and Group IDs for all Docker Containers
# (Default (all): "1000")
PUID="1000"
PGID="1000"
JELLYFIN_PGID="1000"
EOF
  echo "  .env created with defaults."
fi

read -n1 -p "Do you want to automatically configure PUID and PGIDs [y/n]: " answer
answer=${answer,,} # Convert to lowercase
if [[ "$answer" == "y" ]]; then
  echo ""
  echo "  Setting PUID and PGIDs based on current user and render/video groups..."
  set_IDs
  echo "PUID and PGIDs set successfully."
else
  echo ""
  echo "Skipping automatic PUID and PGID configuration."
fi

echo "  Loading configuration from .env file..."
export $(grep -v '^#' .env | xargs) || { echo "Failed to load configuration from .env file."; exit 2; }
echo "Configuration Loaded Successfully."

echo "Validating SRV_DIR Value..."
if [ "$SRV_DIR" = "" ] || [ "$SRV_DIR" = "/" ] || [ "$SRV_DIR" = "/root" ] || [ "$SRV_DIR" = "/home" ] || [[ "$SRV_DIR" =~ ^/usr|^/var|^/etc ]]; then
  echo "  Error: SRV_DIR cannot be set to a critical system directory or \"\"."
  echo "  Please edit .env and set SRV_DIR to a safe subdirectory (e.g., \"/srv-test\")."
  exit 3
fi
echo SRV_DIR Value Validated Successfully.
echo ""

echo "Validating SRV_USER Value..."
if [ $SRV_USER = "" ] || [[ "$SRV_USER" =~ ^(root|admin|sudo|www-data|nobody)$ ]]; then
  echo "  Error: SRV_USER cannot be set to a critical system user or \"\""
  echo "  Please edit .env and set SRV_USER to a safe name (e.g., \"/srv-test\")."
  exit 3
fi
echo SRV_USER Value Validated Successfully.
echo ""

echo "Target Media Server Directory: $SRV_DIR"
echo "Proposed Media Server User: $SRV_USER"
echo "Proposed PUID: $PUID"
echo "Proposed PGID: $PGID"
echo "Proposed JELLYFIN_PGID: $JELLYFIN_PGID"
echo ""

read -p "Click any key to proceed..." -n 1 -r
echo ""

echo "Backing Up And Formatting $SRV_DIR (if it exists)..."
if [ -d "$SRV_DIR" ] && [ ! -w "$SRV_DIR" ]; then
  echo "  $SRV_DIR exists but is not writable. Cannot proceed."
  exit 4
elif [ -d "$SRV_DIR" ] && [ "$(ls -A $SRV_DIR)" ]; then
  echo "  $SRV_DIR exists, creating a backup..."
  SRV_BACKUP="./srv_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
  tar -czf "$SRV_BACKUP" -C "$SRV_DIR" . || { echo "Backup Failed."; exit 5; }
  echo "    Backup created at: $SRV_BACKUP"
  echo "  Clearing $SRV_DIR for new directory structure..."
  rm -rf "${SRV_DIR:?}"/* || { echo "Failed To Clear $SRV_DIR After Backup."; exit 5; }
  echo "    $SRV_DIR cleared."
else
  echo "  $SRV_DIR will be created."
fi
echo "$SRV_DIR Is Ready For Directory Creation."
echo ""

echo "Creating Directory Structure..."
{ echo "  Creating base directories..." && \
  mkdir -p "$SRV_DIR/"{"media","docker/appdata"} && \
  echo "  Creating media subdirs..." && \
  mkdir -p "$SRV_DIR/media/"{"movies","shows","music","personal_media"} && \
  echo "  Creating appdata subdirs..." && \
  mkdir -p "$SRV_DIR/docker/appdata/"{"jellyfin/config","jellyfin/cache"}; } || \
  { echo "Directory Creation failed."; exit 6; }
echo "Directories Created Successfully."
echo ""

echo "Copying .YML Configuration File To $SRV_DIR/docker/..."
if [ -f "./docker-compose.yml" ]; then 
  echo "  Found docker-compose.yml. Copying to $SRV_DIR/docker/."
  cp "./docker-compose.yml" "$SRV_DIR/docker/"
  echo "Copy Successful."
else 
  echo "  Warning: docker-compose.yml not found in current directory."
  echo "Copy Unsuccessful."
fi

# Copy .env file if it exists
echo "Copying .env to $SRV_DIR/docker/..."
cp ".env" "$SRV_DIR/docker/" && \
echo ".env File Copied Successfully."
echo ""

echo "Setting Permissions And Ownership..."
# Adding "$SRV_USER" user if it doesn't already exist
if ! id -u "$SRV_USER" &>/dev/null; then
  echo "  Adding new user: $SRV_USER..."
  useradd -r -s /bin/bash -g docker "$SRV_USER" || { echo "  Failed to create user $SRV_USER."; exit 7; }
else
  echo "  User $SRV_USER already exists. Skipping user creation."
  usermod -aG docker "$SRV_USER" || { echo "  Failed to add existing user $SRV_USER to docker group."; exit 7; }
fi

# Setting ownership and permissions to entire server
echo "  Setting ownership..."
{ chown -R "$SRV_USER":"$SRV_USER" "${SRV_DIR:?}"/ && \
  echo "  Setting permissions..." && \
  chmod -R 777 "${SRV_DIR:?}"/ && \
  echo "  Recursively applying permissions..." && \
  find "${SRV_DIR:?}" -type d -exec chmod g+s {} \;; } || \
{ echo "Failed To Set Ownership And Permissions."; exit 8; }
echo "Permissions And Ownership Set Successfully."