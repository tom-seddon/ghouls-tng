Folder for any tools run as part of the build.

# bbpp

BBC BASIC preprocessor, deliberately dumb. Reads BBC BASIC code from a
text file, a sequence of unnumbered lines, and outputs BBC BASIC code
with line numbers, suitable for use with basictool or similar.

You can control the preprocessing using the following markup, all
oriented around the `{` symbol.

## Markup available

### `{{` - literal ###

Replaced with a `{` in the output.

### `{#` - comment ###

The `{#` is discarded, along with everything following it on the line,
and any spaces preceding it.

### `{$EXPR}` - expand value as string ###

Replaced with the result of evaluating `EXPR`. If the result is a
number, it will be output in decimal.

`EXPR` is a Python expression.

### `{&EXPR}` - expand value as hex number ###
### `{~EXPR}` - expand value as hex digits ###

Replaced with the result of evaluating `EXPR`, which must be numeric
type. For `{~...}`, the result is BBC BASIC-style hex digits, i.e., in
upper case, like using the BBC BASIC `~` operator. For `{&...}`, the
result is a BBC BASIC-style hex value: `&`, followed by upper-case
alpha digits.

(The symbols are supposed to be vaguely mnemonic, but Don't think too
hard about them.)

`EXPR` is a Python expression.

### `{:NAME}` - define line label ###

Must be the first thing on a line.

Defines the value with name `NAME` as the integer number of the next
BASIC line produced.

## Expression evaluation

Expressions are Python expressions, evaluated with an empty set of
globals, and all builtins removed.

## Read symbols from assembler

bbpp will read a `KEY=VALUE`-type symbols file, as output by 64tass
and (probably) many other assemblers.

Use `--asm-symbols` to do this. Supply two arguments: the name of the
file to read, and the prefix to prepend to the names (if any - use
`""` if no prefix is wanted).

The symbols are integer values.

## Example use

The only example use of bbpp is ghouls.bas in this very project.
