# Build ocaml-riscv rsicv-gcc spike
FROM ubuntu:18.04 as builder
RUN apt-get -y update && \ 
  apt-get install -y curl git make gcc g++ autoconf automake autotools-dev \ 
  libmpc-dev libmpfr-dev libgmp-dev libusb-1.0-0-dev \ 
  gawk build-essential bison flex texinfo gperf libtool \ 
  patchutils bc zlib1g-dev device-tree-compiler pkg-config libexpat-dev \ 
  python python3
RUN rm -rf /var/lib/apt/lists

# Set installation location
ENV RISCV /install 
ENV PROC -j8

# GNU Toolchain 
RUN git clone --recursive https://github.com/riscv/riscv-gnu-toolchain.git
# Spike: The RISC-V ISA Simulator
RUN git clone https://github.com/riscv/riscv-isa-sim.git
RUN git clone https://github.com/riscv/riscv-pk.git

# Build gcc
WORKDIR /riscv-gnu-toolchain 
RUN ./configure --prefix=$RISCV --with-arch=rv32gc --with-abi=ilp32d
RUN make newlib $PROC
RUN make linux $PROC
RUN make clean 

# Build 32 bit Spike
ENV PATH="$RISCV/bin:${PATH}"
RUN ls "$RISCV/bin"
WORKDIR /riscv-isa-sim
ENV RISCV /tools

RUN mkdir build
WORKDIR /riscv-isa-sim/build
RUN ../configure --prefix=$RISCV --with-isa=RV32IMAFDC
RUN make
RUN make install

WORKDIR /riscv-pk
RUN mkdir build
WORKDIR /riscv-pk/build
RUN ../configure --prefix=$RISCV --with-arch=rv32gc --with-abi=ilp32d --host=riscv32-unknown-linux-gnu --enable-32bit
RUN make $PROC
RUN make install

FROM ubuntu:18.04
RUN apt-get update && \ 
  apt-get install --no-install-recommends -y sudo vim device-tree-compiler make \
  curl git make gcc g++ autoconf automake autotools-dev \ 
  python3-pip software-properties-common && \
  rm -rf /var/lib/apt/lists/*

# Copy the modified gcc and spike isa sim
COPY --from=builder /install /usr/local
COPY --from=builder /tools /usr/local 

# Set some useful environment variables 
ENV RISCV /usr/local
ENV pk /usr/local/riscv32-unknown-elf/bin/pk 
ENV spike32 "spike --isa=rv32gc"
ENV gcc32 "riscv-unknown-elf-gcc -static -march=rv32gc" 

# Build a normal compiler
RUN git clone https://github.com/patricoferris/ocaml
WORKDIR /ocaml
RUN git checkout 403042794068d29583e8b30e22bde94abaf27192
RUN ./configure --disable-ocamldoc --disable-debugger --disable-ocamltest --prefix=/riscv-ocaml \
            --build=x86_64-pc-linux-gnu --host=i386-linux \
            CC='gcc -m32' AS='as --32' ASPP='gcc -m32 -c' \
            PARTIALLD='ld -r -melf_i386'
RUN make -j8 world.opt && make install
ENV PATH "/riscv-ocaml/bin:${PATH}"

# Build RV32 cross-compiler
RUN git checkout rv32g
RUN make clean
RUN ./configure --host=riscv32-unknown-linux-gnu --prefix=/riscv-ocaml \
            --disable-ocamldoc --disable-debugger --disable-ocamltest \
            --with-target-bindir=/riscv-ocaml/bin \
            CC='riscv32-unknown-linux-gnu-gcc -g -march=rv32g -mabi=ilp32d' \
            AS='riscv32-unknown-linux-gnu-as -g -march=rv32g' \
            ASPP='riscv32-unknown-linux-gnu-gcc -g -march=rv32g -c'
RUN make -j8 world
RUN make -j8 opt
RUN cp /riscv-ocaml/bin/ocamlrun runtime
RUN make install

WORKDIR /
ENTRYPOINT ["/bin/bash"]
