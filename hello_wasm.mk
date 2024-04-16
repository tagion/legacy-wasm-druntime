
WASMLD?=$(WASI_BIN)/wasm-ld
DC?=ldc2

MAIN:=hello_wasm.wasm
DFILES+=hello_wasm.d
DOBJS:=${DFILES:.d=.o}

DFLAGS+=-defaultlib=c,druntime-ldc,phobos2-ldc
DFLAGS+=-I$(LDC_RUNTIME_ROOT)/druntime/src
DFLAGS+=-I$(LDC_RUNTIME_ROOT)/phobos
#DFLAGS+=-d-version=Posix
DFLAGS+=-mtriple=wasm32-unknown-wasi
DFLAGS+=-c

DFLAGS+=-O3 -release -femit-local-var-lifetime 
DFLAGS+=-flto=thin 


#LIBS+=$(addprefix $(OBJ_DIR),$($(call dfiles,$(DRUNTIME_SRC)):.d=.o))
#LIBS+=$(addprefix $(OBJ_DIR),$($(call dfiles,$(PHOBOS_SRC)):.d=.o))
LIBS+=$(LIB_DIR)/libdruntime-ldc.a
LIBS+=$(LIB_DIR)/libphobos2-ldc.a
LIB_WASI+=$(WASI_SDK_PREFIX)/share/wasi-sysroot/lib/wasm32-wasi/libc.a
#LIB_WASI+=$(WASI_SDK_PREFIX)/share/wasi-sysroot/lib/wasm32-wasi/librt.a
#LIB_WASI+=$(WASI_SDK_PREFIX)/share/wasi-sysroot/lib/wasm32-wasi/libdl.a
#LIB_WASI+=$(WASI_SDK_PREFIX)/share/wasi-sysroot/lib/wasm32-wasi/libpthread.a

LDFLAGS+=--export=__data_end
LDFLAGS+=--export=__heap_base
LDFLAGS+=--allow-undefined
#LDFLAGS+=--no-entry
#LDFLAGS+=--verbose 
#LDFLAGS+=-Wl,--fatal-warnings


run: $(LIBS) 

run: wasm-run

all: $(LIBS) $(MAIN)

wasm-env:
	@echo DFILES=$(DFILES)
	@echo DOBJS=$(DOBJS)
	@echo LIBS=$(LIBS)
	@echo DFLAGS=$(DFLAGS)
	@echo LDFLAGS=$(LDFLAGS)
	@echo WASI_SDK_PREFIX=$(WASI_SDK_PREFIX)

wasm-run: $(MAIN)
	wasmer $<

$(MAIN): $(DOBJS) $(LIBS) 
	$(WASMLD) $< $(LDFLAGS) $(LIBS) $(LIB_WASI)  -o $@

$(DOBJS): $(DFILES)
	$(DC) $< $(DFLAGS)

CLEAN+=clean-test

clean-test:
	rm -f $(DOBJS)
	rm -f $(MAIN)

clean: clean-test
