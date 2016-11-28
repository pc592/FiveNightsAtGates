test:
	ocamlbuild
		-use-ocamlfind -tag thread
		-pkgs oUnit,yojson,str,ANSITerminal,async,threads
		 engine_test.byte && ./engine_test.byte

play:
	ocamlbuild
		-use-ocamlfind -tag thread
		-pkgs oUnit,yojson,str,ANSITerminal,async,threads
		 main.byte && ./main.byte

check:
	bash checkenv.sh && bash checktypes.sh

clean:
	ocamlbuild -clean
	rm -f checktypes.ml

