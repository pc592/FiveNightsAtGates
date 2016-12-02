open Sdlevent
open Sdlkey

(*threads.posix*)
module Gui = struct

  let unpack s= match s with None -> "" |Some s -> s

  let create_disp () = let x = Sdlvideo.set_video_mode 600 450 [`DOUBLEBUF] in
  Sdlvideo.unset_clip_rect x; x

let update_disp previous_image new_image screen =
  (* process click and call state? *)
  if previous_image = new_image then () else
  let image = Sdlloader.load_image ("Rooms/" ^ new_image) in
  let position_of_image = Sdlvideo.rect 0 0 0 0 in
  (*Initializes the ttf reader*)
  let () = Sdlttf.init () in
  let font = Sdlttf.open_font "Timea.ttf" 18 in
  let time = Sdlttf.render_text_blended font ("Time: 12:00") ~fg:Sdlvideo.black in
  let battery = Sdlttf.render_text_blended font ("Battery: 98%") ~fg:Sdlvideo.black in
  let position_of_battery = Sdlvideo.rect 10 400 0 0 in
  let position_of_time = Sdlvideo.rect 10 10 0 0 in
  let map = Sdlloader.load_image ("map.png") in
  let position_of_map = Sdlvideo.rect (600-200) (450-114) 0 0 in
  Sdlvideo.blit_surface ~dst_rect:position_of_image ~src:image ~dst:screen ();
  (if new_image = "main.jpg" then () else
    Sdlvideo.blit_surface ~dst_rect:position_of_map ~src:map ~dst:screen ());
  Sdlvideo.blit_surface ~dst_rect:position_of_time ~src:time ~dst:screen ();
  Sdlvideo.blit_surface ~dst_rect:position_of_battery ~src:battery ~dst:screen ();
  Sdlvideo.flip screen
(* ocamlbuild -use-ocamlfind -tag thread -pkgs oUnit,yojson,str,ANSITerminal,async,threads,sdl,sdl.sdlimage,sdl.sdlttf,sdl.sdlgfx GUI.byte  *)

(*
#require "sdl.sdlimage"
#require "sdl.sdlttf"
*)
let translate keycode =
  match keycode with
    |'w' -> "up"
    |'s' -> "down"
    |'a' -> "right"
    |'d' -> "left"
    |'q' -> "door one"
    |'e' -> "door two"
    | _ -> ""

let read_string ?(default="") () : string =
  pump ();Sdltimer.delay 500;
  let x = Sdlvideo.set_video_mode 1 1 [`DOUBLEBUF] in
    let rec read_more_of s :string =
        pump (); if not (has_event ()) then "" else
        match wait_event (), s with
        | KEYDOWN {keysym=KEY_ESCAPE}, _ ->
            "quit"
        | KEYDOWN {keysym=KEY_RETURN}, s ->
            "restart"
        | KEYDOWN {keysym=KEY_SPACE}, "" ->
            "camera"
        | KEYDOWN {keysym=KEY_BACKSPACE}, s ->
            "main"
        | KEYDOWN {keysym=KEY_w}, s ->
            "up"
        | KEYDOWN {keysym=KEY_a}, s ->
            "left"
        | KEYDOWN {keysym=KEY_d}, s ->
            "right"
        | KEYDOWN {keysym=KEY_s}, s ->
            "down"
        | KEYDOWN {keysym=KEY_o}, s ->
            "open one"
        | KEYDOWN {keysym=KEY_p}, s ->
            "close one"
        | KEYDOWN {keysym=KEY_i}, s ->
            "close two"
        | KEYDOWN {keysym=KEY_u}, s ->
            "open two"
        | KEYDOWN {keysym=KEY_n}, s ->
            "next"
        | _, s ->
            read_more_of s
    in
    read_more_of default ;;






  end

