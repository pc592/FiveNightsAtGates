test:
	ocamlbuild -pkgs oUnit,yojson,str,ANSITerminal engine_test.byte && ./engine_test.byte

play:
	ocamlbuild -pkgs oUnit,yojson,str,ANSITerminal main.byte && ./main.byte

check:
	bash checkenv.sh && bash checktypes.sh

clean:
	ocamlbuild -clean
	rm -f checktypes.ml
