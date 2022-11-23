#!/bin/bash

export PREFIX=$(realpath ../install)
export STDLIB=$(realpath ../install-stdlib)
export PATH=$PREFIX/bin:$PATH
export LD_LIBRARY_PATH=$STDLIB/lib:$LD_LIBRARY_PATH

BACKENDS=(
    bitmask
    cancellation
    ieee
    mca_int
    mca
    verrou
    vprec
)

verificarlo-c test.c -o test

for backend in ${BACKENDS[@]}; do
    VFC_BACKENDS="libinterflop_${backend}.so" ./test 0.1 0.1 &>${backend}.log
    if [[ $? != 0 ]]; then
        echo "Error with backend ${backend}"
        cat ${backend}.log
        exit 1
    else
        echo "${backend} passed"
    fi
done
