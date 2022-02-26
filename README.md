<h1 align="center">shdocker</h1>
<h2 align="center">Dockerfiles with shell superpowers</h2>

<p align="center">
  <a href="https://aur.archlinux.org/packages/shdocker/"> <img src="https://img.shields.io/aur/version/shdocker?label=AUR" alt="AUR"/> </a>
  <a href="./LICENSE"><img src="https://img.shields.io/badge/License-MIT-blueviolet" alt="License"/></a>
  <a href="https://matrix.org/#/#shdocker:matrix.org">
    <img src="https://img.shields.io/static/v1?label=Chat&message=matrix&color=%23c2185b">
  </a>
</p

Shdocker is a tiny utility that allows you to write Dockerfiles with shell
features. It is basically a shell-based template engine with Dockerfiles in
mind.

Shdocker is based around a `shDockerfile` which is very similar to a
regular Dockerfile, and in many cases is exactly the same...

## Use cases

#### Create builds from base images that depend on environment variables

**Example:**

```Dockerfile
# file: shDockerfile
FROM "$base:$ver"
RUN apk add git
```

If you run:

```sh
base=alpine ver=3.14.1 shdocker
```

you will generate the following
Dockerfile:

```Dockerfile
FROM alpine:3.14.1
RUN apk add git
```

#### Run different Dockerfile commands for each base image

**Example:**
```Dockerfile
FROM "$base"
if [ "$base" = "ubuntu" ]; then
    RUN apt install -y git
elif [ "$base" = "alpine" ]; then
    RUN apk add git
fi
```

#### Add a default tag in the `shDockerfile`

**Example:**

```Dockerfile
FROM alpine
RUN apk add --no-cache git
TAG my-image:latest
```

By running `shdocker .`, you will build an image tagged as
`my-image:latest`.

#### ...And much more
You can do anything you can imagine using shell features. **In fact, I'd be
honored if you shared your use cases with the community :).**

Let's get you started with a more holistic example:

**Example:**

```Dockerfile
[ -z "$ver" ] && ver="latest"

REQUIRE_ENV base # marks this environment variable as required
FROM "$base:$ver"

## Dependencies
# (whole-line comments starting with ## are included in the output Dockerfile)
common_deps=(git make)
alpine_deps=(python3 py3-rich)
archlinux_deps=(python python-rich)

if [ "$base" = "alpine" ]; then
    RUN apk add --no-cache "${common_deps[@]}" "${alpine_deps[@]}"
elif [ "$base" = "archlinux" ]; then
    RUN pacman -Sy --noconfirm "${common_deps[@]}" "${archlinux_deps[@]}"
else
    echo "Unsupported base image: $base" >&2
    exit 1
fi

TAG shdocker-example:"$base"
```

## Installation

```
make
sudo make install
```
**Dependencies:** `bash`, `docker`.

That's it. Or you can install using your package manager (currently only ArchLinux is
supported via AUR).

## How to use

The procedure is dead simple:

- Create a shDockerfile (or adapt an existing Dockerfile into one)
- Run `shdocker` with or without options
- End up with an actual Dockerfile or with a built docker image

##### Generate a Dockerfile from a shDockerfile

Just create a `shDockerfile` and run:

```
shdocker
```

This will automatically find the shDockerfile in the current directory and
output the generated Dockerfile content to stdout. You can be more specific and
specify the exact input (`shDockerfile`) and output (`Dockerfile`) files, like
so:

```
shdocker -s shDockerfile -d Dockerfile
```

##### Build a docker image directly from a shDockerfile

You just have to specify a context directory to `shdocker`:

```
shdocker -s shDockerfile -d Dockerfile .
```

Because we specified the `-d` option, a Dockerfile will be generated in the
current directory as a side-effect.

Actually, you can tell `shdocker` which options it should pass to `docker
build`. This is valid:

```
shdocker -s shDockerfile -- -t my-tag --quiet .
```

Note that the `--` is necessary so `shdocker` doesn't think you are passing the
`-t` and `--quiet` options to it, but to `docker build` instead.

## Documentation

If you have any questions, consult the `shdocker(1)` manpage. If you can't
find an answer there, you can open an issue, or ask in the [matrix chat](https://matrix.org/#/#shdocker-general:matrix.org).

## Contributing

Everyone is free to contribute. You can simply open a PR, but I'd prefer if you
opened an issue so we can discuss the changes first.

## Projects using shdocker

- [tuterm](https://github.com/veracioux/tuterm) - A better way to learn CLI programs

*P.S. Please let me know about your project. I'll be glad to put it here, or you
can do that yourself with a PR.*
