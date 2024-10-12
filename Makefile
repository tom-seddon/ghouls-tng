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
TASS_ARGS:=--case-sensitive -Wall --cbm-prg $(if $(VERBOSE),,--quiet) --long-branch

##########################################################################
##########################################################################

PWD:=$(shell $(PYTHON) submodules/shellcmd.py/shellcmd.py realpath .)

# How to run shellcmd.py from any folder.
SHELLCMD:=$(PYTHON) $(PWD)/submodules/shellcmd.py/shellcmd.py

# submodules/beeb/bin (absolute path).
BEEB_BIN:=$(PWD)/submodules/beeb/bin

# bin (absolute path)
BIN:=$(PWD)/bin

# How to run ssd_create.py from any folder.
SSD_CREATE:=$(PYTHON) $(BEEB_BIN)/ssd_create.py

# Where intermediate build output goes (absolute path).
BUILD:=$(PWD)/build

# Where the BeebLink volume is (absolute path).
BEEB_VOLUME:=$(PWD)/beeb/ghouls-tng

# Where final Beeb-visible build output goes (absolute path).
BEEB_OUTPUT:=$(BEEB_VOLUME)/y
BEEB_OUTPUT_2:=$(BEEB_VOLUME)/z

# Name of final .ssd to produce
SSD_OUTPUT:=ghouls-tng.ssd

ifeq ($(OS),Windows_NT)
TASS:=$(PWD)/bin/64tass.exe
BASICTOOL:=$(PWD)/bin/basictool.exe
ZX02:=$(PWD)/bin/zx02.exe
else
BASICTOOL:=$(PWD)/submodules/basictool/basictool
ZX02:=$(PWD)/submodules/zx02/build/zx02
endif

##########################################################################
##########################################################################

.PHONY:build
build: _output_folders

ifneq ($(OS),Windows_NT)
	$(_V)cd submodules/basictool/src && make all
	$(_V)cd submodules/zx02 && make all
endif

# Convert title screen
	$(_V)$(MAKE) _title_screen

# Convert !BOOT
	$(_V)$(SHELLCMD) copy-file "src/boot.txt" "$(BUILD)/$$.!BOOT"
	$(_V)$(PYTHON) "$(BEEB_BIN)/text2bbc.py" "$(BUILD)/$$.!BOOT"

# Create levels stuff
	$(_V)$(MAKE) _asm PC=glevels BEEB=GLEVELS
	$(_V)$(PYTHON) "$(BIN)/levels.py" --output "$(BUILD)/levels.generated.s65" --output-list "$(BUILD)/levels.txt"

# Create GMC
	$(_V)$(MAKE) _asm PC=gmc BEEB=GMC TASS_EXTRA_ARGS=-Deditor=false
	$(_V)$(MAKE) _asm PC=gmc BEEB=GEDMC TASS_EXTRA_ARGS=-Deditor=true
	$(_V)$(MAKE) _asm PC=gudgs BEEB=GUDGS
	$(_V)$(MAKE) _asm PC=gmenu BEEB=GMENU

# Create GBAS and D.GBAS
	$(_V)$(PYTHON) "$(BIN)/bbpp.py" -Ddebug=False --asm-symbols "$(BUILD)/GMC.symbols" "" -o "$(BUILD)/gbas.bas" "src/ghouls.bas"
	$(_V)$(BASICTOOL) --tokenise --basic-2 --output-binary "$(BUILD)/gbas.bas" "$(BUILD)/$$.GBAS"
	$(_V)$(PYTHON) $(BIN)/bbpp.py -Ddebug=True --asm-symbols "$(BUILD)/GMC.symbols" "" -o "$(BUILD)/d.gbas.bas" "src/ghouls.bas"
	$(_V)$(BASICTOOL) --tokenise --basic-2 --output-binary "$(BUILD)/d.gbas.bas" "$(BUILD)/D.GBAS"

# Create GLOADER
	$(_V)$(PYTHON) $(BIN)/bbpp.py --asm-symbols "$(BUILD)/GMC.symbols" "" -o "$(BUILD)/gloader.bas" "src/gloader.bas"
	$(_V)$(BASICTOOL) --tokenise --basic-2 --output-binary "$(BUILD)/gloader.bas" "$(BUILD)/$$.GLOADER"

# Create GCSREEN
#	$(_V)$(SHELLCMD) copy-file $(BEEB_VOLUME)/0/$$.GSCREEN $(BEEB_OUTPUT)/

# Set the boot option
#	$(_V)echo 3 > $(BEEB_OUTPUT)/.opt4

# Print some info
	$(_V)$(SHELLCMD) blank-line
	$(_V)$(PYTHON) "$(BIN)/budgets.py" "$(BUILD)" "$(BUILD)"
	$(_V)$(SHELLCMD) blank-line

# Build .ssd. Re-run make to ensure the $(shell cat gets re-evaluated.
	$(_V)$(MAKE) _ssd

# Extract side 0 of .ssd to create individual drive in BeebLink
# volume.
	$(_V)$(PYTHON) "$(BEEB_BIN)/ssd_extract.py" -o "$(BEEB_OUTPUT)" -0 "$(SSD_OUTPUT)"
	$(_V)$(SHELLCMD) copy-file "$(SSD_OUTPUT)" "$(BEEB_OUTPUT_2)/S.GHOULS"

##########################################################################
##########################################################################

.PHONY:_ssd
# It's possible levels.txt won't exist, meaning _LEVELS ends up empty.
# But by the time make _ssd is actually executed, as part of make
# build, it will be present.
_ssd: _LEVELS:=$(shell $(SHELLCMD) cat -f $(BUILD)/levels.txt)
_ssd:
	$(_V)$(SSD_CREATE) -o "$(SSD_OUTPUT)" --title "GHOULS R" --opt4 3 "$(BUILD)/$$.!BOOT" "$(BUILD)/$$.GLOADER" "$(BEEB_VOLUME)/0/$$.GSCREEN" "$(BUILD)/$$.GUDGS" "$(BUILD)/$$.GMC" "$(BUILD)/$$.GBAS" "$(BUILD)/D.GBAS" "$(BUILD)/$$.GEDMC" "$(BUILD)/$$.GINFO" "$(BUILD)/$$.GMENU" $(_LEVELS)

##########################################################################
##########################################################################

.PHONY:_title_screen
_title_screen: $(BUILD)/title.zx02

$(BUILD)/title.zx02 : $(BUILD)/title.bbc
	$(_V)$(ZX02) "$<" "$@"

$(BUILD)/title.bbc : $(PWD)/src/GhoulsRevenge.png
	$(_V)$(PYTHON) "$(BEEB_BIN)/png2bbc.py" -o "$@" "$<" 2

##########################################################################
##########################################################################

.PHONY:_asm
_asm:
	$(_V)$(TASS) $(TASS_ARGS) $(TASS_EXTRA_ARGS) -L "$(BUILD)/$(BEEB).lst" -l "$(BUILD)/$(BEEB).symbols" -o "$(BUILD)/$(BEEB).prg" "src/$(PC).s65"
	$(_V)$(PYTHON) "$(BEEB_BIN)/prg2bbc.py" --io "$(BUILD)/$(BEEB).prg" "$(BUILD)/$$.$(BEEB)"

##########################################################################
##########################################################################

.PHONY:_output_folders
_output_folders:
	$(_V)$(SHELLCMD) mkdir "$(BUILD)"
	$(_V)$(SHELLCMD) mkdir "$(BEEB_OUTPUT)"
	$(_V)$(SHELLCMD) mkdir "$(BEEB_OUTPUT_2)"

##########################################################################
##########################################################################

.PHONY:clean
clean:
	$(_V)$(SHELLCMD) rm-tree "$(BUILD)"
	$(_V)$(SHELLCMD) rm-tree "$(BEEB_OUTPUT)"
	$(_V)$(SHELLCMD) rm-tree "$(BEEB_OUTPUT_2)"
	$(_V)$(SHELLCMD) rm-file -f "$(SSD_OUTPUT)"

##########################################################################
##########################################################################

.PHONY:ci_build
ci_build: OUTPUT_SSD=$(error Must specify OUTPUT_SSD)
ci_build:
	$(_V)$(MAKE) build
	$(_V)$(SHELLCMD) copy-file "$(SSD_OUTPUT)" "$(OUTPUT_SSD)"
	$(_V)echo "$(OUTPUT_SSD)"

##########################################################################
##########################################################################

.PHONY:_tom_laptop
# _tom_laptop: CONFIG=Master 128 (MOS 3.20)
_tom_laptop: CONFIG=B/Acorn 1770
_tom_laptop:
	$(MAKE) build
	-curl --connect-timeout 0.25 --silent -G 'http://localhost:48075/reset/b2' --data-urlencode "config=$(CONFIG)"
	-curl --connect-timeout 0.25 --silent -H 'Content-Type:application/binary' --upload-file 'ghouls-tng.ssd' 'http://localhost:48075/run/b2?name=ghouls-tng.ssd'

.PHONY:_tom_windows_laptop
_tom_windows_laptop: CONFIG=B/Acorn 1770 + BeebLink
_tom_windows_laptop:
#	@$(MAKE) _tom_laptop

	@$(MAKE) build
	-curl --connect-timeout 0.25 --silent -G 'http://localhost:48075/reset/b2' --data-urlencode "config=$(CONFIG)"

##########################################################################
##########################################################################

# Phony target for manual invocation. It doesn't run on every build,
# because it needs the VC++ command line tools on the path, something
# I don't want to require.

.PHONY:zx02_windows
zx02_windows: SRC:=$(PWD)/submodules/zx02/src
zx02_windows: _output_folders
	cd "$(BUILD)" && cl /W4 /Zi /O2 /Fe$(PWD)/bin/zx02.exe "$(SRC)/compress.c" "$(SRC)/memory.c" "$(SRC)/optimize.c" "$(SRC)/zx02.c"
