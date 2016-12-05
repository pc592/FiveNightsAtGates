(* [Music_FX] coordinates the music and sound effects during the game based off
 * event changes triggerred by the gui. *)
module type Music_FX = sig

(* [init_music] initializes the main background music for the game. It plays
 * the music and returns a unit *)
val init_music : unit -> unit

(* [update_sounds] checks reference variables to see if they are true. These
 * variables are updated by the Engine module and are constantly checked through
 * a loop. If one of the variables is true, it will play a sound effect
 * corresponding to it. This function returns a unit when it finishes executing
 * i.e. the game ended *)
val update_sounds : bool ref -> bool ref -> bool ref -> bool ref -> bool ref -> unit

end