# OCaml + RISC-V Dockerfiles 

[![Build Status](https://travis-ci.org/patricoferris/ocaml-on-riscv.svg?branch=trunk)](https://travis-ci.org/patricoferris/ocaml-on-riscv)

This repo contains Dockerfiles for getting started with the OCaml cross-compiler for RISC-V. Scheduled for the [4.11 release](https://discuss.ocaml.org/t/ocaml-4-11-0-third-alpha-release-with-risc-v-backend/5997) the OCaml compiler will support RISC-V as a target ISA! Unfortunately, the cross-compiling story isn't quite there yet in the compiler so some modifications have been made to get this working. See [this repo](https://github.com/patricoferris/ocaml/tree/4.11+cross-riscv) for them.

These files build on the work by [@dra27](https://github.com/dra27), [@kcsrk](https://twitter.com/kc_srk), [@SaiVK](https://github.com/SaiVK) and [@nojb](https://twitter.com/nojebar). I just glued the pieces together and wrote README. 


## Descriptions 


To build either make sure you have [docker](https://www.docker.com/) installed and run the following commands: 

```
sudo docker build . -t ocaml-riscv
sudo docker run -it ocaml-riscv
```

- `ocaml`: this directory contains a Dockefile for building (a) the RISC-V GNU Toolchain, (b) the RISC-V ISA Simulator (Spike) and (c) OCaml Version 4.11 with RISC-V cross-compiler. Once inside the container `ocamlopt` will cross-compile your OCaml files.
- `opam`: this installs OCaml version *4.11.0+alpha2* inside an Opam switch called **cross** which has [this repository](https://github.com/patricoferris/opam-cross-shakti) of packages available as well. 
- `prebuilt`: similar to the `ocaml` repository except it installs a prebuilt `riscv64-linux-gnu` toolchain so if you don't have the time/computer resource to build the entire toolchain from scratch this might be an easier option to get up and running. 


## Examples

In the `ocaml` version of the Dockerfiles, the simplest example is a *hello-world* application. 

```
echo 'let () = print_string "Hello World, OCaml on RISC-V!\n"' > hello.ml
ocamlopt -ccopt -static -o hello hello.ml
spike $pk hello
```   

Note that the above runs the *statically-linked* executable on the RISC-V Proxy Kernel (to handle the syscalls etc.). 

A more involved example can be found in the `examples` directory which compiles a Yojson example. This is possible because I've [added Yojson](https://github.com/patricoferris/opam-cross-shakti/tree/master/packages/yojson-riscv/yojson-riscv.1.7.0) to the repository described above. In the Yojson example run `dune build -x riscv`. Unfortunately `libc` doesn't support statically linking (it might be worthwhile creating a [musl](https://opam.ocaml.org/packages/ocaml-variants/ocaml-variants.4.10.0+musl+flambda/) version) so the default will fail to compile. The RISC-V one won't. You can now run `spike $pk ./_build/default.riscv/hello.exe`. 

```
eval $(opam env)
opam install yojson yojson-riscv
dune build -x riscv
spike $pk _build/default.riscv/hello.exe 
```
