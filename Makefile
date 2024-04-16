include git.mk
include setup.mk

HELP+=help-main

#WASI_BUILD:=$(REPOROOT)/ldc-build-runtime.tmp

.PHONY: help info



all:

native:
	$(MAKE) all NATIVE=1

include llvm.mk 

include wasi_libc.mk

include wasi_sdk.mk
ifdef USE_LDC_BUILD_RUNTIME
include ldc_runtime.mk
else
include wasi_druntime.mk 
#all: libdruntime libphobos
endif

include hello_wasm.mk

help:
	@echo "Usage " 
	@echo
	@echo "make subdate   : If the repo been clone with out --recursive then run the"
	@echo
	@echo "make spull     : All the submodules can be pull by"
	@echo
	@echo "make all       : Build all"
	@echo
	@echo "make native    : Build native"
	@echo
	@echo "make help      : Prints this help text"
	@echo
	@echo "make info      : Prints the Link and Compile setting"
	@echo
	@echo "make proper    : Clean all"
	@echo
	@echo "make clean     : Clean the build"
	@echo

%/.done:
	touch $@

info: 
	@echo $@

prebuild: subdate

all: prebuild

ifndef NATIVE
all: run
endif
.PHONY: run

run:
	@echo "Done"

subdate: $(REPOROOT)/.done
	git submodule update --init --recursive 

spull:
	git pull --recurse-submodules

clean: 
	@echo $@ 

clean-build:
	rm -fR build

ifdef NATIVE
proper: clean clean-build

else

proper: clean clean-build
	@echo $@
	rm -fR build
	rm -f $(REPOROOT)/.done
	$(MAKE) NATIVE=1 proper
	
endif
