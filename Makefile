##########################################################################
##########################################################################

ifeq ($(OS),Windows_NT)
PYTHON:=py -3
$(error TODO - will put the binaries in the repo)
else
PYTHON:=/usr/bin/python3
TASS:=64tass
BASICTOOL:=basictool
endif

##########################################################################
##########################################################################

_V:=$(if $(VERBOSE),,@)
TASS_ARGS:=--case-sensitive -Wall --cbm-prg

##########################################################################
##########################################################################

# How to run shellcmd.py from any folder.
SHELLCMD:=$(PYTHON) $(shell $(PYTHON) submodules/shellcmd.py/shellcmd.py realpath submodules/shellcmd.py/shellcmd.py)

# submodules/beeb/bin (absolute path).
BEEB_BIN:=$(shell $(SHELLCMD) realpath submodules/beeb/bin)

# How to run ssd_extract.py from any folder.
SSD_EXTRACT:=$(PYTHON) $(BEEB_BIN)/ssd_extract.py

# How to run ssd_create.py from any folder.
SSD_CREATE:=$(PYTHON) $(BEEB_BIN)/ssd_create.py

# Where intermediate build output goes (absolute path).
BUILD:=$(shell $(SHELLCMD) realpath build)

# Where the BeebLink volume is (absolute path).
BEEB_VOLUME:=$(shell $(SHELLCMD) realpath beeb/ghouls-tng/)

# Where final Beeb-visible build output goes (absolute path).
BEEB_OUTPUT:=$(BEEB_VOLUME)/y

# Name of final .ssd to produce
SSD_OUTPUT:=ghouls-tng.ssd

##########################################################################
##########################################################################

.PHONY:build
build: _output_folders

# Create GBAS
	$(_V)$(BASICTOOL) --tokenise --basic-2 src/ghouls.bas $(BEEB_OUTPUT)/$$.GBAS

# Convert !BOOT
	$(_V)$(SHELLCMD) copy-file src/boot.txt $(BEEB_OUTPUT)/$$.!BOOT
	$(_V)$(PYTHON) $(BEEB_BIN)/text2bbc.py $(BEEB_OUTPUT)/$$.!BOOT

# Copy GMC
	$(_V)$(SHELLCMD) copy-file $(BEEB_VOLUME)/0/$$.GMC $(BEEB_OUTPUT)/
	$(_V)$(SHELLCMD) copy-file $(BEEB_VOLUME)/0/$$.GMC.inf $(BEEB_OUTPUT)/

# Create GCODE
	$(_V)$(TASS) $(TASS_ARGS) -o $(BUILD)/gcode.prg src/gcode.s65
	$(_V)$(PYTHON) $(BEEB_BIN)/prg2bbc.py $(BUILD)/gcode.prg $(BEEB_OUTPUT)/$$.GCODE

# Set the boot option
	$(_V)echo 3 > $(BEEB_OUTPUT)/.opt4

# Create a .ssd
	$(_V)$(SSD_CREATE) -o $(SSD_OUTPUT) --dir $(BEEB_OUTPUT) $(BEEB_OUTPUT)/*

##########################################################################
##########################################################################

.PHONY:_output_folders
_output_folders:
	$(_V)$(SHELLCMD) mkdir $(BUILD)
	$(_V)$(SHELLCMD) mkdir $(BEEB_OUTPUT)

##########################################################################
##########################################################################

.PHONY:clean
clean:
	$(_V)$(SHELLCMD) rm-tree $(BUILD)
	$(_V)$(SHELLCMD) rm-tree $(BEEB_OUTPUT)
	$(_V)$(SHELLCMD) rm-file $(SSD_OUTPUT)
