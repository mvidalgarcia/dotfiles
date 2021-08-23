OS := macos
DOTFILES_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
PATH := $(DOTFILES_DIR)/bin:$(PATH)

all: $(OS)

macos: core-macos packages link

core-macos: brew

brew:
	is-executable brew || curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash

packages: brew-packages vscode node-packages

brew-packages: brew
	brew bundle --file=$(DOTFILES_DIR)/install/Brewfile

vscode: brew-packages
	for EXT in $$(cat install/Codefile); do code --install-extension $$EXT; done

node-packages: brew-packages
	eval $$(fnm env); npm install -g $(shell cat install/npmfile)

stow-macos: brew
	is-executable stow || brew install stow

link: stow-$(OS)
	stow -t $(HOME) config

unlink: stow-$(OS)
	stow --delete -t $(HOME) config

# Work in progress... Inspiration from https://github.com/webpro/dotfiles
