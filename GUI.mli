(* A [gui] regulates the positions of the buttons for the gui
 * The state can be used by other parts to set up graphics and interface. *)
module type GUI = sig

(* [click] stores the location of mouse in coordinates (x,y) *)
type click = (int * int)

(* The type of camera view shift, either left, right, up, or down. *)
type dir

(* [update_disp loc] returns the state after determining what, if any,
 * button was clicked by mapping the click location to the buttons on the gui.
 * Updates state if necessary. *)
val update_disp : click -> unit

end
