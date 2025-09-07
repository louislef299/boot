.PHONY: build test run clean install uninstall
.DEFAULT_GOAL := build

PRODUCT_NAME = boot
PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
BUILD_FLAGS = -c release

build:
	swift build $(BUILD_FLAGS)

test:
	swift test

# Run the application (optionally with ARGS)
run:
	swift run $(PRODUCT_NAME) --input $(ARGS)

install: build
	mkdir -p $(BINDIR)
	install -m 0755 .build/release/$(PRODUCT_NAME) $(BINDIR)

uninstall:
	rm -f $(BINDIR)/$(PRODUCT_NAME)

# Build and generate an Xcode project
xcode:
	swift package generate-xcodeproj

clean:
	swift package clean
	rm -rf .build tmp_install_test
