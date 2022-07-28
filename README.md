# A setup script for setting up a new dev environment on apple silicon.
A script to set up most of the tooling I need for new Macs. I had to do it once step by step, that's one too many! :grin:

## What it does
Automates the installation a few key tools, namely `homebrew` (and by extensions `xcode-select` command line tools), tools for signing commits (`git, gpg, gh, pinentry-mac`), the `powerlevel10k` zsh theme and a few `zsh` extensions, `iterm2` adn `vs code`. Also some utilities beyond developing such as `alfred`, `caffeine` and `spotify`, along with the office suit that includes outlook.

Finally, it installs `miniforge` `conda` and sets up a `default` environment with (among others) tensorflow for mac.

The shell script itself is fairly easy to follow so have a look and modify accordingly.

## Usage
```sh
wget https://raw.githubusercontent.com/gkampolis/miniforge_homebrew_init_setup/main/mac_setup.sh
# Modify the script as you see fit, adding or removing packages etc.
chmod +x mac_setup.sh && sh mac_setup.sh
```

## Next steps
1. Import keys to `gpg` and set up `.gitconfig`, using gpg key to sign commits
2. Launch VS Code and sign in for extensions and settings sync
3. Set up iTerm2.
