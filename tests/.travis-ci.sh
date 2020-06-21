git clone https://github.com/patricoferris/ocaml-on-riscv.git
cd ocaml-on-riscv && git checkout travis 
cd tests
if opam ; then
    opam install dune yojson yojson-riscv -y
    eval $(opam env)
    cd opam/yojson
    dune build -x riscv || /bin/true
    spike $pk _build/default.riscv/src/hello.exe
else
    cd basic 
    ocamlopt -ccopt -static -o hello hello.ml 
    spike $pk hello
fi
