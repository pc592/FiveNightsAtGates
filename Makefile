test:
<<<<<<< HEAD
	ocamlbuild -pkgs oUnit,yojson,str,ANSITerminal,async engine_test.byte && ./engine_test.byte

play:
	ocamlbuild -pkgs oUnit,yojson,str,ANSITerminal,async main.byte && ./main.byte
=======
	ocamlbuild -pkgs oUnit,yojson,str,ANSITerminal,async -use-ocamlfind -tag thread engine_test.byte && ./engine_test.byte

play:
	ocamlbuild -pkgs oUnit,yojson,str,ANSITerminal,async -use-ocamlfind -tag thread main.byte && ./main.byte
>>>>>>> cabe38576542fae1ae3819286b9a06260ea1d084

check:
	bash checkenv.sh && bash checktypes.sh

clean:
	ocamlbuild -clean
	rm -f checktypes.ml

