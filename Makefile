# Variables
FORGE := forge
SOLIDITY_VERSION := ^0.8.9 # Adjust the version as per your project's requirement

# Emoji Variables
CHECK_EMOJI := ✅
INSTALL_EMOJI := 🔧
BUILD_EMOJI := 🏗️
TEST_EMOJI := 🧪
CLEAN_EMOJI := 🧹
ERROR_EMOJI := ❌

# Check if Foundry is installed, and install it if not
foundry-check:
	@echo "$(CHECK_EMOJI) Checking if Foundry is installed..."
	@which $(FORGE) > /dev/null || make foundry-install

foundry-install:
	@echo "$(INSTALL_EMOJI) Installing Foundry..."
	@curl -L https://foundry.paradigm.xyz | bash
	@echo "$(INSTALL_EMOJI) Foundry installed. Please restart your terminal or source your profile to update your PATH."

# Install dependencies using Foundry
install: foundry-check
	@echo "$(INSTALL_EMOJI) Installing dependencies..."
	$(FORGE) install

# Compile Solidity contracts using Forge
build: foundry-check
	@echo "$(BUILD_EMOJI) Building project with Forge..."
	$(FORGE) build 

# Run tests using Forge
test: foundry-check
	@echo "$(TEST_EMOJI) Running tests..."
	$(FORGE) test

# Clean up build artifacts
clean:
	@echo "$(CLEAN_EMOJI) Cleaning up..."
	rm -rf out cache

# Default target to run all main tasks
all: install build test

.PHONY: foundry-check foundry-install install build test clean all