open Sdl
open Sdlloader

module Gui = struct

  let create_disp () = let x = Sdlvideo.set_video_mode 600 450 [`DOUBLEBUF] in
  Sdlvideo.unset_clip_rect x; x

let update_disp previous_image new_image screen =
  (* process click and call state? *)
  if previous_image = new_image then ()
else
  let image = Sdlloader.load_image ("Rooms/" ^ new_image) in
  let position_of_image = Sdlvideo.rect 0 0 0 0 in
  let font = Sdlttf.open_font "Timea.ttf" 14 in
  let text = Sdlttf.render_test_blended font (print_time st) ~fg:Sdlvideo.white in
  let position_of_text = Sdlvideo.rect 150 0 150 150 in
  let map = Sdlloader.load_image ("map.png") in
  let position_of_map = Sdlvideo.rect 0 0 0 0 in
  Sdlvideo.blit_surface ~dst_rect:position_of_image ~src:image ~dst:screen ();
  Sdlvideo.blit_surface ~dst_rect:position_of_text ~src:text ~dst:screen ();
  Sdlvideo.blit_surface ~dst_rect:position_of_map ~src:map ~dst:screen ();
  Sdlvideo.flip screen
(* ocamlbuild -use-ocamlfind -tag thread,sdl,sdl.sdlimage -pkgs oUnit,yojson,str,ANSITerminal,async,threads,sdl,sdl.sdlimage GUI.byte   *)

end