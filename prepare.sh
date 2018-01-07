#!/bin/bash

function prepare() {
  apt-get -y install qemu gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf libexpat1-dev libncurses5-dev
}
  
prepare
