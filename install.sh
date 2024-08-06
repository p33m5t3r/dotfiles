#!/bin/bash
# a script to get set up on a fresh (ubuntu 22.04 lts) system

# Function to log steps
log_step() {
    echo "$(date): $1"
    echo "$(date): $1" >> install_log.txt
}

# Update system
update_system() {
    log_step "updating system"
    sudo apt update && sudo apt upgrade -y
}

# get ~/.bashrc setup
configure_shell() {
    log_step "configuring bash"
    # todo
}

# get virtualenv, virtualenv wrapper set up
# ... make a new virtualenv `general`
# ... install ./python/requirements.txt to general
configure_python() {
    log_step "setting up python"
    # fill me out
}

# install ligature fonts
configure_fonts() {
    log_step "installing fonts"
}

# install konsole and set profiles
configure_terminal() {
    log_step "configuring the terminal"
}

# install nvim and get the config symlinked
configure_nvim() {
    log_step "configuring neovim"
}

# Configure i3
configure_desktop() {
    log_step "setting up i3"
}

# install chrome, spotify, etc
install_common() {
    log_step "installing user programs"
}

# install common dev tools etc
install_devel() {
    log_step "installing dev tools"
}


# Main installation process
main() {
    update_system
    configure_shell
    configure_python
    configure_fonts
    configure_terminal
    configure_nvim
    configure_desktop
    install_common
    install_devel
}

main
