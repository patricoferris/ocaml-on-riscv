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

# Checkout code before the inline assembly updates 
RUN ./configure -no-ocamldoc -no-debugger -prefix /riscv-ocaml -cc "gcc -m32" -as "as --32" -aspp "gcc -m32 -c" -host i386-linux -partialld "ld -r -melf_i386"
RUN make -j4 world.opt && make install 
ENV PATH="/riscv-ocaml/bin:${PATH}"
# Checkout the latest code with the inline assembly 
RUN make clean && ./configure --target riscv32-unknown-linux-gnu -prefix /riscv-ocaml -no-ocamldoc -no-debugger -target-bindir /riscv-ocaml/bin && make -j4 world || /bin/true 
RUN make -j4 opt
RUN cp /riscv-ocaml/bin/ocamlrun byterun
RUN make install
RUN make clean 

WORKDIR /
ENTRYPOINT ["/bin/bash"]