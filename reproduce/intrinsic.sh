#!/bin/bash

export WS=`pwd`
# Build riscv rvv intrinsics toolchain
git clone https://github.com/riscv-collab/riscv-gnu-toolchain/
cd riscv-gnu-toolchain
git checkout 8c969a9efe68a811cf524174d25255632029f3d3
git clone https://github.com/gcc-mirror/gcc -b releases/gcc-13 gcc-13
export RISCV_TOOLS_DIR=`pwd`/installed-tools
./configure --prefix=${RISCV_TOOLS_DIR}  --with-arch=rv64gcv_zfh --with-abi=lp64d --with-gcc-src=`pwd`/gcc-13
make -j24 
make install
cd $WS

# Build spike
git clone https://github.com/riscv-software-src/riscv-isa-sim
cd riscv-isa-sim
git checkout c636ad356c3d5fd7d5ee565c59ab7bdc3f3852f5
mkdir build
cd build
../configure --prefix=${RISCV_TOOLS_DIR}
make -j24
make install
cd $WS

# Build pk
git clone https://github.com/riscv-software-src/riscv-pk
export PATH=${RISCV_TOOLS_DIR}/bin:$PATH #for cross compile
cd riscv-pk
git checkout acbe166dac9d1db752ee95f61e65ca82bb875afb
mkdir build
cd build
../configure --prefix=${RISCV_TOOLS_DIR} --host=riscv64-unknown-elf
make -j24
make install
cd $WS

# Build gem5
git clone https://github.com/gem5/gem5
export GEM5_REPO_DIR=`pwd`/gem5
cd gem5
git checkout 025ccadc6823eff93ee9e0a20712000978bbc53e
scons build/RISCV/gem5.opt -j $(($(nproc)-2))
cd $WS


# Build riscv binary
${RISCV_TOOLS_DIR}/bin/riscv64-unknown-elf-gcc -march=rv64gcv_zfh -static -DXLEN=64 -DVLEN=256 -DELEN=64 -mabi=lp64d -g  intrinsic.c -o intrinsic.elf

printf "\n\nsimulation\n-------spike-------\n"
# Run simulation
${RISCV_TOOLS_DIR}/bin/spike --isa=rv64gcv --varch=vlen:256,elen:64 pk intrinsic.elf

# bbl loader
# First four elements of Vs1 = 1 1 1 1 
# First four elements of Vd  = 1 1 1 1 

printf "\n-------gem5-------\n"
${GEM5_REPO_DIR}/build/RISCV/gem5.opt  ${GEM5_REPO_DIR}/configs/deprecated/example/se.py -c intrinsic.elf

# **** REAL SIMULATION ****
# src/sim/simulate.cc:199: info: Entering event queue @ 0.  Starting simulation...
# First four elements of Vs1 = 1 1 1 1 
# First four elements of Vd  = 0 0 0 0 
# Exiting @ tick 4541000 because exiting with last active thread context