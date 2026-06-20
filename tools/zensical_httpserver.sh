#! /usr/bin/env bash
SCRIPT="$(readlink -f $0)"
PARENT="$(dirname ${SCRIPT%/*})"
ZENDIR="$PARENT/.github/zensical"
ENVDIR="$ZENDIR/.venv"


detect_linux() {
	NAME="$(sed -rn 's/^NAME=//p' /etc/os-release 2>/dev/null)"
	NAME="$(echo $NAME | sed 's/"//g;s/ *Linux *//;s/ .*//;s/\..*//')"
	VERSION="$(sed -rn 's/^VERSION=//p' /etc/os-release 2>/dev/null)"
	VERSION="$(echo $VERSION | sed 's/"//g;s/ .*//;s/\..*//')"
	echo "$NAME$VERSION"
}

install_python() {
	local SUDO DOY="$1"
	local OSV="$(detect_linux)"
	[ -z "$OSV" ] && echo 'Can not detect your Linux version, failed.' && exit 1
	[ -x "$(command -v sudo)" ] && SUDO="sudo" || SUDO=""
	[ -x "$(command -v apt)"  ] && APT="apt"   || APT="apt-get"

	case "${OSV##*/}" in
		Fedora*)                                    $SUDO dnf --refresh  install $DOY python3 python3-pip python3-virtualenv || exit 1 ;;
		Debian*|Devuan*|LMDE*) $SUDO $APT update && $SUDO $APT           install $DOY python3 python3-pip python3-venv       || exit 1 ;;
		Ubuntu*|Mint*)         $SUDO $APT update && $SUDO $APT           install $DOY python3 python3-pip python3-venv       || exit 1 ;;
		*)                     echo 'You Linux distribution is not yet supported'                                            && exit 1 ;;
	esac
}

setup_virtenv() {
	[ -x "$(command -v python3)" ] || \
	  python3 -m venv -h >/dev/null 2>&1 || \
	  [ -x "$(command -v pip3)" ] || \
	  install_python || exit 1

	python3 -m venv "$ENVDIR"                                   || exit 1
	source "$ENVDIR/bin/activate"                               || exit 1
	pip3 install --upgrade pip                                  || exit 1
	pip3 install -r "$ZENDIR/requirements.txt"                  || exit 1
}

run_httpserver() {
	local PORT="$1"
	[ "$PORT" -gt 0 ] 2>/dev/null || PORT="8000"

	[ -d "$ENVDIR" ] || setup_virtenv || exit 1

	echo "########################################################################"
	echo "     Starting zensical http server on [::]:$PORT, use CTRL+C to quit."
	echo "########################################################################"

	source "$ENVDIR/bin/activate"
	zensical serve --dev-addr "[::]:$PORT" --config-file "$ZENDIR/zensical.toml"  # --open
}

cleanup_virtenv() {
	rm -rf "$ENVDIR"
	rm -rf "$ZENDIR/.cache/"
	rm -rf "$ZENDIR/site/"
	echo "Done."
}

show_usage() {
	cat << EOF

	Zensical http server

	Usage: $0 [ install [-y] | setup | run [port] | cleanup ]

	 - install [-y]
	   Installs packages by package-manager, python3, pip3 and venv.
	   You will be asked for sudo password if you have no sufficent permissions.
	   If sudo is not installed you need to have permissions to install packages.
	   To install instantly and without question use the '-y' parameter.
	   Executed by "setup" if not yet done.

	 - setup
	   Sets up virtual Python environemnt for Zensical.
	   Executed by "run" if not yet done.

	 - run [port]
	   Runs Zensical http server listening on all ips.
	   Default Port: 8000/tcp

	 - cleanup
	   Removes caches and virtual environment directories, needs setup again.

EOF
	exit 1
}


ARG="$1"
shift
[ "$1" == '-y' ] && shift && DOY="-y" || DOY=""
PORT="$1"

case "$ARG" in
	i|install)	install_python "$DOY" ;;
	s|setup)	setup_virtenv ;;
	r|run)		run_httpserver "$PORT" ;;
	c|cleanup)	cleanup_virtenv ;;
	*)		show_usage ;;
esac

exit 0

