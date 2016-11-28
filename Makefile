test:
	ocamlbuild -pkgs oUnit,yojson,str,ANSITerminal,async -use-ocamlfind -tag thread engine_test.byte && ./engine_test.byte

play:
	ocamlbuild -pkgs oUnit,yojson,str,ANSITerminal,async -use-ocamlfind -tag thread main.byte && ./main.byte

check:
	bash checkenv.sh && bash checktypes.sh

clean:
	ocamlbuild -clean
	rm -f checktypes.ml

