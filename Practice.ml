open Sdlevent
open Sdlkey

let read_string ?(default="") show_string =
    let rec read_more_of s =
        show_string s;
        match wait_event (), s with
        | KEYDOWN {keysym=KEY_ESCAPE}, _ ->
            None
        | KEYDOWN {keysym=KEY_RETURN}, s ->
            Some s
        | KEYDOWN {keysym=KEY_BACKSPACE}, "" ->
            read_more_of ""
        | KEYDOWN {keysym=KEY_BACKSPACE}, s ->
            read_more_of (String.sub s 0 (String.length s - 1))
        | KEYDOWN {keycode='a'..'z'|'A'..'Z'|'0'..'9'|' ' as keycode}, s ->
            let string_of_key = String.make 1 keycode in
            read_more_of (s ^ string_of_key)
        | _, s ->
            read_more_of s
    in
    read_more_of default

let simple_show_string screen font s =
    let s = match s with
        | "" -> " " (* render_text functions don't like empty strings *)
        | _  -> s in
    let background_color = match s with
        | "SDL" -> Sdlvideo.yellow
        | _     -> Sdlvideo.white in
    let text = Sdlttf.render_text_blended font s ~fg:Sdlvideo.black in
    Sdlvideo.fill_rect screen (Sdlvideo.map_RGB screen background_color);
    Sdlvideo.blit_surface ~src:text ~dst:screen ();
    Sdlvideo.flip screen

let run () =
    let screen = Sdlvideo.set_video_mode 600 50 [`DOUBLEBUF] in
    let font = Sdlttf.open_font "Xenotron.ttf" 24 in
    let show_string = simple_show_string screen font in
    match read_string show_string with
    | Some s ->
        show_string ("You entered: '" ^ s ^ "'");
        Sdltimer.delay 1000
    | None ->
        show_string "You escaped the entry field. Wimp!";
        Sdltimer.delay 2000

let main () =
    Sdl.init [`VIDEO];
    at_exit Sdl.quit;
    Sdlttf.init ();
    at_exit Sdlttf.quit;
    Sdlkey.enable_unicode true;
    Sdlkey.enable_key_repeat ();
    run ()

let _ = main ()