
(* A [gui] regulates the positions of the buttons for the gui
 * The state can be used by other parts to set up graphics and interface. *)
module type Gui = sig

val create_disp : unit -> Sdlvideo.surface
(* [update_disp loc] returns the state after determining what, if any,
 * button was clicked by mapping the click location to the buttons on the gui.
 * Updates state if necessary. *)
val update_disp : string -> string -> Sdlvideo.surface -> unit

end
