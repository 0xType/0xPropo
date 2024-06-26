FONT_NAME = 0xPropo
TARGET_WEIGHT = Medium
GLYPHS_FILE = $(FONT_NAME).glyphs
OUTPUT_DIR = fonts
UFO_DIR = $(FONT_NAME)-$(TARGET_WEIGHT).ufo
WOFF2_DIR = woff2

setup:
	pip install -r requirements.txt
	if [ ! -e $(WOFF2_DIR) ]; then $(MAKE) setup-woff2; fi

setup-woff2:
	git clone --recursive https://github.com/google/woff2.git $(WOFF2_DIR)
	cd $(WOFF2_DIR) && make clean all

.PHONY: build
build:
	$(MAKE) clean
	$(MAKE) ufo
	$(MAKE) compile-all

ufo:
	glyphs2ufo $(GLYPHS_FILE)

compile-otf: $(FONT_NAME)-$(TARGET_WEIGHT).ufo
	fontmake -u $(FONT_NAME)-$(TARGET_WEIGHT).ufo -o otf --output-dir $(OUTPUT_DIR)

compile-ttf: $(FONT_NAME)-$(TARGET_WEIGHT).ufo
	fontmake -u $(FONT_NAME)-$(TARGET_WEIGHT).ufo -o ttf --output-dir $(OUTPUT_DIR)

compile-woff2: $(OUTPUT_DIR)/$(FONT_NAME)-$(TARGET_WEIGHT).ttf
	./woff2/woff2_compress $(OUTPUT_DIR)/$(FONT_NAME)-$(TARGET_WEIGHT).ttf

compile-all: $(FONT_NAME)-$(TARGET_WEIGHT).ufo
	$(MAKE) compile-otf
	$(MAKE) compile-ttf && $(MAKE) compile-woff2

.PHONY: clean
clean:
	if [ -e $(OUTPUT_DIR) ]; then rm -rf $(OUTPUT_DIR); fi
	if [ -e $(UFO_DIR) ]; then rm -rf $(UFO_DIR); fi
	if [ -e $(FONT_NAME).designspace ]; then rm $(FONT_NAME).designspace; fi

install-otf-font: $(OUTPUT_DIR)/$(FONT_NAME)-$(TARGET_WEIGHT).otf
	cp $(OUTPUT_DIR)/$(FONT_NAME)-$(TARGET_WEIGHT).otf $(HOME)/Library/Fonts

install-latest:
	$(MAKE) build
	$(MAKE) install-otf-font
