# ZIG.BASH

This is a bash library that provides the Zig-like `defer` and `errdefer`
functionalities. Please feel free to copy and paste this code into your
bash scripts to flex on your coworkers.

## Example

Simple example:

```bash
foo() {
    echo "foo: 0"
    defer 'echo "foo: 1st defer"'
    errdefer 'echo "foo: 1st errdefer"'
    return "$1"
}
foo 0
echo 
foo 1
```

Output:

```
foo: 0
foo: 1st defer

foo: 0
foo: 1st errdefer
foo: 1st defer
```

Nested example:

```bash
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
bar 0
echo
bar 1
```

Output:

```
bar: 0
bar: 1
foo: 0
foo: 1st defer
bar: foo returned 0
bar: 2nd defer
bar: 1st defer

bar: 0
bar: 1
foo: 0
foo: 1st errdefer
foo: 1st defer
bar: foo returned 1
bar: 2nd errdefer
bar: 1st errdefer
bar: 1st defer
```
