
(* A [gui] regulates the positions of the buttons for the gui
 * graphics and interface. *)
module type Gui = sig

(* [create_disp] opens a graphics window *)
val create_disp : unit -> Sdlvideo.surface

(* [update_disp oldIm newIm window] returns the new image, if needed, to be
 * displayed on the graphics window. *)
val update_disp : string -> string -> Sdlvideo.surface -> unit

end
