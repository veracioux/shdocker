#!/usr/bin/env bash

# Copyright (c) 2022 The Shdocker Contributors
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# --------------------------------------------------------------------
# This is a helper script that generates a Dockerfile to STDOUT from a
# shDockerfile from STDIN
# --------------------------------------------------------------------

#  Options passed to the SHDOCKER command
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

__OPT_QUOTE="on"

if [ ! -f /.dockerenv ] || [ -z "$__SHDOCKER_INSIDE_CONTAINER" ]; then
    echo "This script must be run from shdocker, inside of a docker container" >&2
fi

# Run the docker command from "$1" with arguments from "${@:2}"
__dockerfile_command() {
    echo "$1" "$(__quote "${@:2}")"
}

# ┏━━━━━━━━┓
# ┃ ACTION ┃
# ┗━━━━━━━━┛

__DOCKERFILE_COMMANDS=(
    FROM MAINTAINER RUN CMD LABEL EXPOSE ENV ADD COPY ENTRYPOINT VOLUME
    USER WORKDIR ARG ONBUILD STOPSIGNAL HEALTHCHECK SHELL
)

for __docker_cmd in "${__DOCKERFILE_COMMANDS[@]}"; do
    eval "$__docker_cmd() { __dockerfile_command $__docker_cmd \"\$@\"; }"
done

TAG() {
    # __IMAGE_TAG_OUTPUT_FILE is an env variable passed from shdocker to this
    # script
    echo "$1" > "$__IMAGE_TAG_OUTPUT_FILE"
}

# Specify a list of environment variables that must exist when shdocker is run.
# If some of the variables don't exist, print an error message and exit.
#
#   Usage: REQUIRE_ENV VARIABLE_NAMES...
#
REQUIRE_ENV() {
    local missing
    missing="$(
        for var in "$@"; do
            [[ ! -v "$var" ]] && echo "$var"
        done
    )"
    if [ -n "$missing" ]; then
        echo "The following environment variables must be set for this shDockerfile:" >&2
        echo "$missing" | sed 's/^/    /' >&2
        exit 1
    fi
}

SHDOCKER() {
    if [ "$1" = "quote" ]; then
        if [ "$2" = "on" ]; then
            __OPT_QUOTE="on"
        elif [ "$2" = "off" ]; then
            __OPT_QUOTE=""
        else
            echo "shdocker: error: SHDOCKER: unrecognized arguments" >&2
        fi
    else
        echo "shdocker: error: SHDOCKER: unrecognized arguments" >&2
    fi
}

# Override some builtins to ensure parsing of ## comments

source() {
    builtin source <(sed "s/^[[:space:]]*##\(.*\)/cat <<$EOF\n#\1\n$EOF/g" "$@")
}

# The contents of shDockerfile will be appended here by shdocker

# vim: filetype=sh foldmethod=syntax
