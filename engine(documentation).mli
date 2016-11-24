(* A [GameEngine] regulates and updates the state of a FNAG game state.
 * The updated state is used by other parts to set up the graphics
 * and interface. *)

(* The type of a game monster. [record]
 * stores:
 *  - name [string]: the identifier for the monster
 *  - level [int]: the level the monster enters the game
 *  - image [string]: image location for the monster
 *  - currentRoom [string]: where the monster is currently located.
 *  - modusOperandi [string]: the algorithm used by the monster for movement
 *  - timeToMove [int]: how long before the monster moves to the next room *)
type monster

(* The type of the two doors leading to the main room, left/right, one/two *)
type door

(* The type of camera view shift, either left, right, up, or down. *)
type dir

(* The type of a room in the map. [record]
 * stores:
 *  - name [string]: the name of the room
 *  - image [string]: the image(s) location for the location
 *  - exits [(dir*string) list]: the exits associated with the room
 *  - monster [monster]: type monster if one is in the room *)
type room

(* The type of the game map [(string*record) list].
 * stores: rooms and their record. *)
type map

(* The type of the game state. [record]
 * stores:
 *  - monsters [monster list]: the possible monsters in play
 *  - player [string]: player's name
 *  - map [map]: game map
 *  - time [int]: the time elapsed during a level
 *  - battery [int]: the battery left since the beginning of the level
 *  - doorStatus [(bool*bool)]: statuses of the two doors leading to main room
 *  - room [room]: The current room the camera is viewing
 *  - level [int]: The current level [1..5], aka night, the player is on *)
type state

(*****************************************************************************
******************************************************************************
**************************MONSTER MOVEMENT ALGORITHMS*************************
******************************************************************************
******************************************************************************)

(* [random_goal room map] returns the next room using random goal oriented
 * traversal. Random goal oriented traversal randomly chooses a room and moves
 * there as directly as possible, briefly pausing in each room. When goal is
 * reached, pauses for a longer amount of time. Chooses a new random goal when
 * goal is reached.
 * requires:
 *  - [room] is the details of the current room
 *  - [map] is the map of the game for the AI to traverse *)
val random_goal : room -> map -> room

(* [weighted_movement room map] returns the next room using weighted
 * movement traversal. Weighted movement traversal weights each path between
 * rooms as a 2-way edge and favors moving along higher weighted edges. In
 * general, paths leaing towards the main room are higher weighted than paths
 * leading away. If the current room is next to the main room and a new room
 * must be selected, the new room is randomly selected and reached before
 * algorithm is restarted.
 * requires:
 *  - [room] is the details of the current room
 *  - [map] is the map of the game for the AI to traverse *)
val weighted_movement : room -> map -> room

(* [preset_path room map] returns the next room on a selected random path. If
 * the room is reached, select a new random path.
 * (Paths will have to be determined and preset.) *)
val preset_path : room -> map -> room

(* [random_walk room map] returns the next room using random walk.
 * requires:
 *  - [room] is the details of the current room
 *  - [map] is the map of the game for the AI to traverse *)
val random_walk : room -> map -> room

(*****************************************************************************
******************************************************************************
*******************************START GAME/LEVEL*******************************
******************************************************************************
******************************************************************************)

(* [get_map yojson] returns a valid map. *)
val get_map : yojson -> map
(* open Yojson.Basic.Util*)

(* [insert_monster j lvl] returns the state with the possible monsters,
 * as corresponding to the level of the game *)
val insert_monster : yojson -> int -> monster list

(* [init_state j lvl] returns an initial state based on the current level.*)
val init_state : yojson -> int -> state

(*****************************************************************************
******************************************************************************
*******************************NON-GAME SCREENS*******************************
******************************************************************************
******************************************************************************)

(* [main_view state] enters the player view to that of the main room. *)
val main_view : state -> state

(* [start] starts a new game. *)
val start : unit -> state

(* [quit] quits the level and enters the start screen. *)
val quit : state -> state

(* [exit state] exits the game. *)
val exit : state -> unit

(* [next_level state] allows player to go to the next level if survived. *)
val next_level : state -> state

(* [game_over state] allows player to restart or quit if lost. *)
val game_over : state -> state

(*****************************************************************************
******************************************************************************
*************************REQUIRED STATE UPDATE********************************
******************************************************************************
******************************************************************************)

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

(*****************************************************************************
******************************************************************************
******************************IN-GAME UPDATES*********************************
******************************************************************************
******************************************************************************)

(* [shift_view state dir] returns the state with a shifted camera view to
 * [dir] if player is viewing cameras.
 * requires:
 *  - [dir] is direction to shift the current camera view. *)
val shift_view : state -> dir -> state

(* [camera_view state] enters the player view to that of the camera(s). *)
val camera_view : state -> state

(* [update_door_status open door] returns the state with the door status of
 * [door] updated to [open].
 * requires:
 *  - [open] is whether or not the door is open
 *  - [door] is which door is to be updated *)
val update_door_status : bool -> door -> state
