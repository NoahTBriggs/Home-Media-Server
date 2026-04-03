# Home-Media-Server

Easy to deploy home media server (with support for the retrieval of new media, subtitles, and metadata).

## Description

This project is meant to handle the initial setup of the server; further configurations are handled in-browser.

## Getting Started

### Dependencies
- UNIX based OS (I'm on Ubuntu Server)
- BASH
- Docker
- Docker Compose

### Install/Initial Setup

* Configure the `.env` file in the `/res` directory to your liking.
  * `PGID`, `PUID`, and `JELLYFIN_PGID` are set automatically within the `/src/createDirs.sh` script.
  * You have the option to skip this step when running the script if you'd rather preserve what's in the `.env` file.
* Initial setup is handled by the `/src/createDirs.sh` script nearly automatically. (NOTE: Script execution MUST be prefixed by `sudo`)
  * Generates directory structure
  * Generates new user and group if required
  * Applies ownership and permissions automatically
  * Creates a backup of an already existing server in `/tmp` (preserves everything)
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

* Ensure everything is running with the following command
```sh
docker ps
```
* While on the same network, test your connection at:
```
http://<YOUR_SERVER_HOSTNAME_OR_IPv4_ADDRESS>:8096/
```
Example: `http://homeserver:8096/`
<!-- FOR ANOTHER TIME
## Help

## Authors

## Version History

## License

## Acknowledgments
-->
