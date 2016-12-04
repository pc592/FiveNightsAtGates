open Sdlevent
open Sdlkey

(*threads.posix*)
module Gui = struct

  let create_disp () = let x = Sdlvideo.set_video_mode 800 600 [`DOUBLEBUF] in
  Sdlvideo.unset_clip_rect x; x

let camera_view roomname new_image screen =
  let image = Sdlloader.load_image ("Rooms/" ^ roomname ^ "/" ^ new_image) in
  let position_of_image = Sdlvideo.rect 0 0 0 0 in
  (*Initializes the ttf reader*)
  let map = Sdlloader.load_image ("map2.png") in
  let position_of_map = Sdlvideo.rect (600-200) (450-114) 0 0 in
  Sdlvideo.blit_surface ~dst_rect:position_of_image ~src:image ~dst:screen ();
  Sdlvideo.blit_surface ~dst_rect:position_of_map ~src:map ~dst:screen ();
  Sdlvideo.update_rect screen

let main_view roomname new_image screen hours battery =
  let image = Sdlloader.load_image ("Rooms/" ^ roomname ^ "/" ^ new_image) in
  let position_of_image = Sdlvideo.rect 0 0 0 0 in
  let () = Sdlttf.init () in
  let font = Sdlttf.open_font "Fonts/Timea.ttf" 18 in
  let position_of_battery = Sdlvideo.rect 10 400 0 0 in
  let position_of_time = Sdlvideo.rect 10 10 0 0 in
  let time = Sdlttf.render_text_blended font ("Time: " ^ hours) ~fg:Sdlvideo.black in
  let battery = Sdlttf.render_text_blended font ("Battery: " ^ battery) ~fg:Sdlvideo.black in
  Sdlvideo.blit_surface ~dst_rect:position_of_image ~src:image ~dst:screen ();
  Sdlvideo.blit_surface ~dst_rect:position_of_time ~src:time ~dst:screen ();
  Sdlvideo.blit_surface ~dst_rect:position_of_battery ~src:battery ~dst:screen ();
  Sdlvideo.update_rect screen



let update_disp roomname new_image screen hours battery=
  (* process click and call state? *)
  match new_image with
  |"main.jpg" -> main_view roomname new_image screen hours battery
  | _ ->     camera_view roomname new_image screen


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

let read_string ?(default="") event : string =
    let read_more_of event =
        match event with
        | KEYDOWN {keysym=KEY_ESCAPE} ->
            "quit"
        | KEYDOWN {keysym=KEY_RETURN} ->
            "restart"
        | KEYDOWN {keysym=KEY_SPACE} ->
            "camera"
        | KEYDOWN {keysym=KEY_w} ->
            "up"
        | KEYDOWN {keysym=KEY_a} ->
            "left"
        | KEYDOWN {keysym=KEY_d} ->
            "right"
        | KEYDOWN {keysym=KEY_s} ->
            "down"
        | KEYDOWN {keysym=KEY_u} ->
            "one"
        | KEYDOWN {keysym=KEY_i} ->
            "two"
        | KEYDOWN {keysym=KEY_n} ->
            "next"
        | _ ->
            ""
    in
    read_more_of event ;;


  (*Watered Down event handler, built for just the menu *)
  let rec read_menu () =
    match wait_event () with
      | KEYDOWN {keysym=KEY_n} ->
        "quit"
      | KEYDOWN {keysym=KEY_y} ->
        "yes"
      | _ ->
          read_menu ()


  let poll_event () = if not (has_event ()) then None else
    let event_opt = poll () in
    event_opt

  let collect_commands () = pump ()


  let rec menu_loop screen =
    let image = Sdlloader.load_image ("menu/" ^ "menu.jpg") in
    let position_of_image = Sdlvideo.rect 0 0 0 0 in
    Sdlvideo.blit_surface ~dst_rect:position_of_image ~src:image ~dst:screen ();
    Sdlvideo.update_rect screen;
    let cmd = read_menu () in
    if cmd = "instructions" then instruction_loop screen else
    let () = Sdl.quit () in
     cmd
  and instruction_loop screen =
    let image = Sdlloader.load_image ("menu/" ^ "instructions.jpg") in
            let position_of_image = Sdlvideo.rect 0 0 0 0 in
            Sdlvideo.blit_surface ~dst_rect:position_of_image ~src:image ~dst:screen ();
            Sdlvideo.update_rect screen;
            let cmd = read_menu () in
            if (not (cmd = "yes")) then instruction_loop screen else
            menu_loop screen

  let menu () =
    let screen = create_disp () in
      "menu_loop screen"


  end

