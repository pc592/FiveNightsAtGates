(* A [GameEngine] regulates and updates the state of a FNAG game state.
 * The updated state is used by other parts to set up the graphics
 * and interface. *)

(*****************************************************************************
******************************************************************************
*********************************GLOBAL CONSTANTS*****************************
******************************************************************************
******************************************************************************)

(*
monsterProb [int]: probability 1/monsterProb that the monster will move.
gameNight [float]: length of a night, in game time, in seconds.
  eg, 10 hours is 36000.
levelMaxTime [float]: length of real time for each level to complete, in seconds.
  eg, 20 minutes is 1200.
monsterTime [float]: length of real time a monster is allowed to be in the room
  next to main before the player loses (is killed), in seconds. eg, 5.
maxLevel [int]: the maximum number of levels in the game, same as the maximum
  number of monsters defined in the .json.
cPen [float]: the battery penalty for using the camera.
dPen [float]: the battery penalty for opening/closing door
*)

(*****************************************************************************
******************************************************************************
*************************************TYPES************************************
******************************************************************************
******************************************************************************)

(* The type of a game monster. [record]
 * stores:
 *  - nameM [string]: the identifier for the monster
 *  - levelM [int]: the level the monster enters the game
 *  - imageM [string]: image location for the monster
 *  - currentRoomM [string]: where the monster is currently located.
 *  - modusOperandiM [string]: the algorithm used by the monster for movement
 *  - timeToMoveM [int]: how long it has been since the monster moved
 *  - teleportRoom [string list]: the name(s) of room(s) to teleport/travel to *)
type monster

(* The type of the two doors leading to the main room, left/right, one/two *)
type door

(* The type of camera view shift, either left, right, up, or down.
 *  elsewhere is used to for non-valid directions *)
type dir

(* The type of a room in the map. [record]
 * stores:
 *  - nameR [string]: the name of the room
 *  - imageR [string]: the image(s) location for the location
 *  - valueR [ing]: the value of a room, ie the fewest number of edges to main
 *  - exitsR [(dir*string) list]: the exits associated with the room
 *  - monsterR [monster option]: Some monster if one is in the room or None.
 *                            ** there can only be one monster in a room **)
type room

(* The type of the game map [(string*room) list].
 * stores: rooms and their record. *)
type map

(* The type of the game state. [record]
 * stores:
 *  - monsters [(string*monster) list]: the possible monsters in play
 *  - player [string]: player's name
 *  - map [map]: game map
 *  - startTime [float]: time at start of level
 *  - time [float]: the time elapsed during a level, in game time.
 *  - battery [float]: the battery left since the beginning of the level
 *  - doorStatus [((door*bool)*(door*bool))]: statuses of two doors in main room
 *  - room [room]: The current room the camera is viewing
 *  - level [int]: The current level [1..5], aka night, the player is on
 *  - quit [bool]: whether or not the player has quit, ie if game is ongoing
 *  - lost [bool]: whether or not the player has lost to a monster
 *  - printed [bool]: whether or not a win/lose message was printed *)
type state

(*****************************************************************************
******************************************************************************
**************************MONSTER MOVEMENT ALGORITHMS*************************
******************************************************************************
******************************************************************************)

(* [random_walk room map] returns the next room using random walk.
 * Returned room will not be main nor have another monster in it already.
 * requires:
 *  - [room] is the details of the current room
 *  - [map] is the map of the game for the AI to traverse *)
val random_walk : room -> map -> room

(* [weighted_movement room map monster] returns the next room using weighted
 * movement traversal. Weighted movement traversal requires that each room
 * has a value, with movement towards a lower value more likely. In general,
 * rooms near the main room are lower valued than paths leading away. If the
 * current room is next to the main room and a new room must be selected,
 * or the lower valued room has been reached (ie all other rooms are of equal
 * or higher value) then the monster will teleport. Returned room will not be
 * main nor have another monster in it already.
 * requires:
 *  - [room] is the details of the current room
 *  - [map] is the map of the game for the AI to traverse *)
val weighted_movement : room -> map -> monster -> room

(*****************************************************************************
******************************************************************************
*******************************START GAME/LEVEL*******************************
******************************************************************************
******************************************************************************)

(* [insert_monster j lvl] returns the list of possible monsters,
 * as corresponding to the level of the game *)
val insert_monster : yojson -> int -> (string*monster) list

(* [get_map yojson] returns a valid map from the json file. *)
val get_map : yojson -> map

(* [init_state j lvl] returns an initial state based on the current level.*)
val init_state : yojson -> int -> state

(*****************************************************************************
******************************************************************************
*******************************NON-GAME SCREENS*******************************
******************************************************************************
******************************************************************************)

(* [main_view state] returns a state noting the player is viewing the main room. *)
val main_view : state -> state

(* [start] returns the state of a game at level 0. *)
val start : yojson -> state

(* [next_level j state] returns the state of the next level. *)
val next_level : yojson -> state -> state

(* [quit state] returns the state showing the user has quit the game. *)
val game_over : state -> state

(*****************************************************************************
******************************************************************************
*************************REQUIRED STATE UPDATE********************************
******************************************************************************
******************************************************************************)

(* [update_time_and_battery state] returns the state with the time increased
 * and, if in use, the battery decreased. *)
val update_time_and_battery : state -> state

(*****************************************************************************
******************************************************************************
*************************MONSTER MOVE STATE UPDATE****************************
******************************************************************************
******************************************************************************)

(* [update_state_monster_move monster newRoom map] returns the state with
 * map and monsters updated after [monster] has moved to [newRoom]. *)
val update_state_monster_move : monster -> room -> map -> state

(*****************************************************************************
******************************************************************************
*****************************USER INPUT UPDATES*******************************
******************************************************************************
******************************************************************************)

(* [shift_view state dir] returns the state with a shifted camera view to
 * [dir] if player is viewing cameras. raises Illegal if there is no exit in
 * the direction of [dir].
 * requires:
 *  - [dir] is direction to shift the current camera view. *)
val shift_view : state -> dir -> state

(* [camera_view state] enters the player view to that of the camera.
 * Automatically shifts the room view out of the main room to some other room. *)
val camera_view : state -> state

(* [update_door_status state open door] returns the state with the door status
 * of [door] updated to [open] and battery updated if door status is changed.
 * requires:
 *  - [open] is whether or not the door is open
 *  - [door] is which door is to be updated *)
val update_door_status : state -> bool -> door -> state

(*****************************************************************************
******************************************************************************
**********************************INTERFACE***********************************
******************************************************************************
******************************************************************************)

(* [eval j st cmd] returns a state after evaluating the command. *)
val eval : yojson -> state -> string -> state

(* [main f] is the main entry point from outside this module
 * to load a game from file [f] and start playing it. *)
val main : string -> unit