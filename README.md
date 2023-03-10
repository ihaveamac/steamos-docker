# SteamOS 3 Docker Image

This is a fork of the [Arch Linux Docker Image](https://gitlab.archlinux.org/archlinux/archlinux-docker) repo with alterations to build an image using the SteamOS repository.

This repo has the following tags:
* `base`, `3.4`, `3.4-base`, `latest`: SteamOS with only the `base` group.
* `base-devel`, `3.4-base-devel`: Includes the `base-devel` group.
* `buildpack`, `3.4-buildpack`: Based on `base-devel`, this includes these packages: `cmake linux-neptune linux-neptune-headers python python-pip wget unzip git`
* `buildpack-extra`, `3.4-buildpack-extra`: Based on `buildpack`, this includes these packages: `qt5-base`

* Docker Hub repo: https://hub.docker.com/r/ianburgwin/steamos
* GitHub repo: https://github.com/ihaveamac/steamos-docker
