play:
	ocamlbuild -use-ocamlfind	-pkgs \
	yojson,str,sdl,sdl.sdlimage,sdl.sdlmixer,sdl.sdlttf,sdl.sdlgfx \
	main.byte && ./main.byte

test:
	ocamlbuild -use-ocamlfind	-pkgs \
	oUnit,yojson,str,sdl,sdl.sdlimage,sdl.sdlmixer,sdl.sdlttf,sdl.sdlgfx \
	engine_test.byte && ./engine_test.byte

check:
	bash checkenv.sh

clean:
	ocamlbuild -clean
	rm -f checktypes.ml