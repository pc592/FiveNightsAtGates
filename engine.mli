(* An [GameEngine] regulates the state of a FNAG game state
 * The state can be used by other parts to set up the graphics
 * and interface.
 *)
module type GameEngine = sig

(* A type that stores game relevant information about a monster
 * Stores:
 * name: The identifier for the monster
 * image: Image location for the monster
 * startingRoom: Where the monster will first appear
 * modusOperandi: Details on how to determine where the monster will move
 *  next and how long it will spend in one room
 * timeToMove: How long before the monster moves to the next room.
 *)
type monster

(* A type that stores game relevant information about the map.
 * Each room stores:
 * name: The name of the rooms
 * images: The images stored for the location
 * exits: The exits associated with the room
 * monster: type Monster if one is in the room
 *)
type map

(* A type that stores everything about the game state. Stores:
 * monsters: stores multiples of type Monster
 * player: player's name
 * map: type Map
 * time [int]: the time left before the end of the level
 * battery [int]: How much energy in the battery before the game ends
 * doorStatus [bool * bool] - a tuple controlling the status of the two doors
 *  that lead into the main room
 * view [string]: The current view the camera is watching
 * level [int]: The current level (night) the character is in. is between
 *  1 and 5 inclusive
 *)
type state

(* [insert_monster level state] *)
  val insert_monster : int -> state -> monster -> state -> state

(* [init_state lev] gives an initial state that is based on the current level.*)
  val init_state : int -> state

(* [update_time state] Updates the time of the state [state] by 1. One is equivalent to
 * an hour of in game state time. Returns an updated state*)
  val update_time : state -> state

(* [update_monster_location ma] Updates location of each monster inside of
 * type map [map]*)
  val update_monster_location : map -> map

(* [update_door_status open which] Updates the door status [open] of either the
 * first or second [int] door in the main room.*)
  val update_door_status : bool -> int -> state

(* [update_battery_power num stat] Updates the batter level of the state [state] by
 * subtracting by an integer [num]. One is equivalent *)
  val update_battery_power : int -> state -> state


end



