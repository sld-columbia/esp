# Copyright 2018 Columbia University, SLD Group

#
# Images
#

IMAGES = $(wildcard ../data/*.jpg)

#
# Target
#

IMAGE_NAMES = $(basename $(IMAGES))
TARGETS = $(addprefix rgb_, $(IMAGE_NAMES))

#
# Ouput
#

TEXTOUT = $(addsuffix .txt, $(notdir $(IMAGE_NAMES)))

#
# Converter
#

CONVERTER = ./image_to_txt.py

all: $(TARGETS)

$(TARGETS): rgb_%: %.jpg
	@echo " [CONVERTING] $(notdir $<)"
	@$(CONVERTER) $< > $(subst .jpg,,$(notdir $<)).txt

clean:
	@echo " [CLEANING]"
	@rm -f $(TEXTOUT)

.PHONY: all clean $(TARGETS)
