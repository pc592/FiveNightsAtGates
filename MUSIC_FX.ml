open Sdlttf
open Sdltimer
open Sdlmixer
open Async.Std

(* [Music_FX] Cretes the background music and the sound effects during game play.
 * It utilizes Sdlmixer to open and play audio files as well as stop them, etc.*)
module Music_FX = struct

(*****************************************************************************
******************************************************************************
*********************************GLOBAL CONSTANTS*****************************
******************************************************************************
******************************************************************************)
 (* Global variables that are used to load in specific sound effects and
  * background music. songlength variables store the length of that song in ms.
  *)
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

(*****************************************************************************
******************************************************************************
****************************MUSIC PLAYING HELPER FUNCTIONS********************
******************************************************************************
******************************************************************************)

(* [is_song_playing song] checks if music is still playing every two seconds.
 * If the song is still playing, it will call the function again after two seconds.
 * Otherwise, if the song has finished playing, it will stop everything and free
 * that variable *)
let rec is_song_playing song =
  if (Sdlmixer.playing_music ()) = false then
     (Sdlmixer.fadeout_music 2.0;
      Sdltimer.delay 2000; (* fade out *)
      Sdlmixer.halt_music (); (* stop song *)
      Sdlmixer.free_music song)
  else
    Sdltimer.delay 2000;
    is_song_playing song

(* [init_song music_filename length] takes in a [music_filename] and its [length]
 * as input. The [music_filename] is used to load the file and play the song.
 * [length] helps determine the length of time this song should be played for. *)
let init_song music_filename length=
  let current_song = Sdlmixer.load_music music_filename in
    Sdlmixer.fadein_music ~loops:1 current_song 1.0; (* change loops later *)
    Sdltimer.delay 1000; (* fade in *)
    Sdltimer.delay length; (* play *)
    Sdlmixer.fadeout_music 2.0;
    Sdltimer.delay 1000; (* fade out *)
    Sdlmixer.halt_music ();
    Sdlmixer.free_music current_song

(* [start_songs song1 song2 length1 length2] initializes two songs as background
 * music. Takes in their names and their length. Plays the first input and then
 * plays the second input song. *)
let start_songs song1 song2 length1 length2 =
  init_song song1 length1;
  init_song song2 length2

(* [open_door] when this function is called the sound effect for a door opening
 * is played immediately then it is stopped and the variable is freed. *)
let open_door () =
  Sdlmixer.open_audio ();
  let door_sound = Sdlmixer.load_music door_open in
  Sdlmixer.play_music door_sound;
  Sdltimer.delay 500;
  Sdlmixer.fadeout_music 2.0;
  Sdlmixer.halt_music ();
  Sdlmixer.free_music door_sound

(* [close_door] when this function is called the sound effect for a door closing
 * is played immediately then it is stopped and the variable is freed. *)
let close_door () =
  Sdlmixer.open_audio ();
  let door_sound = Sdlmixer.load_music door_close in
  Sdlmixer.play_music door_sound;
  Sdltimer.delay 500;
  Sdlmixer.fadeout_music 2.0;
  Sdlmixer.halt_music ();
  Sdlmixer.free_music door_sound

(* [open_camera_mode] when this function is called the sound effect for when
 * camera_mode is toggled. Once played, it is stopped and its variable is freed *)
let open_camera_mode () =
  Sdlmixer.open_audio ();
  let cam_mode = Sdlmixer.load_music cam_mode_switch in
  Sdlmixer.play_music cam_mode;
  Sdltimer.delay 150;
  Sdlmixer.fadeout_music 2.0;
  Sdlmixer.halt_music ();
  Sdlmixer.free_music cam_mode

(* [switch_screens] when this function is called the sound effect for when
 * player is switching between room screens when camera mode is on.
 * Once played, it is stopped and its variable is freed *)
let switch_screens () =
  Sdlmixer.open_audio ();
  let switch = Sdlmixer.load_music switch_screens in
  Sdlmixer.play_music switch;
  Sdltimer.delay 150;
  Sdlmixer.fadeout_music 2.0;
  Sdlmixer.halt_music ();
  Sdlmixer.free_music switch

(*****************************************************************************
******************************************************************************
****************************MAIN MUSIC PLAYING FUNCTIONS**********************
******************************************************************************
******************************************************************************)

(* [init_music] initializes the main background music for the game. It plays
 * the music and returns a unit. It goes through two different songs then stops *)
let init_music () =
  Sdl.init [`AUDIO];
  at_exit Sdl.quit;
  Sdlmixer.open_audio ();
  at_exit Sdlmixer.close_audio;
  start_songs background1 background2 song1Length song2Length

(* [update_sounds] checks reference variables to see if they are true. These
 * variables are updated by the Engine module and are constantly checked through
 * a loop. If one of the variables is true, it will play a sound effect
 * corresponding to it. This function returns a unit when it finishes executing
 * i.e. the game ended *)
let rec update_sounds door_open door_close switch_sc cam_mode flag =
  (if (!door_open = true) then (open_door(); door_open := false) else () );
  (if (!door_close = true) then (close_door(); door_close := false) else ());
  (if (!switch_sc = true) then (switch_screens(); switch_sc := false) else ());
  (if (!cam_mode = true) then (open_camera_mode(); cam_mode := false) else  ());
  if (!flag = true) then () else update_sounds door_open door_close switch_sc cam_mode flag

(* [master_song_controller] takes in 5 different reference variables that act like
 * flags for whenever the user is performing a specific action. Given that one of
 * these "flags" are updated to true, the corresponding sound effect or action
 * will be performed. This function is wrapped by a Deferred.any for whenever the
 * user decides to exit the game, everything is closed appropriately and the
 * game can exit flawlessly. *)
let master_song_controller door_open door_close switch_sc cam_mode flag =
  Deferred.any [ return (init_music ());
  return (update_sounds door_open door_close switch_sc cam_mode flag)]

end

