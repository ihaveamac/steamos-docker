# SteamOS 3 Docker Image

* Docker Hub repo: https://hub.docker.com/r/ianburgwin/steamos
* GitHub repo: https://github.com/ihaveamac/steamos-docker

This is a fork of the [Arch Linux Docker Image](https://gitlab.archlinux.org/archlinux/archlinux-docker) repo with alterations to build an image using the SteamOS repository.

Building this has only been tested on a Steam Deck. It might also work on standard Arch Linux. It wouldn't work on other distros that lack pacman.

This adds an extra user, "deck", which SteamOS always includes for Steam Deck users.

This repo has the following tags:
## 3.4
* `base`, `3.4`, `3.4-base`, `latest`: SteamOS with only the `base` group.
* `base-devel`, `3.4-base-devel`: Includes the `base-devel` group.
* `buildpack`, `3.4-buildpack`: Based on `base-devel`, this includes these packages: `cmake linux-neptune linux-neptune-headers python python-pip wget unzip git sdl2`
* `buildpack-extra`, `3.4-buildpack-extra`: Based on `buildpack`, this includes these packages: `qt5-tools`
## 3.5 (preview)
* `base`, `3.5`, `3.5-base`, `latest`: SteamOS with only the `base` and `holo-base` groups.
* `base-devel`, `3.5-base-devel`: Includes the `base-devel` group.
* `buildpack`, `3.5-buildpack`: Based on `base-devel`, this includes these packages: `cmake linux-neptune linux-neptune-headers python python-pip wget unzip git sdl2`
* `buildpack-extra`, `3.5-buildpack-extra`: Based on `buildpack`, this includes these packages: `qt5-tools`

## Extras

More stuff in the `extras/` subdir.

* `Docker-winebuilder` - Based on `3.4-buildpack`, it installs a bunch of extra packages that I used to build Wine.
