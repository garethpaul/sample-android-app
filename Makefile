.PHONY: build check lint root-test test verify
.SECONDEXPANSION:

override SHELL := /bin/sh
override .SHELLFLAGS := -c
override RUBY := ruby
ifneq ($(strip $(MAKEFILES)),)
$(error MAKEFILES must be empty; repository verification requires this Makefile to be loaded alone)
endif
override MAKEFILES :=
ifneq ($(origin MAKEFILE_LIST),file)
$(error MAKEFILE_LIST must not be overridden)
endif
override ROOT := $(shell sed_path=/usr/bin/sed; [ -x "$$sed_path" ] || sed_path=/bin/sed; [ -x "$$sed_path" ] || exit 1; path=$$(printf '%s' '$(subst ','"'"',$(MAKEFILE_LIST))' | "$$sed_path" 's/^ //'); [ -f "$$path" ] || exit 1; directory=$${path%/*}; [ "$$directory" != "$$path" ] || directory=.; CDPATH= cd "$$directory" && pwd -P)
export ROOT
ifeq ($(strip $(ROOT)),)
$(error repository Makefile path could not be resolved)
endif

build check lint root-test test verify: $$(if $$(filter file,$$(origin MAKEFILE_LIST)),,$$(error MAKEFILE_LIST must not be overridden))
build check lint root-test test verify: $$(if $$(shell sed_path=/usr/bin/sed && [ -x "$$$$sed_path" ] || sed_path=/bin/sed && [ -x "$$$$sed_path" ] && path=$$$$(printf '%s' '$$(subst ','"'"',$$(MAKEFILE_LIST))' | "$$$$sed_path" 's/^ //') && [ -f "$$$$path" ] && printf '%s' ok),,$$(error repository Makefile must be loaded alone))

RUN_LEGACY_GRADLE ?= 0
export RUN_LEGACY_GRADLE
export ANDROID_HOME

lint:
	cd "$$ROOT" && $(RUBY) scripts/check_android_contract.rb
	cd "$$ROOT" && $(RUBY) scripts/check_timeline_refresh.rb
	cd "$$ROOT" && $(RUBY) scripts/check_profile_image_lifecycle.rb

test: lint
	/bin/sh "$$ROOT/scripts/test-timeline-publication.sh"
	/bin/sh "$$ROOT/scripts/test-profile-image-publication.sh"
	cd "$$ROOT" && $(RUBY) scripts/test-timeline-refresh-mutations.rb
	cd "$$ROOT" && $(RUBY) scripts/test-profile-image-lifecycle-mutations.rb

build:
	@if [ "$$RUN_LEGACY_GRADLE" = "1" ]; then \
		cd "$$ROOT" && ./gradlew assembleDebug ; \
	else \
		echo "legacy Gradle build skipped; set RUN_LEGACY_GRADLE=1 with a compatible Android SDK"; \
	fi

root-test:
	/bin/sh "$$ROOT/scripts/test-makefile-root.sh"

verify: root-test lint test build

check: verify
