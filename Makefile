.PHONY: build check lint test verify

RUN_LEGACY_GRADLE ?= 0

lint:
	ruby scripts/check_android_contract.rb

test: lint

build:
	@if [ "$(RUN_LEGACY_GRADLE)" = "1" ]; then \
		if [ -n "$(ANDROID_HOME)" ]; then ANDROID_HOME="$(ANDROID_HOME)" ./gradlew assembleDebug ; else ./gradlew assembleDebug ; fi ; \
	else \
		echo "legacy Gradle build skipped; set RUN_LEGACY_GRADLE=1 with a compatible Android SDK"; \
	fi

verify: lint test build

check: verify
