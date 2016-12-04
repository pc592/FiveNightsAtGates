play:
	ocamlbuild -use-ocamlfind -tags thread	-pkgs \
	yojson,str,ANSITerminal,sdl,sdl.sdlimage,sdl.sdlmixer,sdl.sdlttf,sdl.sdlgfx,async,async_parallel \
	main.byte && ./main.byte


check:
	bash checkenv.sh

clean:
	ocamlbuild -clean
	rm -f checktypes.ml