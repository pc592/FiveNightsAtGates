(* An [Gui] regulates the positions of the buttons for the guis
* The state can be used by other parts to set up the graphics
* and interface. *)
module type Gui = sig

(*[presslocation] stores the location of mouse*)
 type presslocation = int * int

(*[door_one state] Updates the door status [open] of the
first door to either open or closed.*)
 val door_one : state -> state

(*[door_two state] Updates the door status [open] of the
seond door to either open or closed.*)
 val door_two : state -> state

(*[right_map state] shifts to right adjacent room in camera view.*)
 val right_map : state -> state

(*[right_map state] shifts to left adjacent room in camera view.*)
 val left_map : state -> state

(*[exit state] Exits the game.*)
 val exit : state -> state

 (*[quit state] quits the level and enters the main screen.*)
 val quit : state -> state

(*[resume state] resumes the game after it is in menu mode.*)
 val resume : state -> state

 (*[next_level state] allows the player to enter the next level after a victory.*)
 val next_level : state -> state

(*[camera_view state] enters the player into camera_view state.*)
 val camera_view : state -> state

 (*[main_view state] enters the player into main_view state.*)
 val main_view : state -> state

  (*[menu state] pauses the game and displays the menu*)
 val menu : state -> state

(*[update_gui loc state] The master function that takes in a button location
*and matchs it to the appropriate button on the gui.*)
 val update_gui : presslocation -> state -> state


end
