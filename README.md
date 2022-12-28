# SteamOS 3 Docker Image

This is a fork of the [Arch Linux Docker Image](https://gitlab.archlinux.org/archlinux/archlinux-docker) repo with alterations to build an image using the SteamOS repository.

The main change (so far) is that `pacman.conf` was taken from a Steam Deck running SteamOS 3.4 and edited to include the mirror path (instead of depending on `/etc/pacman.d/mirrorlist`).

* Docker Hub repo: https://hub.docker.com/r/ianburgwin/steamos
* GitHub repo: https://github.com/ihaveamac/steamos-docker
