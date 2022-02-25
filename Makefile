PREFIX ?= /usr/local
VERSION ?= 0.1.0
DOCKER_VERSION ?= 20.10.12

build:
	@# Inject a __SHDOCKER_VERSION variable definition into the shdocker script
	@# Inject a __DOCKER_VERSION variable definition into the shdocker script
	mkdir -p _build
	sed -e "0,/__SHDOCKER_VERSION=.*/s::__SHDOCKER_VERSION='${VERSION}':"   \
		-e "0,/__DOCKER_VERSION=.*/s::__DOCKER_VERSION='${DOCKER_VERSION}':" \
		shdocker > _build/shdocker

install:
	@# Install
	mkdir -p "${DESTDIR}${PREFIX}/bin" \
			 "${DESTDIR}${PREFIX}/lib/shdocker"
	install -Dm755 _build/shdocker "${DESTDIR}${PREFIX}/bin/"
	install -Dm755 converter.sh    "${DESTDIR}${PREFIX}/lib/shdocker/"

clean:
	rm -rf _build
