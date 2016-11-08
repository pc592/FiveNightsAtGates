(* A [GameEngine] regulates and updates the state of a FNAG game state.
 * The updated state is used by other parts to set up the graphics
 * and interface. *)
module type GameEngine = sig

(* The type of a game monster.
 * stores:
 *  - name: the identifier for the monster
 *  - image: image location for the monster
 *  - startingRoom: where the monster will first appear
 *  - modusOperandi: the algorithm used by the monster for movement
 *  - timeToMove: how long before the monster moves to the next room *)
type monster

(* The type of the game map, storing rooms and their details. *)
type map


(* The type of a room in the map.
 * stores:
 *  - name: the name of the room
 *  - image: the image(s) stored for the location
 *  - exits: the exits associated with the room
 *  - monster: type Monster if one is in the room *)
type room


(* The type of the game state.
 * stores:
 *  - monsters: the possible monsters in play, multiples of type Monster
 *  - player: player's name
 *  - map: game map, of type Map
 *  - time: the time elapsed during a level
 *  - battery: the battery left since the beginning of the level
 *  - doorStatus: maintains statuses of the two doors leading into main room
 *  - view: The current view the camera is watching
 *  - level: The current level (1..5), aka night, the character is playing *)
type state

(* The type of the level. *)
type level

(* [insert_monster lvl state] returns the state with the possible monsters,
 * as corresponding to the level of the game *)
  val insert_monster : level -> state -> state

(* [init_state lvl] returns an initial state based on the current level.*)
  val init_state : level -> state

(* [update_time state] returns the state with the time increased. One night is
 * 24 minutes, ie 1 game time hour is 2.5 real time minutes. *)
  val update_time : state -> state

(* [update_battery num state] returns the state with the battery level
 * decreased by a given num of type [int]. Begins at 100% for each level.
 * costs:
 *  - closing door has an initial cost of 5% and 0.2% / sec door stays closed.
 *  - checking cameras has a cost of 0.1% / sec while in use. *)
  val update_battery : int -> state -> state

(* [update_monsters_location map] returns the map with updated location(s) of
 * each monster in play. *)
  val update_monsters_location : map -> map

(* [update_door_status open which] returns the state with the door status of
 * [which] updated to [open].
 * requires:
 *  - [open] is whether or not the door is open
 *  - [which] is which door is to be updated *)
  val update_door_status : bool -> int -> state

end



