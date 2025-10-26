# HiResTxt Library Integration for CoCo
# Downloads and integrates the hirestxt-mod library for CMOC

HIRESTXT_LIB_VERSION := 0.5.0
HIRESTXT_LIB_CACHE := _cache/hirestxt-lib
HIRESTXT_LIB_VERSION_DIR := $(HIRESTXT_LIB_CACHE)/$(HIRESTXT_LIB_VERSION)
HIRESTXT_LIB_PATH := $(HIRESTXT_LIB_VERSION_DIR)/hirestxt
HIRESTXT_LIB_DOWNLOAD_URL := https://github.com/RichStephens/hirestxt-mod/releases/download/$(HIRESTXT_LIB_VERSION)/hirestxt-mod-bin-0.5.0.tar.gz
HIRESTXT_LIB_DOWNLOAD_FILE := $(HIRESTXT_LIB_CACHE)/hirestxt-mod-bin-0.5.0.tar.gz

# Phony target to ensure library is available
.PHONY: .get_hirestxt_lib

.get_hirestxt_lib:
	@if [ ! -f "$(HIRESTXT_LIB_DOWNLOAD_FILE)" ]; then \
		if [ -d "$(HIRESTXT_LIB_VERSION_DIR)" ]; then \
			echo "A directory already exists with version $(HIRESTXT_LIB_VERSION) - please remove it first"; \
			exit 1; \
		fi; \
		HTTPSTATUS=$$(curl -Is $(HIRESTXT_LIB_DOWNLOAD_URL) 2>/dev/null | head -n 1 | awk '{print $$2}'); \
		if [ "$${HTTPSTATUS}" == "404" ] || [ -z "$${HTTPSTATUS}" ]; then \
			echo "ERROR: Unable to find file $(HIRESTXT_LIB_DOWNLOAD_URL)"; \
			exit 1; \
		fi; \
		echo "Downloading hirestxt-mod version $(HIRESTXT_LIB_VERSION) from $(HIRESTXT_LIB_DOWNLOAD_URL)"; \
		mkdir -p $(HIRESTXT_LIB_CACHE); \
		mkdir -p $(HIRESTXT_LIB_VERSION_DIR); \
		curl -sL $(HIRESTXT_LIB_DOWNLOAD_URL) -o $(HIRESTXT_LIB_DOWNLOAD_FILE); \
		echo "Extracting to $(HIRESTXT_LIB_VERSION_DIR)"; \
		tar -xf $(HIRESTXT_LIB_DOWNLOAD_FILE) -C $(HIRESTXT_LIB_VERSION_DIR); \
		echo "Extraction complete."; \
		( cd "$(HIRESTXT_LIB_VERSION_DIR)" && ln -sf libhirestxt.a hirestxt ); \
	fi;

# Add hirestxt library to include and library paths
CFLAGS += -I$(HIRESTXT_LIB_VERSION_DIR)
ASFLAGS += --asm-include-dir $(HIRESTXT_LIB_VERSION_DIR)
# Add library directory and library name for linking
LDFLAGS += -L$(HIRESTXT_LIB_VERSION_DIR)
LIBS += -lhirestxt
