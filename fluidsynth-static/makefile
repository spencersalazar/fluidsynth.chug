
FLUIDSYNTH_DIR=fluidsynth-1.0.9
STAGING_DIR=$(shell pwd)

STAGING_SUBDIRS=$(addprefix $(STAGING_DIR)/,bin include lib share)

CONFIGURE_OPTS=--disable-pulse\
 --disable-alsa-support\
 --disable-portaudio-support\
 --disable-oss-support\
 --enable-midishare\
 --disable-jack-support\
 --disable-coreaudio\
 --disable-coremidi\
 --disable-dart\
 --disable-lash\
 --disable-ladcca\
 --without-readline 

all: 
	cd $(FLUIDSYNTH_DIR) &&\
 CFLAGS="$(ARCHOPTS)" LDFLAGS="$(ARCHOPTS)" \
 ./configure --prefix=$(STAGING_DIR) --enable-static $(CONFIGURE_OPTS)
	make -C $(FLUIDSYNTH_DIR)
	make -C $(FLUIDSYNTH_DIR) install

clean:
	make -C $(FLUIDSYNTH_DIR) clean
	rm -rf $(STAGING_SUBDIRS)
