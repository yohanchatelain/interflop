export PREFIX=$(realpath install)
export STDLIB=$(realpath install-stdlib)
export PATH=$PREFIX/bin:$PATH
export LD_LIBRARY_PATH=$STDLIB/lib:$LD_LIBRARY_PATH
