# Build ocaml-riscv rsicv-gcc spike
FROM ubuntu:18.04 as builder
RUN apt-get -y update
RUN apt-get install -y curl git make gcc g++ autoconf automake autotools-dev
RUN apt-get install -y libmpc-dev libmpfr-dev libgmp-dev libusb-1.0-0-dev
RUN apt-get install -y gawk build-essential bison flex texinfo gperf libtool
RUN apt-get install -y patchutils bc zlib1g-dev device-tree-compiler pkg-config libexpat-dev
RUN apt-get install -y python python3
RUN rm -rf /var/lib/apt/lists

# Set installation location
ENV RISCV /install 
ENV PROC -j16

# The RISC-V Toolchain: gcc
RUN git clone --recursive https://github.com/riscv/riscv-gnu-toolchain.git

# Spike: The RISC-V ISA Simulator
RUN git clone https://github.com/riscv/riscv-isa-sim.git

# Build gcc
WORKDIR /riscv-gnu-toolchain 
RUN ./configure --prefix=$RISCV --with-arch=rv64imafd
RUN make newlib $PROC
RUN make linux $PROC
RUN make clean 

# Build tools (importantly Spike ISA sim) 
ENV PATH="$RISCV/bin:${PATH}"
RUN ls "$RISCV/bin"
WORKDIR /riscv-isa-sim
ENV RISCV /tools

RUN mkdir build 
WORKDIR /riscv-isa-sim/build
RUN ../configure --prefix=$RISCV
RUN make
RUN make install

# PK: Proxy Kernel for Syscall-ing Programs 
WORKDIR /
RUN git clone https://github.com/riscv/riscv-pk.git
WORKDIR /riscv-pk 
RUN mkdir build 
WORKDIR /riscv-pk/build 
RUN ../configure --prefix=$RISCV --host=riscv64-unknown-elf
RUN make $PROC 
RUN make install 

# Copy over all the built tools 
FROM ubuntu:18.04
RUN apt-get update
RUN apt-get install -y sudo vim device-tree-compiler make
RUN apt-get install -y curl git make gcc autoconf automake autotools-dev
RUN apt-get install -y pkg-config libffi-dev python3-pip software-properties-common

# Copy the modified gcc and spike isa sim
COPY --from=builder /install /usr/local
COPY --from=builder /tools /usr/local

# Add the proxy kernel to the environment 
ENV RISCV /usr/local
ENV pk=$RISCV/riscv64-unknown-elf/bin/pk

# Get OCaml and Cross Compiler :) 
RUN echo "Building OCaml and Cross Compiler"
RUN git clone https://github.com/patricoferris/ocaml.git 
WORKDIR /ocaml
RUN git checkout 4.11
RUN ./configure --prefix=/riscv-ocaml --disable-ocamldoc --disable-debugger --disable-ocamltest 
RUN make -j16 world.opt && make install 
ENV PATH=/riscv-ocaml/bin:$PATH
RUN make clean

RUN git checkout 4.11+cross-riscv && git pull
RUN ./configure --host=riscv64-unknown-linux-gnu --prefix=/riscv-ocaml --disable-ocamldoc --disable-debugger --disable-ocamltest --with-target-bindir=/riscv-ocaml/bin
RUN make -j16 world
RUN make -j16 opt
RUN cp /riscv-ocaml/bin/ocamlrun runtime
RUN make install

WORKDIR /
CMD ["/bin/bash"] 
