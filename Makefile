override ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
RUBY ?= ruby

.PHONY: build check lint test verify

RUN_LEGACY_GRADLE ?= 0

lint:
	cd "$(ROOT)" && $(RUBY) scripts/check_android_contract.rb

test: lint

build:
	@if [ "$(RUN_LEGACY_GRADLE)" = "1" ]; then \
		if [ -n "$(ANDROID_HOME)" ]; then cd "$(ROOT)" && ANDROID_HOME="$(ANDROID_HOME)" ./gradlew assembleDebug ; else cd "$(ROOT)" && ./gradlew assembleDebug ; fi ; \
	else \
		echo "legacy Gradle build skipped; set RUN_LEGACY_GRADLE=1 with a compatible Android SDK"; \
	fi

verify: lint test build

check: verify
