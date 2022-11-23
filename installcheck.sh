#!/bin/bash

REPO=yohanchatelain
PREFIX=$PWD/install
INSTALL=$PWD/install-backend.sh
VALGRIND_VERSION=3.20.0
BACKENDS_PATH=$PWD/backends
FRONTENDS_PATH=$PWD/frontends
PYTHON_VERSION=$(/usr/bin/env python3 -V | cut -d' ' -f2 | cut -d'.' -f1-2)
PYTHONPATH=$PREFIX/lib/python${PYTHON_VERSION}/site-p

BACKENDS=(
    interflop-backend-bitmask
    interflop-backend-cancellation
    interflop-backend-checkcancellation
    interflop-backend-checkdenormal
    interflop-backend-checkfloatmax
    interflop-backend-ieee
    interflop-backend-mcaint
    interflop-backend-mcaquad
    interflop-backend-verrou
    interflop-backend-vprec
)

function check() {
    if [[ $? != 0 ]]; then
        echo "Error"
        exit 1
    fi
}

function Clone() {
    git clone $1
    check
}

function Cd() {
    cd $1
    check
}

function Autogen() {
    ./autogen.sh
    check
}

function Configure() {
    ./configure $@
    check
}

function Make() {
    make -j
    check
}

function MakeInstall() {
    make install
    check
}

function MakeInstallCheck() {
    make installcheck
    check
}

function install_stdlib() {
    Clone https://github.com/${REPO}/interflop-stdlib
    Cd interflop-stdlib
    Autogen
    Configure --enable-warnings --prefix=${PREFIX}
    Make
    MakeInstall
    Cd ..
    export PATH=${PREFIX}/bin:$PATH
    export LD_LIBRARY_PATH=$(interflop-config --libdir):$LD_LIBRARY_PATH
}

function installcheck_stdlib() {
    install_stdlib
    Cd interflop-stdlib/tests
    ./test.sh
    check
    Cd ../..
}

function install_backend() {
    Clone https://github.com/${REPO}/$1
    Cd $1
    Autogen
    Configure --enable-warnings --prefix=${PREFIX}
    Make
    MakeInstall
    Cd ..
}

function install_backends() {
    Cd backends
    for backend in ${BACKENDS[@]}; do
        install_backend $backend
    done
    Cd ..
}

function install_verificarlo() {
    Clone https://github.com/${REPO}/verificarlo
    Cd verificarlo
    git checkout interflop
    Autogen
    Configure --without-flang --with-llvm=$(llvm-config-14 --prefix) --prefix=$PREFIX
    Make
    MakeInstall
    Cd ..
}

function tests_verificarlo() {
    Cd $FRONTENDS_PATH/verificarlo
    MakeInstallCheck
    Cd ..
}

function install_verrou() {
    tar vxf valgrind-${VALGRIND_VERSION}.tar.bz2 valgrind-${VALGRIND_VERSION}
    Cd valgrind-${VALGRIND_VERSION}
    Clone https://github.com/${REPO}/verrou
    Cd verrou
    git checkout interflop
    Cd ..
    patch -p1 <verrou/valgrind.diff
    Autogen
    Configure --enable-only64bit --enable-intrinsic-fma --prefix=$PREFIX
    Make
    MakeInstall
    source ${PREFIX}/env.sh
    Cd ..
}

function tests_verrou() {
    Cd $FRONTENDS_PATH/valgrind-${VALGRIND_VERSION}
    valgrind --help
    check
    valgrind --tool=verrou --help
    check
    make -C tests check
    check
    make -C verrou check
    check
    perl tests/vg_regtest verrou
    check
    Cd verrou/unitTest
    VFC_BACKENDS_LOGGER=False Make
}

function installcheck_frontends() {
    Cd frontends
    install_verificarlo
    tests_verificarlo
    install_verrou
    tests_verrou
    Cd ..
}

installcheck_stdlib
install_backends
installcheck_frontends
