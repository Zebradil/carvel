#!/bin/bash

if test -z "$BASH_VERSION"; then
  echo "Please run this script using bash, not sh or any other shell." >&2
  exit 1
fi

install() {
	set -euo pipefail

	echo "Installing ytt..."
	wget -O- https://github.com/k14s/ytt/releases/download/v0.14.0/ytt-linux-amd64 > /tmp/ytt
	echo "20b644eea48c7580d9aa205378aef1211821e6a233d92cc8b1df26acf73773c6  /tmp/ytt" | shasum -c -
	mv /tmp/ytt /usr/local/bin/ytt
	chmod +x /usr/local/bin/ytt
	echo "Installed ytt"

	echo "Installing kbld..."
	wget -O- https://github.com/k14s/kbld/releases/download/v0.8.0/kbld-linux-amd64 > /tmp/kbld
	echo "4a94e7ed7627b2fde0d21e4a4ba3043f8a490586ab1c3a92f371c45226c1fcad  /tmp/kbld" | shasum -c -
	mv /tmp/kbld /usr/local/bin/kbld
	chmod +x /usr/local/bin/kbld
	echo "Installed kbld"

	echo "Installing kapp..."
	wget -O- https://github.com/k14s/kapp/releases/download/v0.9.0/kapp-linux-amd64 > /tmp/kapp
	echo "1f54e6146af55112332898108d7870375fc2a38a540bfbc420c70ecbbb0d8461  /tmp/kapp" | shasum -c -
	mv /tmp/kapp /usr/local/bin/kapp
	chmod +x /usr/local/bin/kapp
	echo "Installed kapp"

	echo "Installing kwt..."
	wget -O- https://github.com/k14s/kwt/releases/download/v0.0.5/kwt-linux-amd64 > /tmp/kwt
	echo "706abe487e38c4f673180600d11098e408e6bc22fefb1cc512e3ac0f07a9072c  /tmp/kwt" | shasum -c -
	mv /tmp/kwt /usr/local/bin/kwt
	chmod +x /usr/local/bin/kwt
	echo "Installed kwt"
}

install
