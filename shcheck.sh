#!/bin/sh

# sh-check 0.1
# https://github.com/fmunch/sh-check
#
# Environment:
#  - SHCHECK_NB_CHECKS: total number of checks
#  - SHCHECK_LOG_END_HPA: columns at the left of the result tags
#  - SHCHECK_FANCYTTY: if set to "true" / "false", forces colored / raw output


## Prepare environment

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


## Public functions

# Main check function, called to perform one of the checks.
#
# shcheck <checkname> <callback> [args...]
#   checkname: Name of the check to perform.
#   callback: Function to call to perform the check.
#   args: Arguments passed to <callback>.
shcheck() {
  SHCHECK_CHECK_COMMENT="$1"
  SHCHECK_CHECK_COMMAND="$2"
  shift 2

  shcheck_log_begin "$SHCHECK_CHECK_COMMENT"
  "$SHCHECK_CHECK_COMMAND" "$@"

  shcheck_log_end $?
  SHCHECK_CURRENT_CHECK=$(($SHCHECK_CURRENT_CHECK + 1))
}

# Default check callbacks

# Callback checking if a file exists.
#
# shcheck_file_exists <file>
#   file: File to look for.
shcheck_file_exists() {
  [ -f "$1" ] && return 0 || return 1
}

# Callback checking if a file is readable.
#
# shcheck_file_readable <file>
#   file: File to look for.
shcheck_file_readable() {
  [ -r "$1" ] && return 0 || return 1
}

# Callback checking if a file is executable.
#
# shcheck_file_executable <file>
#   file: File to look for.
shcheck_file_executable() {
  [ -x "$1" ] && return 0 || return 1
}

# Callback checking if a command is available in $PATH.
#
# shcheck_command_available <command>
#   command: Command to look for.
shcheck_command_available() {
  which "$1" > /dev/null 2>&1 && return 0 || return 1
}


## Private functions

# Starts a check by printing its name and the current check number.
#
# shcheck_log_begin <checkname>
#   checkname: Name of the check to perform.
shcheck_log_begin() {
  if [ -n "$SHCHECK_NB_CHECKS" ]; then
    printf "[%${#SHCHECK_NB_CHECKS}s/%s] %s... " "$SHCHECK_CURRENT_CHECK" "$SHCHECK_NB_CHECKS" "$1"
  else
    printf "[%3s] %s... " "$SHCHECK_CURRENT_CHECK" "$1"
  fi
}

# Ends a check by printing its state (OK, WARN or FAIL).
#
# shcheck_log_begin <callbackreturn>
#   callbackreturn: Return value of the callback function.
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
