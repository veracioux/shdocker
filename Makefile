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
			 "${DESTDIR}${PREFIX}/lib/shdocker" \
			 "${DESTDIR}${PREFIX}/share/man/man1/"
	cat _build/shdocker | sed "0,/__SHDOCKER_PREFIX=.*/s::__SHDOCKER_PREFIX='${PREFIX}':" > /tmp/shdocker_with_injected_vars
	chmod a+rw /tmp/shdocker_with_injected_vars
	@# Inject a __SHDOCKER_PREFIX variable definition into the shdocker script
	install -Dm755 /tmp/shdocker_with_injected_vars "${DESTDIR}${PREFIX}/bin/shdocker"
	install -Dm755 lib.sh.in       "${DESTDIR}${PREFIX}/lib/shdocker/"
	install -Dm755 converter.sh    "${DESTDIR}${PREFIX}/lib/shdocker/"
	install -Dm644 man/shdocker.1  "${DESTDIR}${PREFIX}/share/man/man1/"

clean:
	rm -rf _build
