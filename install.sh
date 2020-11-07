#!/usr/bin/env bash

set -eou pipefail

#
# Install all the configs!
#

function install_brew_packages() {
  echo '⏳ >>> Installing brew'
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

  brew_packages=(
    "direnv"
    "gnupg"
    "pinentry-mac"
    "tmux"
    "neovim"
    "ripgrep"
    "fzf"
    "z"
  )

  brew_cask_packages=(
    "iterm2"
    "docker"
  )

  echo '⏳ >>> Installing brew packages'
  for i in "${brew_packages[@]}"
  do
      brew install $i
  done

  echo '⏳ >>> Installing brew cask packages'
  for i in "${brew_cask_packages[@]}"
  do
      brew cask install $i
  done

  echo '✨ >>> Successfully setup brew packages'
}

function setup_zsh() {
  echo '⏳ >>> Installing oh-my-zsh'
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

  echo '⏳ >>> Installing oh-my-zsh plugins'
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
  git clone https://github.com/zsh-users/zsh-syntax-highlighting \
    "${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "${HOME}/.oh-my-zsh/custom/themes/powerlevel10k"

  echo '✨ >>> Successfully setup zsh'
}

function setup_symlinks() {

  echo '⏳ >>> Setting up symlinks'
  linkables=$( find -H "$PWD" -name '*.symlink' )
  for file in $linkables ; do
    target="$HOME/.$( basename $file '.symlink' )"
    if [ -e $target ]; then
      echo "✋ >>> ~${target#$HOME} already exists. Skipping file"
    else
      echo "⏳ >>> Creating symlink for $file"
      ln -s $file $target
    fi
  done

  if [ ! -d $HOME/.config ]; then
      echo '⏳ >>> Creating ~/.config'
      mkdir -p $HOME/.config
  fi

  # for config in $INSTALLDIR/config/*; do
  #   target=$HOME/.config/$( basename $config )
  #   if [ -e $target ]; then
  #     echo "---------------------------------------------------------"
  #     echo "$(tput setaf 3)JARVIS: ~${target#$HOME} already exists... Skipping.$(tput sgr 0)"
  #     echo "---------------------------------------------------------"
  #   else
  #     echo "---------------------------------------------------------"
  #     echo "$(tput setaf 2)JARVIS: Creating symlink for ${config}.$(tput sgr 0)"
  #     echo "---------------------------------------------------------"
  #     ln -s $config $target
  #   fi
  # done

  echo '✨ >>> Successfully setup symlnks'
}

function setup_vscode() {
  echo '⏳ >>> Installing VSCode settings'
  cp config/vscode/settings.json "${HOME}/Library/Application Support/Code/User/settings.json"

  echo '⏳ >>> Installing VSCode extensions'
  while IFS="" read -r p || [ -n "$p" ]
  do
    code --install-extension "${p}"
  done < config/vscode/extensions

  echo '✨ >>> Successfully setup VSCode'
}

function main() {
  install_brew_packages
  setup_zsh
  setup_symlinks
  setup_vscode
  
  echo "✨ >>> And we're done!"
}

main
