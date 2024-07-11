#!/bin/bash
# vim: ts=4:et
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
# variable `ZIG_EAX` to the return value of the function, so `errdefer` can
# check the return value of the function. (`$?` does not work in this case.)

ZIG_EAX=0

# Use aliases as C-style macros
shopt -s expand_aliases

if [ -n "$DEBUG" ]; then set -x; fi

_defer() { eval "$*"; }
_errdefer() { if [ "$ZIG_EAX" -ne 0 ]; then eval "$*"; fi }
_extract_trap() {
    local trap_str=$1
    local cb
    cb=${trap_str#"trap -- '"}
    cb=${cb%"' RETURN"}
    echo "$cb"
}

# shellcheck disable=SC2154
alias return='if read -r rc; then
    if [ -z "$(trap -p RETURN)" ]; then
        return $rc;
    else
        ZIG_EAX=$rc;
        return $rc;
    fi
fi <<<'

# shellcheck disable=SC2154
alias defer='if read -r cb; then
    local prev_cb
    prev_cb=$(_extract_trap "$(trap -p RETURN)")
    if [ -z "$prev_cb" ]; then
        trap "_defer $cb; trap - RETURN; ZIG_EAX=0" RETURN
    else
        trap "_defer $cb; $prev_cb" RETURN
    fi
fi <<<'

# shellcheck disable=SC2154
alias errdefer='if read -r cb; then
    local prev_cb
    prev_cb=$(_extract_trap "$(trap -p RETURN)")
    if [ -z "$prev_cb" ]; then
        trap "_errdefer ""$cb""; trap - RETURN; ZIG_EAX=0" RETURN
    else
        trap "_errdefer ""$cb""; $prev_cb" RETURN
    fi
fi <<<'
