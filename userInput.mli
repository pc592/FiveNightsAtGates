(* [userInput] takes player input, processes the input, and calls game engine
 * to update state. *)
module type UI = sig

(* [click] stores the click location of the player's click. *)
type click

(* [oldState] is the state of the game before player's click. *)
type oldState = state

(* [newState] is the state of the game after player's click has been applied. *)
type newState = state

(* [clicked on click oldState gui] determines the new state based on the
 * player's click, gui, and old state of the game. [gui] has the information
 * on where the valid buttons are located. *)
val clicked_on : click -> oldState -> gui -> newState

end