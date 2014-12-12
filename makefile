
# chugin name
CHUGIN_NAME=FluidSynth

# change this to 1 to use native fluidsynth (i.e. from system directories)
USE_NATIVE_FLUIDSYNTH?=0

ifeq ($(USE_NATIVE_FLUIDSYNTH),0)
    FLUIDSYNTH_PATH?=fluidsynth-static
endif


# all of the c/cpp files that compose this chugin
C_MODULES=
CXX_MODULES=FluidSynth.cpp

ifeq ($(USE_NATIVE_FLUIDSYNTH),0)
    FLAGS+=-I$(FLUIDSYNTH_PATH)/include
    # static link libfluidsynth
    LDFLAGS+=$(FLUIDSYNTH_PATH)/lib/libfluidsynth.a
    FLUIDSYNTH_DEPS=$(FLUIDSYNTH_PATH)/lib/libfluidsynth.a
else
    ifneq ($(FLUIDSYNTH_PATH),)
        FLAGS+=-I$(FLUIDSYNTH_PATH)/include
        LDFLAGS+=-L$(FLUIDSYNTH_PATH)/lib/
    endif
    FLUIDSYNTH_DEPS=
    LDFLAGS+=-lfluidsynth
endif

# where the chuck headers are
CK_SRC_PATH?=chuck/include/


# ---------------------------------------------------------------------------- #
# you won't generally need to change anything below this line for a new chugin #
# ---------------------------------------------------------------------------- #

# default target: print usage message and quit
current: 
	@echo "[chuck build]: please use one of the following configurations:"
	@echo "   make linux, make osx, or make win32"

ifneq ($(CK_TARGET),)
.DEFAULT_GOAL:=$(CK_TARGET)
ifeq ($(MAKECMDGOALS),)
MAKECMDGOALS:=$(.DEFAULT_GOAL)
endif
endif

.PHONY: osx linux linux-oss linux-jack linux-alsa win32
osx linux linux-oss linux-jack linux-alsa: all

win32:
	make -f makefile.win32

CC=gcc
CXX=gcc
LD=g++

CHUGIN_PATH=/usr/lib/chuck

ifneq (,$(strip $(filter osx bin-dist-osx,$(MAKECMDGOALS))))
include makefile.osx
endif

ifneq (,$(strip $(filter linux,$(MAKECMDGOALS))))
include makefile.linux
endif

ifneq (,$(strip $(filter linux-oss,$(MAKECMDGOALS))))
include makefile.linux
endif

ifneq (,$(strip $(filter linux-jack,$(MAKECMDGOALS))))
include makefile.linux
endif

ifneq (,$(strip $(filter linux-alsa,$(MAKECMDGOALS))))
include makefile.linux
endif


ifneq ($(CHUCK_DEBUG),)
FLAGS+= -g
else
FLAGS+= -O3
endif

ifneq ($(CHUCK_STRICT),)
FLAGS+= -Werror
endif



# default: build a dynamic chugin
CK_CHUGIN_STATIC?=0

ifeq ($(CK_CHUGIN_STATIC),0)
SUFFIX=.chug
else
SUFFIX=.schug
FLAGS+= -D__CK_DLL_STATIC__
endif

C_OBJECTS=$(addsuffix .o,$(basename $(C_MODULES)))
CXX_OBJECTS=$(addsuffix .o,$(basename $(CXX_MODULES)))

CHUG=$(addsuffix $(SUFFIX),$(CHUGIN_NAME))

all: $(CHUG)

$(CHUG): $(C_OBJECTS) $(CXX_OBJECTS) $(FLUIDSYNTH_DEPS)
ifeq ($(CK_CHUGIN_STATIC),0)
	$(LD) $(LDFLAGS) -o $@ $(C_OBJECTS) $(CXX_OBJECTS)
else
	ar rv $@ $^
	ranlib $@
endif

$(C_OBJECTS): %.o: %.c $(FLUIDSYNTH_DEPS)
	$(CC) $(FLAGS) -c -o $@ $<

$(CXX_OBJECTS): %.o: %.cpp $(CK_SRC_PATH)/chuck_dl.h $(FLUIDSYNTH_DEPS)
	$(CXX) $(FLAGS) -c -o $@ $<

$(FLUIDSYNTH_PATH)/lib/libfluidsynth.a: 
	make -C $(FLUIDSYNTH_PATH)

install: $(CHUG)
	mkdir -p $(CHUGIN_PATH)
	cp $^ $(CHUGIN_PATH)
	chmod 755 $(CHUGIN_PATH)/$(CHUG)

test:
	chuck --chugin:FluidSynth.chug FluidSynth-play.ck -v5

clean: 
	rm -rf $(C_OBJECTS) $(CXX_OBJECTS) $(CHUG) Release Debug
ifeq ($(USE_NATIVE_FLUIDSYNTH),0)
	make -C $(FLUIDSYNTH_PATH) clean
endif
