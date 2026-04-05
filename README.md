# Home-Media-Server

Easy to deploy home media server (with support for the retrieval of new media, subtitles, and metadata).

## Description

This project is meant to handle the initial setup of the server; further configurations are handled in-browser.

## Getting Started

### Dependencies
- UNIX based OS (I'm on Ubuntu Server)
- BASH (https://www.gnu.org/software/bash/)
- Docker Engine (https://docs.docker.com/engine/install/)
- Tailscale (https://tailscale.com/download)

### Install/Initial Setup

* Configure the `.env` file in the `/res` directory to your liking.
  * `PGID`, `PUID`, and `JELLYFIN_PGID` are set automatically within the `/src/createDirs.sh` script.
    * You have the option to skip this step when running the script if you'd rather preserve what's in the `.env` file.
  * Update your `TS_AUTH_KEY` with an Reusable, and Ephemeral key; generated via https://login.tailscale.com/admin/settings/keys
* Via Tailscale enable HTTPS certificates (https://login.tailscale.com/admin/dns; under _HTTPS Certificates_); this allows the use of serve, allowing access outside of LAN but within your own tailscale network.
* Initial setup is handled by the `/src/createDirs.sh` script nearly automatically. (NOTE: Script execution MUST be prefixed by `sudo`)
  * Generates directory structure
  * Generates new user and group if required
  * Applies ownership and permissions automatically
  * Creates a backup of an already existing server in current working directory (preserves everything)
  * Automatically copies over the `/res/docker-compose.yml` and `/res/.env` files to `/${SRV_DIR}/docker/`

### Executing program

* Change your current directory to `/${SRV_DIR}/docker/`
  ```sh
  cd /${SRV_DIR}/docker/
  ```
  Example: `cd /My_Srv/docker`
* Run the following `docker compose` command:
  ```sh
  docker compose up -d
  ```

* Ensure everything is running with the following command:
  ```sh
  docker ps
  ```
* Find the jellyfin-node address (`<JF_ADDRESS>`)
  * Address is located on https://login.tailscale.com/admin/machines. It is the address associated with the `jellyfin-node` machine.
  * Alternatively using the terminal call the following to return the IP Address that you can use: 
    ```sh
    tailscale status | grep "jellyfin-node" | awk '{print $1}'
    ```
* Test your connection (while running a Tailscale client on your device) at:
  ```
  http://<JF_ADDRESS>:8096/
  ```
  Examples: 
  - `http://100.126.41.65:8096/`
  - `http://jellyfin-node.tail564wa2.ts.net:8096/`
<!-- FOR ANOTHER TIME
## Help

## Authors

## Version History

## License

## Acknowledgments
-->
