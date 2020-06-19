FROM ubuntu:18.04
RUN apt-get update
RUN apt-get install -y sudo vim device-tree-compiler make
RUN apt-get install -y curl git make gcc autoconf automake autotools-dev
RUN apt-get install -y pkg-config libffi-dev python3-pip software-properties-common

RUN apt-get install -y gcc-riscv64-linux-gnu
RUN echo "Building OCaml and Cross Compiler"


# Spike: RISC-V ISA Simulator
RUN git clone https://github.com/riscv/riscv-isa-sim.git
WORKDIR /riscv-isa-sim
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
RUN ../configure --prefix=$RISCV --host=riscv64-linux-gnu
RUN make $PROC
RUN make install

ENV pk=/riscv64-linux-gnu/bin/pk

# OCaml Cross Compiler
WORKDIR /
RUN git clone https://github.com/patricoferris/ocaml.git
WORKDIR /ocaml
RUN git checkout 4.11
RUN ./configure --prefix=/riscv-ocaml --disable-ocamldoc --disable-debugger --disable-ocamltest
RUN make -j16 world.opt && make install
ENV PATH=/riscv-ocaml/bin:$PATH
RUN make clean

RUN git checkout 4.11+cross-riscv && git pull
RUN ./configure --host=riscv64-linux-gnu --prefix=/riscv-ocaml --disable-ocamldoc --disable-debugger --disable-ocamltest --with-target-bindir=/riscv-ocaml/bin
RUN make -j16 world
RUN make -j16 opt
RUN cp /riscv-ocaml/bin/ocamlrun runtime
RUN make install

WORKDIR /
CMD ["/bin/bash"]
