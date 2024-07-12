#!/bin/bash
# vim: ts=2:et
#
# This is a bash library that provides the Zig-like `defer` and `errdefer`
# functionalities. Please feel free to copy and paste this code into your
# bash scripts to flex on your coworkers.
#
# This file uses the bash `alias` as a C-style macro to define the `defer` and
# `errdefer`, which requires the `shopt -s expand_aliases` to be set when you
# are running in non-interactive mode.
#
# The `return` overrides the default `return` keyword, which will set the env
# variable `DEFER_RC` to the return value of the function, so `errdefer` can
# check the return value of the function. (`$?` does not work in this case.)

DEFER_RC=0

# Use aliases as C-style macros
shopt -s expand_aliases

if [ -n "$DEBUG" ]; then set -x; fi

_defer() {
    eval "$*"
}

_errdefer() {
    if [ "${DEFER_RC:-0}" -ne 0 ]; then 
        eval "$*"
    fi
}

_xtrap() {
  local trap_str=$1
  local cb
  cb=${trap_str#"trap -- '"}
  cb=${cb%"' RETURN"}
  echo "$cb"
}

_ctrap() {
  local cb prev_cb kind
  prev_cb="$1"
  kind="$2"
  while read -r _cb; do
    if [ -z "$_cb" ]; then continue; fi
    if [ -z "$cb" ]; then
      cb="$_cb"
    else
      cb="$cb; $_cb"
    fi
  done
  if [ -z "$prev_cb" ]; then
    echo "$kind $cb; trap - RETURN; DEFER_RC=0"
  else
    echo "$kind $cb; $prev_cb"
  fi
}

# shellcheck disable=SC2154
alias return='if read -r rc; then
  if [ -n "$(trap -p RETURN)" ]; then DEFER_RC=$rc; fi
  return $rc
fi <<<'

# shellcheck disable=SC2154
alias defer='if true; then
  trap "$(_ctrap "$(_xtrap "$(trap -p RETURN)")" _defer)" RETURN
fi <<<'

# shellcheck disable=SC2154
alias errdefer='if true; then
  trap "$(_ctrap "$(_xtrap "$(trap -p RETURN)")" _errdefer)" RETURN
fi <<<'
