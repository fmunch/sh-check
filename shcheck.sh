#!/bin/sh

# sh-check 0.1
# https://github.com/fmunch/sh-check


: ${NB_CHECKS:=}
CURRENT_CHECK=1

: ${LOG_END_HPA:=70}


if which tput > /dev/null 2>&1; then
  TPUT=$(which tput)
elif [ -x /usr/bin/tput ]; then
  TPUT=/usr/bin/tput
else
  TPUT=
fi

if [ -z "$FANCYTTY" -a -x "$TPUT" -a -n "$TERM" ] \
    && "$TPUT" hpa "$LOG_END_HPA" > /dev/null 2>&1; then
  FANCYTTY=true
fi
case "$FANCYTTY" in
  1|Y|true|yes) FANCYTTY=true;;
  *) FANCYTTY=false;;
esac

if [ "$FANCYTTY" = 'true' ]; then
  COLOR_RED=$(tput setaf 1)
  COLOR_GREEN=$(tput setaf 2)
  COLOR_YELLOW=$(tput setaf 3)
  COLOR_NORMAL=$(tput op)
else
  COLOR_RED=
  COLOR_GREEN=
  COLOR_YELLOW=
  COLOR_NORMAL=
fi


check() {
  CHECK_COMMENT="$1"
  CHECK_COMMAND="$2"
  shift 2

  log_check_begin "$CHECK_COMMENT"
  "$CHECK_COMMAND" "$@"

  log_check_end $?
  CURRENT_CHECK=$(($CURRENT_CHECK + 1))
}

log_check_begin() {
  if [ -n "$NB_CHECKS" ]; then
    printf "[%${#NB_CHECKS}s/%s] %s... " "$CURRENT_CHECK" "$NB_CHECKS" "$1"
  else
    printf "[%s] %s... " "$CURRENT_CHECK" "$1"
  fi
}

log_check_end() {
  [ "$FANCYTTY" = 'true' ] && tput hpa "$LOG_END_HPA"
  if [ "$1" = 0 ]; then
    echo "[${COLOR_GREEN} OK ${COLOR_NORMAL}]"
  elif [ "$1" = 255 ]; then
    echo "[${COLOR_YELLOW}WARN${COLOR_NORMAL}]"
  else
    echo "[${COLOR_RED}FAIL${COLOR_NORMAL}]"
  fi
}
