if opam ; then
    opam install dune yojson yojson-riscv
    eval $(opam env)
    cd opam/yojson
    dune build -x riscv || /bin/true
    spike $pk _build/default.riscv/hello.exe
else
    cd basic 
    ocamlopt -ccopt -static -o hello hello.ml 
    spike $pk hello
fi
