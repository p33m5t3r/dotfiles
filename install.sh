#!/bin/bash
# a script to get set up on a fresh (ubuntu 22.04 lts) system

# Function to log steps
log_step() {
    echo "$(date): $1"
    echo "$(date): $1" >> install_log.txt
}

# update system
update_system() {
    log_step "updating system"
    sudo apt update && sudo apt upgrade -y
}

# install common
install_common() {
    log_step "installing needed packages..."
    sudo apt install -y python3 python3-pip python3-venv \
        neovim konsole i3 i3blocks dmenu i3lock feh
}

# get ~/.bashrc setup
configure_shell() {
    log_step "configuring bash"

    mkdir -p ~/.local/bin
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> ~/.bashrc
}

# get virtualenv, virtualenv wrapper set up
# ... make a new virtualenv `general`
# ... install ./python/requirements.txt to general
configure_python() {
    log_step "setting up python"
    mkdir -p ~/.virtualenvs
    python3 -m venv ~/.virtualenvs/system
    source ~/.virtualenvs/system/bin/activate
    pip install virtualenv virtualenvwrapper
    deactivate
    echo " " >> ~/.bashrc
    echo "# python" >> ~/.bashrc
    echo "export VIRTUALENVWRAPPER_PYTHON=$HOME/.virtualenvs/system/bin/python" >> ~/.bashrc
    echo "export VIRTUALENVWRAPPER_VIRTUALENV=$HOME/.virtualenvs/system/bin/virtualenv" >> ~/.bashrc
    echo "source $HOME/.virtualenvs/system/bin/virtualenvwrapper.sh" >> ~/.bashrc
    echo " " >> ~/.bashrc
    source ~/.bashrc
    mkvirtualenv general
    pip install -r ./python/requirements.txt
    pip install --upgrade pip
    deactivate
}

# install ligature fonts
configure_fonts() {
    log_step "installing ligature fonts"
    TEMP_DIR=$(mktemp -d)

    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip -O "$TEMP_DIR/fira_code.zip"

    unzip "$TEMP_DIR/fira_code.zip" -d "$TEMP_DIR/fira_code"
    mkdir -p ~/.local/share/fonts

    cp "$TEMP_DIR/fira_code/"*.ttf ~/.local/share/fonts
    fc-cache -f -v
    rm -rf "$TEMP_DIR"
}

# install konsole and set profiles
configure_terminal() {
    log_step "configuring the terminal"
    rm -r ~/.local/share/konsole
    cp -r terminal/konsole ~/.local/share
}

# install nvim and get the config symlinked
configure_nvim() {
    log_step "configuring neovim"
    echo "# neovim" >> ~/.bashrc
    echo "alias vim='nvim'" >> ~/.bashrc
    echo " " >> ~/.bashrc

    mkdir -p nvim/lua/vimiq
    git clone https://github.com/p33m5t3r/vimiq.git nvim/lua/vimiq/
    git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim

    cp -r nvim/ ~/.config/
    # now run `:Packer install` a few times

    # lsp stuff:
    ln -s ~/.virtualenvs/general/bin/pylsp ~/.local/bin/pylsp
}

# Configure i3
configure_desktop() {
    log_step "setting up i3"
    mkdir -p ~/.config/i3
    cp ./i3/config ~/.config/i3/config
    # echo "exec i3" > ~/.xsession
}

# install common dev tools etc
install_devel() {
    log_step "installing dev tools"
    # haskell
    sudo apt install build-essential curl libffi-dev libffi8 \
        libgmp-dev libgmp10 libncurses-dev pkg-config
    
    curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
}


# main installation process
main() {
    # update_system
    # install_common
    # configure_shell
    # configure_python
    # configure_nvim
    # configure_fonts
    # configure_terminal
    # configure_desktop
    install_devel
}

main
