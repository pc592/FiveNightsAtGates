(* An [Gui] regulates the positions of the buttons for the guis
* The state can be used by other parts to set up the graphics
* and interface. *)
module type Gui = sig

(*[update_door_status open which] Updates the door status [open] of either the
first or second [int] door in the main room.*)
 val door_one : unit -> unit

(*[update_door_status open which] Updates the door status [open] of either the
first or second [int] door in the main room.*)
 val door_two : unit -> unit

(*[update_door_status open which] Updates the door status [open] of either the
first or second [int] door in the main room.*)
 val door_two : unit -> unit

(*[update_door_status open which] Updates the door status [open] of either the
first or second [int] door in the main room.*)
 val left : state -> unit

(*[update_door_status open which] Updates the door status [open] of either the
first or second [int] door in the main room.*)
 val right : state -> state

(*[update_door_status open which] Updates the door status [open] of either the
first or second [int] door in the main room.*)
 val left : state -> state

(*[update_door_status open which] Updates the door status [open] of either the
first or second [int] door in the main room.*)
 val right : state -> state

(*[update_door_status open which] Updates the door status [open] of either the
first or second [int] door in the main room.*)
 val update_gui : int * int -> state


end
