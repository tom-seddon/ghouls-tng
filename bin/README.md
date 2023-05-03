# bbpp

BBC BASIC preprocessor, deliberately dumb. Reads BBC BASIC code from a
text file, a sequence of unnumbered lines, and outputs BBC BASIC code
with line numbers, suitable for use with basictool or similar.

You can control the preprocessing using the following markup, all
oriented around the `{` symbol.

Markup available so far: (there is more to come)

## `{{` - literal

Replaced with a `{` in the output.

## `{#` - comment

The `{#`, and everything following it on the line, is discarded.

## `{$NAME}` - expand value

The `{$...}` is replaced with the value with name `NAME`.

## `{:NAME}` - define line label

Must be the first thing on a line.

Defines the value with name `NAME` as the decimal number of the next
BASIC line produced.

----

The only example use of bbpp is ghouls.bas in this very project.
