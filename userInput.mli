(* [userInput] takes player input, processes the input, and calls game engine
 * to update state.
 *)
module type UI = sig

(* [click] stores the x and y location on the screen of the player's click. *)
type click = (x * y)

(* [oldState] is the state of the game before player's click. *)
type oldState = state

(* [newState] is the state of the game after player's click. May be the same
 * as the old state. *)
type newState = state

(* [clicked on click oldState gui] determines the newState based on the
 * player's click, gui, and oldState of the game.
 * requires:
 *  - [click] is of type click
 *  - [oldState] is of type oldState
 *  - [gui] has the information on where the buttons are located
 *)
val clicked_on : click -> oldState -> gui -> newState

end