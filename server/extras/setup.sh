#!/bin/bash

set -x

PW="${PUPPERWARE:-$HOME/pupperware}"

install_toml_rb() {
    "$PW/bin/puppetserver" gem install toml-rb
    "$PW/bin/hup"
}

restart_puppetserver() {
    "$PW/bin/hup"
}

install_toml_rb

restart_puppetserver
