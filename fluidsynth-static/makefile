
FLUIDSYNTH_DIR=fluidsynth-1.0.9
STAGING_DIR=$(shell pwd)

STAGING_SUBDIRS=$(addprefix $(STAGING_DIR)/,bin include lib share)

all: 
	cd $(FLUIDSYNTH_DIR) &&\
 CFLAGS="$(ARCHOPTS)" LDFLAGS="$(ARCHOPTS)" ./configure --prefix=$(STAGING_DIR) --enable-static &&\
 make &&\
 make install\

clean:
	make -C $(FLUIDSYNTH_DIR) clean
	rm -rf $(STAGING_SUBDIRS)
