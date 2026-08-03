OUTPUT ?= daed
APPNAME ?= daed
VERSION ?= 0.0.0.unknown

.PHONY: submodules submodule magisk magisk-zip

daed:

all: clean daed

clean:
	rm -rf dist && rm -rf apps/web/dist && rm -f daed

## Begin Git Submodules
.gitmodules.d.mk: .gitmodules Makefile
	@set -e && \
	submodules=$$(grep '\[submodule "' .gitmodules | cut -d'"' -f2 | tr '\n' ' ' | tr ' \n' '\n' | sed 's/$$/\/.git/g') && \
	echo "submodule_ready=$${submodules}" > $@

-include .gitmodules.d.mk

$(submodule_ready): .gitmodules.d.mk
ifdef SKIP_SUBMODULES
	@echo "Skipping submodule update"
else
	git submodule update --init --recursive -- "$$(dirname $@)" && \
	touch $@
endif

submodule submodules: $(submodule_ready)
	@if [ -z "$(submodule_ready)" ]; then \
		rm -f .gitmodules.d.mk; \
		echo "Failed to generate submodules list. Please try again."; \
		exit 1; \
	fi
## End Git Submodules

## Begin Web
PFLAGS ?=
ifeq (,$(wildcard ./.git))
	PFLAGS += HUSKY=0
endif
dist: package.json pnpm-lock.yaml
	$(PFLAGS) pnpm i
	TURBO_TELEMETRY_DISABLED=1 DO_NOT_TRACK=1 pnpm build
	@if [ -d "apps/web/dist" ]; then \
		rm -rf dist; \
		cp -r apps/web/dist dist; \
	fi
## End Web

## Begin Bundle
DAE_WING_READY=wing/graphql/service/config/global/generated_resolver.go

$(DAE_WING_READY): wing
	cd wing && \
	$(MAKE) deps && \
	cd .. && \
	touch $@

daed: submodule $(DAE_WING_READY) dist
	cd wing && \
	$(MAKE) OUTPUT=../$(OUTPUT) APPNAME=$(APPNAME) WEB_DIST=../dist VERSION=$(VERSION) bundle
## End Bundle

## Begin Magisk
MAGISK_DIR ?= android/magisk
MAGISK_WEB_DIST ?= apps/web/dist

magisk:
	@mkdir -p $(MAGISK_DIR)/system/bin
	@if [ ! -f "wing/daed-android-arm64" ]; then \
		echo "ERROR: Android arm64 binary not found at wing/daed-android-arm64"; \
		echo "Build it first with: cd wing && make OUTPUT=../wing/daed-android-arm64 APPNAME=daed-android-arm64 VERSION=$(VERSION) GOOS=android GOARCH=arm64 bundle"; \
		exit 1; \
	fi
	cp wing/daed-android-arm64 $(MAGISK_DIR)/system/bin/daed
	chmod 755 $(MAGISK_DIR)/system/bin/daed
	@if [ -d "$(MAGISK_WEB_DIST)" ]; then \
		rm -rf $(MAGISK_DIR)/web; \
		cp -r $(MAGISK_WEB_DIST) $(MAGISK_DIR)/web; \
		echo "Web assets copied to $(MAGISK_DIR)/web/"; \
	else \
		echo "WARNING: $(MAGISK_WEB_DIST) not found, skipping web assets (daed binary may have web embedded)"; \
	fi
	@echo "Magisk module staged at $(MAGISK_DIR)/"

magisk-zip: magisk
	@cd $(MAGISK_DIR) && zip -r ../../daed-magisk-$(VERSION).zip . \
		-x ".gitignore"
	@echo "Magisk module zip created: daed-magisk-$(VERSION).zip"
## End Magisk
