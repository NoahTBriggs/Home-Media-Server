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

* Configure the `.env` file to your liking.
  * `PGID`, `PUID`, and `JELLYFIN_PGID` are set automatically within `createDirs.sh`.
  * You have the option to skip this step when running the script if you'd rather preserve what's in the `.env` file.
* Initial setup is handled by the `createDirs.sh` script nearly automatically. (NOTE: This command must be prefixed by `sudo`)
  * Generates directory structure
  * Generates new user and group if required
  * Applies ownership and permissions automatically
  * Creates a backup of an already existing server in `/tmp` (preserves everything)
  * Automatically copies over the `docker-compose.yml` and `.env` files to `/${SRV_DIR}/docker/`

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

Any advise for common problems or issues.
```
command to run if program contains helper info
```

## Authors

Contributors names and contact info

ex. Dominique Pizzie  
ex. [@DomPizzie](https://twitter.com/dompizzie)

## Version History

* 0.2
    * Various bug fixes and optimizations
    * See [commit change]() or See [release history]()
* 0.1
    * Initial Release

## License

This project is licensed under the [NAME HERE] License - see the LICENSE.md file for details

## Acknowledgments

Inspiration, code snippets, etc.
* [awesome-readme](https://github.com/matiassingers/awesome-readme)
* [PurpleBooth](https://gist.github.com/PurpleBooth/109311bb0361f32d87a2)
* [dbader](https://github.com/dbader/readme-template)
* [zenorocha](https://gist.github.com/zenorocha/4526327)
* [fvcproductions](https://gist.github.com/fvcproductions/1bfc2d4aecb01a834b46)
-->
