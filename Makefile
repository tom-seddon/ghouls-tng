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

SHELLCMD:=$(PYTHON) $(shell $(PYTHON) submodules/shellcmd.py/shellcmd.py realpath submodules/shellcmd.py/shellcmd.py)
BEEB_BIN:=$(shell $(SHELLCMD) realpath submodules/beeb/bin)
SSD_EXTRACT:=$(PYTHON) $(BEEB_BIN)/ssd_extract.py
SSD_CREATE:=$(PYTHON) $(BEEB_BIN)/ssd_create.py

# Where 
BUILD:=$(shell $(SHELLCMD) realpath build)

BEEB_VOLUME:=$(shell $(SHELLCMD) realpath beeb/ghouls-tng/)

# Where Beeb-visible build artefacts go.
BEEB_BUILD:=$(BEEB_VOLUME)/y

##########################################################################
##########################################################################

.PHONY:build
build: _output_folders

# Get BeebAsm to do some file conversion
	cd src && $(BEEBASM) -i ghouls_files.asm -do $(BUILD)/ghouls_files.ssd
	$(SSD_EXTRACT) $(BUILD)/ghouls_files.ssd -0 -o $(BUILD)
	$(SHELLCMD) copy-file $(BUILD)/$$.GBAS $(BEEB_BUILD)/
	$(SHELLCMD) copy-file $(BUILD)/$$.!BOOT $(BEEB_BUILD)/

# Copy GMC
	$(SHELLCMD) copy-file $(BEEB_VOLUME)/0/$$.GMC $(BEEB_BUILD)/
	$(SHELLCMD) copy-file $(BEEB_VOLUME)/0/$$.GMC.inf $(BEEB_BUILD)/

# Copy GCODE
	$(SHELLCMD) copy-file $(BEEB_VOLUME)/0/$$.GCODE $(BEEB_BUILD)/
	$(SHELLCMD) copy-file $(BEEB_VOLUME)/0/$$.GCODE.inf $(BEEB_BUILD)/

# Set the boot option
	echo 3 > $(BEEB_BUILD)/.opt4

# Create a .ssd
	$(SSD_CREATE) -o ghouls-tng.ssd --dir $(BEEB_BUILD) $(BEEB_BUILD)/*

##########################################################################
##########################################################################

.PHONY:_output_folders
_output_folders:
	$(SHELLCMD) mkdir $(BUILD)
	$(SHELLCMD) mkdir $(BEEB_BUILD)

##########################################################################
##########################################################################

.PHONY:clean
clean:
	$(SHELLCMD) rm-tree $(BUILD)
	$(SHELLCMD) rm-tree $(BEEB_BUILD)

