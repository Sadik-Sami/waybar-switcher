#!/bin/sh

restore_alsa() {
  while ! pgrep -x pipewire >/dev/null; do
    sleep 1
  done
  alsactl restore
}

restore_alsa &
