#!/bin/bash

#---------- Provision vim environment
vi ~/.vimrc
#--
set nu
set ts=2
set sw=2
set et
set ai
set pastetoggle=<F3>
#
#---------- Set the vim as default editor
sudo update-alternatives --config editor # select the vim basic as the editor in choice

