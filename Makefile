play:
	ocamlbuild -use-ocamlfind	-pkgs \
	yojson,str,ANSITerminal,sdl,sdl.sdlimage,sdl.sdlttf,sdl.sdlgfx \
	main.byte && ./main.byte


check:
	bash checkenv.sh

clean:
	ocamlbuild -clean
	rm -f checktypes.ml