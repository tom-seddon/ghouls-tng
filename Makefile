##########################################################################
##########################################################################

ifeq ($(OS),Windows_NT)
PYTHON:=py -3
$(error TODO)
else
PYTHON:=/usr/bin/python3
BEEBASM:=beebasm
TASS:=64tass
endif

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

# Get BeebAsm to do some file conversion
	cd src && $(BEEBASM) -i ghouls_files.asm -do $(BUILD)/ghouls_files.ssd
	$(SSD_EXTRACT) $(BUILD)/ghouls_files.ssd -0 -o $(BUILD)
	$(SHELLCMD) copy-file $(BUILD)/$$.GBAS $(BEEB_OUTPUT)/
	$(SHELLCMD) copy-file $(BUILD)/$$.!BOOT $(BEEB_OUTPUT)/

# Copy GMC
	$(SHELLCMD) copy-file $(BEEB_VOLUME)/0/$$.GMC $(BEEB_OUTPUT)/
	$(SHELLCMD) copy-file $(BEEB_VOLUME)/0/$$.GMC.inf $(BEEB_OUTPUT)/

# Copy GCODE
	$(SHELLCMD) copy-file $(BEEB_VOLUME)/0/$$.GCODE $(BEEB_OUTPUT)/
	$(SHELLCMD) copy-file $(BEEB_VOLUME)/0/$$.GCODE.inf $(BEEB_OUTPUT)/

# Set the boot option
	echo 3 > $(BEEB_OUTPUT)/.opt4

# Create a .ssd
	$(SSD_CREATE) -o $(SSD_OUTPUT) --dir $(BEEB_OUTPUT) $(BEEB_OUTPUT)/*

##########################################################################
##########################################################################

.PHONY:_output_folders
_output_folders:
	$(SHELLCMD) mkdir $(BUILD)
	$(SHELLCMD) mkdir $(BEEB_OUTPUT)

##########################################################################
##########################################################################

.PHONY:clean
clean:
	$(SHELLCMD) rm-tree $(BUILD)
	$(SHELLCMD) rm-tree $(BEEB_OUTPUT)
	$(SHELLCMD) rm-file $(SSD_OUTPUT)
