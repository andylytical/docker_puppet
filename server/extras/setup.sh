#!/bin/bash

set -x

PW="${PUPPERWARE:-~/pupperware}"

install_toml_rb() {
    $PW/bin/puppetserver gem install toml-rb
}

install_toml_rb
