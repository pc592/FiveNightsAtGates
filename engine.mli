(* A [GameEngine] regulates and updates the state of a FNAG game state.
 * The updated state is used by other parts to set up the graphics
 * and interface. *)
module type GameEngine = sig

(* The type of a game monster. [record]
 * stores:
 *  - name [string]: the identifier for the monster
 *  - image [string]: image location for the monster
 *  - currentRoom [room]: where the monster is currently located.
 *  - modusOperandi [module]: the algorithm used by the monster for movement
 *  - timeToMove [int]: how long before the monster moves to the next room *)
type monster

(* The type of the game map [(string*record) list]. stores rooms and their record. *)
type map

(* The type of a room in the map. [record]
 * stores:
 *  - name [string]: the name of the room
 *  - image [string]: the image(s) location for the location
 *  - exits [list]: the exits associated with the room
 *  - monster [monster]: type Monster if one is in the room *)
type room

(* The type of the game state. [record]
 * stores:
 *  - monsters [monster list]: the possible monsters in play
 *  - player [string]: player's name
 *  - map [Map]: game map
 *  - time [int]: the time elapsed during a level
 *  - battery [int]: the battery left since the beginning of the level
 *  - doorStatus [(bool*bool)]: statuses of the two doors leading to main room
 *  - view [room]: The current view the camera is watching
 *  - level [int]: The current level (1..5), aka night, the player is on *)
type state

(* The type of the two doors leading to the main room. [int] *)
type door

(* [insert_monster lvl state] returns the state with the possible monsters,
 * as corresponding to the level of the game *)
  val insert_monster : int -> state -> state

(* [init_state lvl] returns an initial state based on the current level.*)
  val init_state : int -> state

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

(* [update_door_status open door] returns the state with the door status of
 * [door] updated to [open].
 * requires:
 *  - [open] is whether or not the door is open
 *  - [door] is which door is to be updated *)
  val update_door_status : bool -> door -> state

end



