##########################################################################
##########################################################################

ifeq ($(OS),Windows_NT)
PYTHON:=py -3
else
PYTHON:=/usr/bin/python3
TASS:=64tass
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

# bin (absolute path)
BIN:=$(shell $(SHELLCMD) realpath bin)

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

ifeq ($(OS),Windows_NT)
TASS:=$(shell $(SHELLCMD) realpath bin/64tass.exe)
BASICTOOL:=$(shell $(SHELLCMD) realpath bin/basictool.exe)
else
BASICTOOL:=$(shell $(SHELLCMD) realpath submodules/basictool/basictool)
endif

##########################################################################
##########################################################################

.PHONY:build
build: _output_folders

ifneq ($(OS),Windows_NT)
	$(_V)cd submodules/basictool/src && make all
endif

# Convert !BOOT
	$(_V)$(SHELLCMD) copy-file src/boot.txt $(BEEB_OUTPUT)/$$.!BOOT
	$(_V)$(PYTHON) $(BEEB_BIN)/text2bbc.py $(BEEB_OUTPUT)/$$.!BOOT

# Create GMC
	$(_V)$(TASS) $(TASS_ARGS) -L $(BUILD)/gmc.lst -l $(BUILD)/gmc.symbols -o $(BUILD)/gmc.prg src/gmc.s65
	$(_V)$(PYTHON) $(BEEB_BIN)/prg2bbc.py $(BUILD)/gmc.prg $(BEEB_OUTPUT)/$$.GMC

# Create GCODE
	$(_V)$(TASS) $(TASS_ARGS) -L $(BUILD)/gcode.lst -l $(BUILD)/gcode.symbols -o $(BUILD)/gcode.prg src/gcode.s65
	$(_V)$(PYTHON) $(BEEB_BIN)/prg2bbc.py $(BUILD)/gcode.prg $(BEEB_OUTPUT)/$$.GCODE

# Create GBAS
	$(_V)$(PYTHON) $(BIN)/bbpp.py  --asm-symbols $(BUILD)/gmc.symbols "" --asm-symbols $(BUILD)/gcode.symbols gcode. -o $(BUILD)/ghouls.bas src/ghouls.bas
	$(_V)$(BASICTOOL) --tokenise --basic-2 --output-binary $(BUILD)/ghouls.bas $(BEEB_OUTPUT)/$$.GBAS

# Set the boot option
	$(_V)echo 3 > $(BEEB_OUTPUT)/.opt4

# Create a .ssd
#
# TODO: don't include everything!
	$(_V)$(SSD_CREATE) -o $(SSD_OUTPUT) --dir $(BEEB_OUTPUT) $(BEEB_OUTPUT)/*

# Some stuff while I'm trying to ensure the output matches.
	@$(SHELLCMD) blank-line
	@$(SHELLCMD) sha1 beeb/ghouls-tng/0/$$.GCODE
	@$(SHELLCMD) sha1 beeb/ghouls-tng/y/$$.GCODE
	@$(SHELLCMD) sha1 beeb/ghouls-tng/0/$$.GMC
	@$(SHELLCMD) sha1 beeb/ghouls-tng/y/$$.GMC
	@$(SHELLCMD) sha1 beeb/ghouls-tng/0/$$.GBAS
	@$(SHELLCMD) sha1 beeb/ghouls-tng/y/$$.GBAS

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

##########################################################################
##########################################################################

.PHONY:_tom_laptop
_tom_laptop: CONFIG=Master 128 (MOS 3.20)
_tom_laptop:
	$(MAKE) build
	-curl --connect-timeout 0.25 --silent -G 'http://localhost:48075/reset/b2' --data-urlencode "config=$(CONFIG)"
	-curl --connect-timeout 0.25 --silent -H 'Content-Type:application/binary' --upload-file 'ghouls-tng.ssd' 'http://localhost:48075/run/b2?name=ghouls-tng.ssd'
