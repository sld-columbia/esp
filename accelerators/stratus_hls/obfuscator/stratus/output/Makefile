# Copyright 2017 Columbia University, SLD Group

#
# Images
#

IMAGES = $(wildcard *.txt)

#
# Target
#

IMAGE_NAMES = $(basename $(IMAGES))
TARGETS = $(addprefix debayer_, $(IMAGE_NAMES))

#
# Ouput
#

JPEGOUT = $(addsuffix .jpg, $(IMAGE_NAMES))

#
# Converter
#

CONVERTER = ./txt_to_image.py

all: $(TARGETS)

$(TARGETS): debayer_%: %.txt
	@echo " [CONVERTING] $(notdir $<)"
	@$(CONVERTER) $< $(subst .txt,,$<).jpg

clean:
	@echo " [CLEANING]"
	@rm -f $(JPEGOUT)

.PHONY: all clean $(TARGETS)
