DOCKER=docker
BUILDDIR=$(shell pwd)/build
OUTPUTDIR=$(shell pwd)/output

define rootfs
	mkdir -vp $(BUILDDIR)/alpm-hooks/usr/share/libalpm/hooks
	find /usr/share/libalpm/hooks -exec ln -sf /dev/null $(BUILDDIR)/alpm-hooks{} \;

	mkdir -vp $(BUILDDIR)/var/lib/pacman/ $(OUTPUTDIR)
	install -Dm644 pacman-steamos.conf $(BUILDDIR)/etc/pacman.conf
	cat pacman-conf.d-noextract.conf >> $(BUILDDIR)/etc/pacman.conf

	fakechroot -- fakeroot -- pacman -Sy -r $(BUILDDIR) \
		--noconfirm --dbpath $(BUILDDIR)/var/lib/pacman \
		--config $(BUILDDIR)/etc/pacman.conf \
		--noscriptlet \
		--hookdir $(BUILDDIR)/alpm-hooks/usr/share/libalpm/hooks/ $(2)

	cp --recursive --preserve=timestamps --backup --suffix=.pacnew rootfs/* $(BUILDDIR)/

	fakechroot -- fakeroot -- chroot $(BUILDDIR) update-ca-trust
	fakechroot -- fakeroot -- chroot $(BUILDDIR) sh -c 'pacman-key --init && pacman-key --populate && bash -c "rm -rf etc/pacman.d/gnupg/{openpgp-revocs.d/,private-keys-v1.d/,pubring.gpg~,gnupg.S.}*"'

	ln -fs /usr/lib/os-release $(BUILDDIR)/etc/os-release

	# add system users
	fakechroot -- fakeroot -- chroot $(BUILDDIR) /usr/bin/systemd-sysusers --root "/"

	# remove passwordless login for root (see CVE-2019-5021 for reference)
	sed -i -e 's/^root::/root:!:/' "$(BUILDDIR)/etc/shadow"

	# fakeroot to map the gid/uid of the builder process to root
	# fixes #22
	fakeroot -- tar --numeric-owner --xattrs --acls --exclude-from=exclude -C $(BUILDDIR) -c . -f $(OUTPUTDIR)/$(1).tar

	cd $(OUTPUTDIR); zstd --long -T0 -8 $(1).tar; sha256sum $(1).tar.zst > $(1).tar.zst.SHA256
endef

define dockerfile
	sed -e "s|TEMPLATE_ROOTFS_FILE|$(1).tar.zst|" \
	    -e "s|TEMPLATE_ROOTFS_RELEASE_URL|Local build|" \
	    -e "s|TEMPLATE_ROOTFS_DOWNLOAD|ROOTFS=\"$(1).tar.zst\"|" \
	    -e "s|TEMPLATE_ROOTFS_HASH|$$(cat $(OUTPUTDIR)/$(1).tar.zst.SHA256)|" \
	    -e "s|TEMPLATE_VERSION_ID|dev|" \
	    Dockerfile.template > $(OUTPUTDIR)/Dockerfile.$(1)
endef

define dockerfile-extra
	sed -e "s|TEMPLATE_BASE_TAG|$(2)|" \
	    -e "s|TEMPLATE_PACKAGES|$(3)|" \
	    Dockerfile.extra.template > $(OUTPUTDIR)/Dockerfile.$(1)
endef

.PHONY: clean
clean:
	rm -rf $(BUILDDIR) $(OUTPUTDIR)

$(OUTPUTDIR)/base.tar.zst:
	$(call rootfs,base,base)

$(OUTPUTDIR)/Dockerfile.base: $(OUTPUTDIR)/base.tar.zst
	$(call dockerfile,base)

$(OUTPUTDIR)/Dockerfile.base-devel: $(OUTPUTDIR)/Dockerfile.base
	$(call dockerfile-extra,base-devel,base,base-devel)

$(OUTPUTDIR)/Dockerfile.buildpack: $(OUTPUTDIR)/Dockerfile.base-devel
	$(call dockerfile-extra,buildpack,base-devel,cmake linux-neptune linux-neptune-headers python python-pip wget unzip git sdl2)

$(OUTPUTDIR)/Dockerfile.buildpack-extra: $(OUTPUTDIR)/Dockerfile.buildpack
	$(call dockerfile-extra,buildpack-extra,buildpack,qt5-tools)

.PHONY: docker-image-base
image-base: $(OUTPUTDIR)/Dockerfile.base
	${DOCKER} build -f $(OUTPUTDIR)/Dockerfile.base -t ianburgwin/steamos:latest -t ianburgwin/steamos:base -t ianburgwin/steamos:3.4 -t ianburgwin/steamos:3.4-base $(OUTPUTDIR)

# these are changed to not send the build context, which will probably be big due to the rootfs for the base image
# i don't really know makefiles that well
.PHONY: docker-image-base-devel
image-base-devel: image-base $(OUTPUTDIR)/Dockerfile.base-devel
	${DOCKER} build -t ianburgwin/steamos:base-devel -t ianburgwin/steamos:3.4-base-devel - < $(OUTPUTDIR)/Dockerfile.base-devel

.PHONY: docker-image-buildpack
image-buildpack: image-base-devel $(OUTPUTDIR)/Dockerfile.buildpack
	${DOCKER} build -t ianburgwin/steamos:buildpack -t ianburgwin/steamos:3.4-buildpack - < $(OUTPUTDIR)/Dockerfile.buildpack

.PHONY: docker-image-buildpack-extra
image-buildpack-extra: image-buildpack $(OUTPUTDIR)/Dockerfile.buildpack-extra
	${DOCKER} build -t ianburgwin/steamos:buildpack-extra -t ianburgwin/steamos:3.4-buildpack-extra - < $(OUTPUTDIR)/Dockerfile.buildpack-extra
