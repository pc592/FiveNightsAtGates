open Sdlttf
open Sdltimer
open Sdlmixer

module Music_FX = struct
 let background1 = "Sound_Effects/Background1.wav"
 let song1Length = 134000
 let background2 = "Sound_Effects/Background2.wav"
 let song2Length = 188000
 let background3 = "Sound_Effects/Background3.wav"
 let song3Length = 265000
 let door_open = "Sound_Effects/open_door.wav"
 let door_close = "Sound_Effects/close_door.wav"
 let switch_screens = "Sound_Effects/switch_screens.wav"
 let cam_mode_switch = "Sound_Effects/cam_mode.wav"

let rec is_song_playing song =
  if (Sdlmixer.playing_music ()) = false then
     (Sdlmixer.fadeout_music 2.0;
      Sdltimer.delay 2000; (* fade out *)
      Sdlmixer.halt_music ();
      Sdlmixer.free_music song)
  else
    Sdltimer.delay 2000;
    is_song_playing song

let init_song music_filename length=
  let current_song = Sdlmixer.load_music music_filename in
    Sdlmixer.fadein_music ~loops:1 current_song 1.0; (* change loops later *)
    Sdltimer.delay 1000; (* fade in *)
    Sdltimer.delay length; (* play *)
    Sdlmixer.fadeout_music 2.0;
    Sdltimer.delay 1000; (* fade out *)
    Sdlmixer.halt_music ();
    Sdlmixer.free_music current_song

let start_songs song1 song2 length1 length2 =
  init_song song1 length1;
  init_song song2 length2

let init_music () =
  Sdl.init [`AUDIO];
  at_exit Sdl.quit;
  Sdlmixer.open_audio ();
  at_exit Sdlmixer.close_audio;
  start_songs background1 background2 song1Length song2Length

let open_door () =
  Sdlmixer.open_audio ();
  let door_sound = Sdlmixer.load_music door_open in
  Sdlmixer.play_music door_sound;
  Sdltimer.delay 500;
  Sdlmixer.fadeout_music 2.0;
  Sdlmixer.halt_music ();
  Sdlmixer.free_music door_sound

let close_door () =
  Sdlmixer.open_audio ();
  let door_sound = Sdlmixer.load_music door_close in
  Sdlmixer.play_music door_sound;
  Sdltimer.delay 500;
  Sdlmixer.fadeout_music 2.0;
  Sdlmixer.halt_music ();
  Sdlmixer.free_music door_sound

let open_camera_mode () =
  Sdlmixer.open_audio ();
  let cam_mode = Sdlmixer.load_music cam_mode_switch in
  Sdlmixer.play_music cam_mode;
  Sdltimer.delay 150;
  Sdlmixer.fadeout_music 2.0;
  Sdlmixer.halt_music ();
  Sdlmixer.free_music cam_mode

let switch_screens () =
  Sdlmixer.open_audio ();
  let switch = Sdlmixer.load_music switch_screens in
  Sdlmixer.play_music switch;
  Sdltimer.delay 150;
  Sdlmixer.fadeout_music 2.0;
  Sdlmixer.halt_music ();
  Sdlmixer.free_music switch

let update_sounds door_open door_close switch_sc cam_mode =
  (if (!door_open = true) then (open_door(); door_open := false) else () );
  (if (!door_close = true) then (close_door(); door_close := false) else ());
  (if (!switch_sc = true) then (switch_screens(); switch_sc := false) else ());
  if (!cam_mode = true) then (open_camera_mode(); cam_mode := false) else  ()

let stop_music () =
  Sdlmixer.halt_music ();
  Sdlmixer.close_audio;
  Sdl.quit

end

