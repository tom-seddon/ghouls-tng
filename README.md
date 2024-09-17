# Ghouls - The Next Generation

Play the original in your browser: http://bbcmicro.co.uk/game.php?id=2506

----

# Run

Grab latest-dated .ssd file from the wip_builds folder. (Click on the
.ssd, then use the download link. Don't right click. GitHub is
annoying like that.)

Shift+Break to boot.

## Adventurer

Select 1 to play the game. Enter name of levels file created using
editor (see below), or leave blank for the default.

## Architect

Select 2 to create levels.

From the editor menu, press `1`/`2`/`3`/`4` to edit that level.

Press `N` to set a level's name. Select level number then type in its
new name. There's a limit of 16 chars.

Press `R` to reset a level's data. The level will be emptied, leaving
just a row of blocks along the bottom.

Press `L` to load levels. Enter file name.

Press `S` to save levels. Enter file name.

Press `I` to import a level from another level set. Enter file name,
then level from that set to import, then level in the current set to
replace. Press ESCAPE at any point to get back to the main menu.

Press `*` to get a prompt for entering OS commands. Change drive and
dir and so on. Press ESCAPE to get back to the editor menu.

When editing:

- `Z`/`X`/`*`/`?` move the cursor. CUR shows the item under the
  cursor, and its creation value (see below)
- `DELETE` deletes the thing under the cursor
- `←`/`→` select the NEW thing's type
- `↑`/`↓` select the NEW thing's creation value (see below)
- `RETURN` adds an instance of the NEW thing to the level
- `C` changes the level-specific colour
- `R` redraws the level (since the editor isn't particularly careful
  about tidily redrawing everything while editing)
- `SHIFT+S` sets the player's start position
- `G` sets one corner of the ghost start position area (the position
  is automatically clamped if necessary)
- `SHIFT+G` sets the other corner of the ghost start position area
- `CTRL+G` unsets the ghost start position area
- `S` sets the player's test start position
- `TAB` lets you test the level. If the test start position is set,
  the player starts there. Testing ends with `ESCAPE` or when you die
  or complete the level
- `SHIFT+TAB` tests the level, always using the level start position
- `ESCAPE` takes you back to the main menu

The test start position is shown in red. It isn't saved. It's there to
make it quicker to iterate on sections of the level.

The ghost start area, if set, is indicated by a dotted red rectangle.
Ghosts will start from some position in this area. (If not set, the
ghost will start at some random point in the level.) When testing in
the editor, you will only ever get 1 ghost.

The creation value is a number associated with some types of object:

- For moving platforms: the platform's speed
- For spiders: the spider's speed

There are two types of spider: a solid one (always present), and a
masked/dimmed one (appears only when playing with 2+ ghosts).

----

# Build

## Prerequisites

### Windows

- Python 3.x

Additional dependencies are provided as EXEs in the repo.

### POSIX-type

- GNU Make (`make`)
- Python 3.x (`/usr/bin/python3`)
- [64tass](https://sourceforge.net/projects/tass64/) (`64tass`) -
  version 2974 works
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

## Build

Run `make` in the working copy. (A `make.bat` is supplied for Windows,
which will run the supplied copy of GNU Make.)

The output is a .ssd file, `ghouls-tng.ssd`, suitable for use with an
emulator.

The output files can also be found in `beeb/ghouls-tng/y/`. If you use
[BeebLink](https://github.com/tom-seddon/beeblink/), configure it so
it can find this folder - the output will be available in drive Y of
the ghouls-tng volume.

----

# Branches

## `main`

Branch used for active development.

## `unmodified`

Latest version that promises to build to something bit identical to
the starting point: a minified version of Ghouls, loaders stripped
out, unmodified machine code parts, BASIC unmodified other than
replacing embedded control codes with appropriate CHR$.
