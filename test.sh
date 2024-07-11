#!/bin/bash
# vim: ts=4:et

. zig.sh

if [ -n "$DEBUG" ]; then set -x; fi

baz() {
    echo "baz"
    defer "
        echo 'defer 1'
        echo 'bye'
    "
}

foo() {
    echo "foo: 0"
    defer 'echo "foo: 1st defer"'
    errdefer 'echo "foo: 1st errdefer"'
    return "$1"
}

bar() {
    echo "bar: 0"
    defer 'echo "bar: 1st defer"'
    errdefer 'echo "bar: 1st errdefer"'
    echo "bar: 1"
    errdefer 'echo "bar: 2nd errdefer"'
    if foo "$1"; then
        echo "bar: foo returned 0"
    else
        echo "bar: foo returned 1"
        return 1
    fi
    defer 'echo "bar: 2nd defer"'
    return "$1"
}

baz
echo
foo 0
echo
foo 1
echo
bar 0
echo
bar 1
