# Ghouls - The Next Generation

There is nothing interesting here, so far.

Play the original in your browser: http://bbcmicro.co.uk/game.php?id=2506

# Build

## Prerequisites

### Windows

- Python 3.x

Additional dependencies are provided as EXEs in the repo.

### POSIX-type

- GNU Make (`make`)
- Python 3.x (`/usr/bin/python3`)
- [64tass](https://sourceforge.net/projects/tass64/) (`64tass`)
- Working C compiler
  ([basictool](https://github.com/ZornsLemma/basictool) is compiled
  automatically as part of the build)

## Clone the repo

This repo has submodules. Clone it with `--recursive`:

    git clone --recursive https://github.com/tom-seddon/ghouls-tng
	
Alternatively, if you already cloned it non-recursively, you can do
the following from inside the working copy:

    git submodule init
	git submodule update

# Build

Run `make` in the working copy. (A `make.bat` is supplied for Windows,
which will run the supplied copy of GNU Make.)

The output is a .ssd file, `ghouls-tng.ssd`, suitable for use with an
emulator.

The output files can also be found in `beeb/ghouls-tng/y/`. If you use
[BeebLink](https://github.com/tom-seddon/beeblink/), configure it so
it can find this folder - the output will be available in drive Y of
the ghouls-tng volume.
