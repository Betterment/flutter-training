#!/usr/bin/env bash

cd "$(dirname "$0")/.." || exit

# - Helpers

PROMPT="===>"
CLEARCOLOR=""
RED=""
YELLOW=""
GREEN=""
LOGFILE="$PWD/setup.log"

fail() {
  echo -e "${RED} $1${CLEARCOLOR}"
  exit -1
}

task_inform() {
  echo -e "${GREEN}${PROMPT} $1${CLEARCOLOR}"
}

clear_previous_line() {
  tput cuu 1 && tput el
}

# Don't complain about echo -e not expanding escape sequences since macOS's
# implementation of echo -e does
# shellcheck disable=2028
subtask_inform() {
  echo -e "\t ${YELLOW}$1${CLEARCOLOR}"
}

# shellcheck disable=2028
subtask_success() {
  clear_previous_line
  echo -e "\t✅ ${GREEN}$1${CLEARCOLOR}"
}

# shellcheck disable=2028
subtask_fail(){
  clear_previous_line
  echo -e "\t❌ ${RED}$1${CLEARCOLOR}"
}

subtask_exec() {
  echo -e "Starting subtask with log string: $1" >> "$LOGFILE" 2>&1
  subtask_inform "$1"
  ${*:2} >> "$LOGFILE" 2>&1

  if [ "$?" -eq 0 ]; then
    subtask_success "$1"
  else
    subtask_fail "$1"
    fail "Command ${*:2} failed. Check $LOGFILE for more info"
  fi
}

# - Setup

cleanup_log() {
  rm -f "$LOGFILE"
}

FLUTTER_HOME="$HOME/flutter"
FLUTTER_CHANNEL=beta
FLUTTER_VERSION=1.17.0

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
