# Ghouls - The Next Generation

There is nothing interesting here... yet!

Play the original in your browser: http://bbcmicro.co.uk/game.php?id=2506

# Build

## Prerequisites

### Windows

Not supported... yet!

### POSIX-type

- GNU Make
- Python 3.x
- [basictool](https://github.com/ZornsLemma/basictool)
- [64tass](https://sourceforge.net/projects/tass64/)

All are assumed to be on PATH under their default names, but this can
be overridden. Consult the Makefile.

## Clone the repo

This repo has submodules. Clone it with `--recursive`:

    git clone https://github.com/tom-seddon/ghouls-tng
	
Alternatively, if you already cloned it non-recursively, you can do
the following from inside the working copy:

    git submodule init
	git submodule update

# Build

Run GNU Make from the working copy.

The output is a .ssd file, `ghouls-tng.ssd`, suitable for use with an
emulator.

The output files can also be found in `beeb/ghouls-tng/y/`. If you use
[BeebLink](https://github.com/tom-seddon/beeblink/), configure it so
it can find this folder - the output will be available in drive Y of
the ghouls-tng volume.
