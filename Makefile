play:
	ocamlbuild -use-ocamlfind -tag thread	-pkgs oUnit,yojson,str,ANSITerminal,async,threads main.byte && ./main.byte


check:
	bash checkenv.sh

clean:
	ocamlbuild -clean
	rm -f checktypes.ml