.SUFFIXES:
.SECONDARY:
.ONESHELL:
.SECONDEXPANSIOM:

# This switch print out the missing wasi function in runtime
#LIB_DFLAGS+=-d-version=WASI_MISSING

DRUNTIME_SRC:=$(CURDIR)/ldc/runtime/druntime/src 
PHOBOS_SRC:=$(CURDIR)/ldc/runtime/phobos
WASI_INC:=$(CURDIR)/$(WASI_SDK)/share/wasi-sysroot/include
TARGET_DIR?=$(CURDIR)/ldc-build-runtime.wasi
OBJ_DIR:=$(TARGET_DIR)/objects
LIB_DIR:=$(TARGET_DIR)/lib
OBJC_DIR:=$(OBJ_DIR)/c

LIBDC:=$(LIB_DIR)/libdc.a
LIBPHOBOS2:=$(LIB_DIR)/libphobos2-ldc.a
LIBDRUNTIME:=$(LIB_DIR)/libdruntime-ldc.a

DC!=which ldc2 || /home/carsten/bin/ldc2-1.36.0-linux-x86_64/bin/ldc2
LIB_DFLAGS+=-mtriple=wasm32-unknown-wasi
LIB_DFLAGS+=--output-o 
LIB_DFLAGS+=-conf= 
LIB_DFLAGS+=-w -de 
LIB_DFLAGS+=-preview=dip1000 -preview=dtorfields -preview=fieldwise 
LIB_DFLAGS+=-od=$(TARGET_DIR)/objects 
LIB_DFLAGS+=-op 
LIB_DFLAGS+=-oq
LIB_DFLAGS+=--lib

#LIB_DFLAGS+=-mtriple=wasm32-linux-wasi
LIB_DFLAGS+=-O3 -release -femit-local-var-lifetime 
LIB_DFLAGS+=-flto=thin 

WASI_FILTER+=-a -not -path "*/linux/*"
WASI_FILTER+=-a -not -path "*/windows/*"
WASI_FILTER+=-a -not -path "*/phobos/tools/*"
WASI_FILTER+=-a -not -path "*/tests/*"
WASI_FILTER+=-a -not -path "*/test/*"
WASI_FILTER+=-a -not -name "unittest.d"
WASI_FILTER+=-a -not -name "eh_msvc.d"
WASI_FILTER+=-a -not -name "dwarfeh.d"
WASI_FILTER+=-a -not -name "dwarf.d"
WASI_FILTER+=-a -not -name "test_runner.d"

cfiles=$(shell find $1 -name "*.c" -printf "%p ")
#dfiles=$(shell find $1 -name "*.d" $(WASI_FILTER) -printf "%P ")
dfiles=$(shell find $1 -name "*.d" $(WASI_FILTER) -printf "%P ")
#OBJDC=$($(call cfiles,$(PHOBOS_SRC)):.c=.o)
CFILES:=$(call cfiles,$(PHOBOS_SRC))
COBJS:=$(notdir $(CFILES))
COBJS:=$(COBJS:.c=.o)
COBJS:=$(addprefix $(OBJC_DIR)/,$(COBJS))

libdc: CFILES+=$(call cfiles,$(PHOBOS_SRC))
libdc: CFLAGS+=-I$(PHOBOS_SRC)
libdc: CFLAGS+=-I$(PHOBOS_SRC)/etc/c/zlib
libdc: CFLAGS+=-I$(WASI_INC)
libdc: CFLAGS+=-c
libdc: CFLAGS+=--target=wasm32-unknown-wasi
libdc: $(COBJS)

libdruntime: $(LIBDRUNTIME)

#$(LIBDRUNTIME): $(LIB_DIR)/libdruntime-ldc.a
$(LIBDRUNTIME): DINC+=-I$(DRUNTIME_SRC)
$(LIBDRUNTIME): DFILES=$(call dfiles,$(DRUNTIME_SRC))
$(LIBDRUNTIME): SRC_DIR=$(DRUNTIME_SRC)

libphobos2: $(LIBPHOBOS2) 

$(LIBPHOBOS2): libdc
$(LIBPHOBOS2): OBJS=$(COBJS)
$(LIBPHOBOS2): DFILES=$(call dfiles,$(PHOBOS_SRC))
$(LIBPHOBOS2): DINC+=-I$(DRUNTIME_SRC)
$(LIBPHOBOS2): DINC+=-I$(PHOBOS_SRC)
$(LIBPHOBOS2): SRC_DIR=$(PHOBOS_SRC)

ways: $(OBJ_DIR)/.way
ways: $(LIB_DIR)/.way

%/.way:
	mkdir -p $(@D)
	touch $@

$(COBJS)&: $(CFILES)| $(OBJ_DIR)/c/.way  
	@echo C objects 
	cd $(OBJ_DIR)/c; clang $^ -c $(CFLAGS)
	#touch $@
	

$(OBJDC): $(OBJ_DIR)/c/.way 
	cd $(OBJ_DIR)/c; clang $(CFLAGS) $(CFILES)

#$(LIBDC): $(COBJS)
#	ar -r $@ $< 
	#cd $(OBJ_DIR)/c; clang $(CFLAGS) $(CFILES)
		

$(LIB_DIR)/%.a: ways
	cd $(SRC_DIR); $(DC) $(LIB_DFLAGS) $(DINC) $(DFILES) $(OBJS) -of $@

#compile: ways 
#	cd $(SRC_DIR); $(DC) $(LIB_DFLAGS) $(DINC) $(DFILES) -of $(LIB)

check-druntime:
	find $(DRUNTIME_SRC) -name "*.d" $(WASI_FILTER) -exec grep -nH _d_throw_exception {} \;

check-phobos:
	find $(PHOBOS_SRC) -name "*.d" $(WASI_FILTER) -exec grep -nH _d_throw_exception {} \;

dfiles-druntime:
	find $(DRUNTIME_SRC) -name "*.d" $(WASI_FILTER) -printf "%P\n"

dfiles-phobos:
	find $(PHOBOS_SRC) -name "*.d" $(WASI_FILTER) -printf "%P\n"

clean-druntime:
	rm -f $(LIB_DIR)/libdruntime-ldc.a
	rm -f $(LIB_DIR)/libphobos2-ldc.a
	rm -fR $(OBJ_DIR)

clean: clean-druntime


