open Sdlmixer
open Sdlttf

module Music_FX = struct
 let BCKGND1 = "Sound_Effects/Background1.wav"
 let LENGTH1 = 134000;
 let BCKGND2 = "Sound_Effects/Background2.wav"
 let LENGTH2 = 188000;
 let BCKGND3 = "Sound_Effects/Background3.wav"
 let LENGTH3 = 265000;

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
    Sdlmixer.fadein_music ~loops:3 current_song 1.0;
    Sdltimer.delay 1000; (* fade in *)
    Sdltimer.delay length; (* play *)
    Sdlmixer.fadeout_music 2.0;
    Sdltimer.delay 1000; (* fade out *)
    Sdlmixer.halt_music ();
    Sdlmixer.free_music current_song

let start_songs song1 song2 length1 length2 =
  init_song song1 length1;
  init_song song2 length2;

let init_music_fx music_filename =
  Sdl.init [`AUDIO];
  at_exit Sdl.quit;
  Sdlttf.init ();
  at_exit Sdlttf.quit;
  Sdlmixer.open_audio ();
  at_exit Sdlmixer.close_audio;
  start_songs BCKGND1 BCKGND2 LENGTH1 LENGTH2


end

