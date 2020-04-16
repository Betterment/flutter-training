#!/usr/bin/env bash

cd "$(dirname "$0")/.." || exit

source script/helpers.sh

cleanup_log() {
  rm -f "$LOGFILE"
}

FLUTTER_HOME="$HOME/flutter"
FLUTTER_CHANNEL=beta
FLUTTER_VERSION=1.14.6

install_flutter() {
  append_to_rcfile 'export FLUTTER_HOME="$HOME/flutter"'
  append_to_rcfile 'export PATH="$FLUTTER_HOME/bin:$PATH"'
  export PATH="$FLUTTER_HOME/bin:$PATH"

  pushd "$FLUTTER_HOME"
    if [ ! -d "$FLUTTER_HOME" ]; then
      git clone --branch "$FLUTTER_CHANNEL" https://github.com/flutter/flutter.git "$FLUTTER_HOME"
      git checkout "v$FLUTTER_VERSION"
    else
      git pull
      git checkout "v$FLUTTER_VERSION"
    fi
  popd

  flutter doctor
  flutter precache
  flutter config --enable-macos-desktop
}

append_to_rcfile() {
  local text="$1" rcfile

  if [[ "$SHELL" =~ 'zsh' ]]; then
    rcfile="$HOME/.zshrc"
  else
    rcfile="$HOME/.bashrc"
  fi

  if ! grep -Fqs "$text" "$rcfile"; then
    printf "\n%s\n" "$text" >> "$rcfile"
  fi
}

task_inform "Bootstrapping Dependencies..."

cleanup_log

subtask_exec "Installing Flutter" install_flutter
