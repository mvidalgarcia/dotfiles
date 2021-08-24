OS := macos
DOTFILES_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
PATH := $(DOTFILES_DIR)/bin:$(PATH)

all: $(OS)

macos: core-macos packages oh-my-zsh link

core-macos: brew

brew:
	is-executable brew || curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash

packages: brew-packages vscode node-packages

brew-packages: brew
	brew bundle --file=$(DOTFILES_DIR)/install/Brewfile

vscode: brew-packages
	for EXT in $$(cat install/Codefile); do code --install-extension $$EXT; done
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

node-packages: brew-packages
	eval $$(fnm env); npm install -g $(shell cat install/npmfile)

stow-macos: brew
	is-executable stow || brew install stow

link: stow-$(OS)
	stow -t $(HOME) config
	mkdir -p ~/bin
	stow -t $(HOME)/bin bin

unlink: stow-$(OS)
	stow --delete -t $(HOME) config
	stow --delete -t $(HOME)/bin bin

oh-my-zsh:
	sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions


# Work in progress... Inspiration from https://github.com/webpro/dotfiles
