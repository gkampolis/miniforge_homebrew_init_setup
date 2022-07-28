#!/bin/sh
echo " "
##################### Command Line Tools from Xcode
echo "Installing Command Line Tools from Xcode..."
xcode-select --install
echo "Installation finished."

##################### Homebrew 
echo "Installing Homebrew..."
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo "Installation finished."

##################### Homebrew packages
echo "Installing gnupg (gpg2), git and GitHub CLI,"
echo "zsh: powerlevel10k, autosuggestions and syntax highlighting,"
echo "and  alfred, caffeine, spotify and visual studio code."
echo "This script will automatically enable zsh plugins for you."
brew install gpg2 git gh pinentry-mac \
    powerlevel10k zsh-autosuggestions zsh-syntax-highlighting \
    alfred caffeine spotify visual-studio-code

##################### COnfiguring zsh and gpg
echo "Enabling zsh: autosuggestions..."
echo 'source #{HOMEBREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh' >>~/.zshrc
echo "Enabling zsh: syntax highlighting..."
echo 'source #{HOMEBREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >>~/.zshrc
echo "Enabling powerlevel10k..."
echo "source $(brew --prefix)/opt/powerlevel10k/powerlevel10k.zsh-theme" >>~/.zshrc

if [ -d "~/.gnupg/" ] 
then
    echo "Directory ~/.gnupg already exists. Checking for gpg-agent.conf..."
    if [ -f "~/.gnupg/gpg-agent.conf"]
    then
        echo "~/.gnupg/gpg-agent.conf exists. Adding at the end." 
        echo "pinentry-program $(brew --prefix)/bin/pinentry-mac" >>~/.gnupg/gpg-agent.conf
        echo "enable-ssh-support" >>~/.gnupg/gpg-agent.conf
    else
        echo "~/.gnupg/gpg-agent.conf does not exist. Creating and adding options..."
        touch ~/.gnupg/gpg-agent.conf
        echo "pinentry-program $(brew --prefix)/bin/pinentry-mac" >>~/.gnupg/gpg-agent.conf
        echo "enable-ssh-support" >>~/.gnupg/gpg-agent.conf
    fi
    echo "Now checking for gpg.conf..."
    if [ -f "~/.gnupg/gpg.conf"]
    then
        echo "~/.gnupg/gpg.conf exists. Adding at the end."
        echo "use-agent" >>~/.gnupg/gpg.conf
    else
        echo "~/.gnupg/gpg.conf does not exist. Creating and adding options..."
        touch ~/.gnupg/gpg.conf
        echo "use-agent" >~/.gnupg/gpg.conf
    fi
else
    echo "Folder ~/.gnupg/ does not exist. Creating it plus .gpg-agent.conf & gpg.conf inside..."
    mkdir ~/.gnupg/ && touch ~/.gnupg/gpg-agent.conf && touch ~/.gnupg/gpg.conf
    echo "... and adding options."
    echo "pinentry-program $(brew --prefix)/bin/pinentry-mac" >>~/.gnupg/gpg-agent.conf
    echo "enable-ssh-support" >>~/.gnupg/gpg-agent.conf
    echo "use-agent" >~/.gnupg/gpg.conf
fi

echo "Adding .zshrc lines that help with gpg git commit signing"
echo "Adding echo 'export GPG_TTY=$(tty)'..."
echo "export GPG_TTY=$(tty)" >>~/.zshrc

echo "Adding 'gpgconf --launch gpg-agent'..."
echo "gpgconf --launch gpg-agent" >>~/.zshrc

echo "Setting permissions for ~/.gnupg directory..."
chmod 700 ~/.gnupg

##################### Installing miniforge 
echo " "
echo "Downloading latest miniforge release..."
wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-arm64.sh -P ~/Downloads/
echo "Download complete. Installing..."
# Make executable
chmod +x ~/Downloads/Miniforge3-MacOSX-arm64.sh
# Silently install
sh ~/Downloads/Miniforge3-MacOSX-arm64.sh -b -p ~/miniforge3
echo "Installation complete. Initialising for zsh..."
# Setup ZSH shell to activate conda (ZSH is now the default in Mac OS)
eval "$(~/miniforge3/bin/conda shell.zsh hook)"
conda init
# Clean up installation file
echo "cleaning up downloaded file."
rm ~/Downloads/Miniforge3-MacOSX-arm64.sh
echo "Disabling base auto-activation to keep clean."
# Disable auto-activation of the base environment
conda config --set auto_activate_base false

##################### Create default miniforge environment, separate from base
echo " "
echo "Setting up sane 'default' environment, incl. tensorflow for mac." 
# Create new environment with key packages and tensorflow for mac
conda create -n default_tf -y \
    -c conda-forge \
    python=3.9 numpy scipy statsmodels \
    pandas pyarrow \
    jupyterlab jupyter_contrib_nbextensions \
    plotly matplotlib seaborn \
    black pylint pytest pytest-cov mkdocs

conda activate default-tf

# ipywidgets is required by plotly on jupyter,
# for some reason it's never recognised properly on
# above command. Let's  add it here:
conda install "ipywidgets>=7.5"

# Install tensorflow
conda install -y -c apple tensorflow-deps=2.9.0
python -m pip install tensorflow-macos=2.9.0
python -m pip install tensorflow-metal

##################### End of key functionallity

echo "It is strongly advised to restart your shell"
echo "and run 'p10k configure` if wizard doesn't start automatically."

echo "End of script."

echo "Killing (restarting) gpg agent..."
killall gpg-agent

echo "Attempting to restart zsh"
exec zsh
