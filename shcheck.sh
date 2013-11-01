#!/bin/sh

# sh-check 0.1
# https://github.com/fmunch/sh-check
#
# Environment:
#  - SHCHECK_NB_CHECKS: total number of checks
#  - SHCHECK_LOG_END_HPA: columns at the left of the result tags
#  - SHCHECK_FANCYTTY: if set to "true" / "false", forces colored / raw output


: ${SHCHECK_NB_CHECKS:=}
SHCHECK_CURRENT_CHECK=1

: ${SHCHECK_LOG_END_HPA:=70}


if which tput > /dev/null 2>&1; then
  SHCHECK_TPUT=$(which tput)
elif [ -x /usr/bin/tput ]; then
  SHCHECK_TPUT=/usr/bin/tput
else
  SHCHECK_TPUT=
fi

if [ -z "$SHCHECK_FANCYTTY" -a -x "$SHCHECK_TPUT" -a -n "$TERM" ] \
    && "$SHCHECK_TPUT" hpa "$SHCHECK_LOG_END_HPA" > /dev/null 2>&1; then
  SHCHECK_FANCYTTY=true
fi
case "$SHCHECK_FANCYTTY" in
  1|Y|true|yes) SHCHECK_FANCYTTY=true;;
  *) SHCHECK_FANCYTTY=false;;
esac

if [ "$SHCHECK_FANCYTTY" = 'true' ]; then
  SHCHECK_COLOR_RED=$($SHCHECK_TPUT setaf 1)
  SHCHECK_COLOR_GREEN=$($SHCHECK_TPUT setaf 2)
  SHCHECK_COLOR_YELLOW=$($SHCHECK_TPUT setaf 3)
  SHCHECK_COLOR_NORMAL=$($SHCHECK_TPUT op)
else
  SHCHECK_COLOR_RED=
  SHCHECK_COLOR_GREEN=
  SHCHECK_COLOR_YELLOW=
  SHCHECK_COLOR_NORMAL=
fi


shcheck() {
  SHCHECK_CHECK_COMMENT="$1"
  SHCHECK_CHECK_COMMAND="$2"
  shift 2

  shcheck_log_begin "$SHCHECK_CHECK_COMMENT"
  "$SHCHECK_CHECK_COMMAND" "$@"

  shcheck_log_end $?
  SHCHECK_CURRENT_CHECK=$(($SHCHECK_CURRENT_CHECK + 1))
}

shcheck_log_begin() {
  if [ -n "$SHCHECK_NB_CHECKS" ]; then
    printf "[%${#SHCHECK_NB_CHECKS}s/%s] %s... " "$SHCHECK_CURRENT_CHECK" "$SHCHECK_NB_CHECKS" "$1"
  else
    printf "[%s] %s... " "$SHCHECK_CURRENT_CHECK" "$1"
  fi
}

shcheck_log_end() {
  [ "$SHCHECK_FANCYTTY" = 'true' ] && $SHCHECK_TPUT hpa "$SHCHECK_LOG_END_HPA"
  if [ "$1" = 0 ]; then
    echo "[${SHCHECK_COLOR_GREEN} OK ${SHCHECK_COLOR_NORMAL}]"
  elif [ "$1" = 255 ]; then
    echo "[${SHCHECK_COLOR_YELLOW}WARN${SHCHECK_COLOR_NORMAL}]"
  else
    echo "[${SHCHECK_COLOR_RED}FAIL${SHCHECK_COLOR_NORMAL}]"
  fi
}
