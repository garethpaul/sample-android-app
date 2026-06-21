.PHONY: build check lint root-test test verify

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
override ROOT := $(shell path='$(subst ','"'"',$(MAKEFILE_LIST))'; path=$$(printf '%s' "$$path" | /bin/sed 's/^ //'); [ -f "$$path" ] || exit 1; directory=$$(/usr/bin/dirname -- "$$path"); CDPATH= cd -- "$$directory" && /bin/pwd -P)
export ROOT
ifeq ($(strip $(ROOT)),)
$(error repository Makefile path could not be resolved)
endif

RUN_LEGACY_GRADLE ?= 0
export RUN_LEGACY_GRADLE
export ANDROID_HOME

lint:
	cd "$$ROOT" && $(RUBY) scripts/check_android_contract.rb

test: lint

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
