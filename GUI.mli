(* A [gui] regulates the positions of the buttons for the gui
 * The state can be used by other parts to set up graphics and interface. *)
module type GUI = sig

(* [click] stores the location of mouse in coordinates (x,y) *)
type click = (int * int)


(* The type of the two doors leading to the main room. [int] *)
type door

(* The type of camera view shift, either left or right. *)
type dir

(* [update_door_status open door] returns the state with the door status of
 * [door] updated to [open].
 * requires:
 *  - [open] is whether or not the door is open
 *  - [door] is which door is to be updated *)
  val update_door_status : bool -> door -> state

(* [shift_view state dir] returns the state with a shifted camera view to
 * [dir] if player is viewing cameras.
 * requires:
 *  - [dir] is direction to shift the current camera view. *)
  val shift_view : state -> dir -> state

(* [camera_view state] enters the player view to that of the camera(s). *)
  val camera_view : state -> state

(* [main_view state] enters the player view to that of the main room. *)
  val main_view : state -> state

(* [start] starts a new game. *)
  val start : unit -> state

(* [quit] quits the level and enters the start screen. *)
  val quit : state

(* [exit state] exits the game. *)
  val exit : state -> unit

(* [next_level state] allows player to go to the next level if survived. *)
  val next_level : state -> state

(* [game_over state] allows player to restart or quit if lost. *)
  val game_over : state -> state

(* [update_gui loc state] returns the state after determining what, if any,
 * button was clicked by mapping the click location to the buttons on the gui.
 * Updates state if necessary. *)
  val update_gui : click -> state -> state

end
