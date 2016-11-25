(* A [GameEngine] regulates and updates the state of a FNAG game state.
 * The updated state is used by other parts to set up the graphics
 * and interface. *)

type monster = {
  nameM: string;
  levelM: int;
  imageM: string;
  currentRoomM: string;
  modusOperandiM: string;
  timeToMoveM: int
}

type door = | One | Two

type dir = | Left | Right | Up | Down

type room = {
  nameR: string;
  imageR: string;
  exitsR: (dir*string) list;
  monstersR: monster list
}

type map = (string*room) list

type state = {
  monsters: (string*monster) list;
  player: string;
  map: map;
  time: int;
  battery: int;
  doorStatus: (door*bool)*(door*bool);
  room: room;
  level: int
}

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
 *  - [map] is the map of the game for the AI to traverse
val random_goal : room -> map -> room *)
let random_goal room map =
  failwith "unimplemented"

(* [weighted_movement room map] returns the next room using weighted
 * movement traversal. Weighted movement traversal weights each path between
 * rooms as a 2-way edge and favors moving along higher weighted edges. In
 * general, paths leaing towards the main room are higher weighted than paths
 * leading away. If the current room is next to the main room and a new room
 * must be selected, the new room is randomly selected and reached before
 * algorithm is restarted.
 * requires:
 *  - [room] is the details of the current room
 *  - [map] is the map of the game for the AI to traverse
val weighted_movement : room -> map -> room *)
let weighted_movement room map =
  failwith "unimplemented"

(* [preset_path room map] returns the next room on a selected random path. If
 * the room is reached, select a new random path.
 * (Paths will have to be determined and preset.)
val preset_path : room -> map -> room *)
let preset_path room map =
  failwith "uniimplemented"

(* [random_walk room map] returns the next room using random walk.
 * requires:
 *  - [room] is the details of the current room
 *  - [map] is the map of the game for the AI to traverse
val random_walk : room -> map -> room *)
let random_walk room map =
  failwith "unimplemented"


(* [Illegal] is raised by the game to indicate that a command is illegal. *)
exception Illegal

(*****************************************************************************
******************************************************************************
*******************************START GAME/LEVEL*******************************
******************************************************************************
******************************************************************************)

open Yojson.Basic.Util

(* Helper functions to get room record fields from json file. *)
let getName room =
  room |> member "name" |> to_string
let getImage room =
  room |> member "image" |> to_string
let getExits room =
  let exitsList = room |> member "exits" |> to_list in
    let makeExit exit =
      let direction exit = let e = (exit |> member "direction" |> to_string) in
        match e with
        | "left" -> Left
        | "right" -> Right
        | "up" -> Up
        | "down" -> Down
        | _ -> raise Illegal
      in
      let exitid exit = exit |> member "room_id" |> to_string in
      (direction exit,exitid exit)
    in List.map makeExit exitsList
let getMonsters room = []

(* Helper function to make room record. *)
let makeRoom room = {
  nameR = getName room;
  imageR = getImage room;
  exitsR = getExits room;
  monstersR = getMonsters room;
}

(* [get_map yojson] returns a valid map.
val get_map : yojson -> map *)
let get_map j =
  (j |> member "rooms" |> to_list) |> List.map makeRoom |>
  List.map (fun roomRec -> (roomRec.nameR, roomRec))

(* Helper functions to get monster record fields from json file. *)
let getNameM monster =
  monster |> member "name" |> to_string
let getLevelM monster =
  monster |> member "level" |> to_int
let getImageM monster =
  monster |> member "image" |> to_string
let getStartRoom monster =
  monster |> member "startRoom" |> to_string
let getModusOp monster =
  monster |> member "modusOperandi" |> to_string
let getTime monster =
  monster |> member "timeToMove" |> to_int

(* Helper function to make monster record. *)
let makeMonster monster = {
  nameM = getNameM monster;
  levelM = getLevelM monster;
  imageM = getImageM monster;
  currentRoomM = getStartRoom monster;
  modusOperandiM = getModusOp monster;
  timeToMoveM = getTime monster;
}

(* [insert_monster lvl state] returns the state with the possible monsters,
 * as corresponding to the level of the game
val insert_monster : yojson -> int -> monster list *)
let insert_monster j lvl =
  (j |> member "monsters" |> to_list) |> List.map makeMonster
  |> List.filter (fun monstRec -> (monstRec.levelM < lvl))
  |> List.map (fun monstRec -> (monstRec.nameM, monstRec))

(* [init_state lvl] returns an initial state based on the current level.
val init_state : yojson -> int -> state *)
let init_state j lvl = {
  monsters = (insert_monster j lvl);
  player = "Student";
  map = (get_map j);
  time = 0;
  battery = 100;
  doorStatus = ((One,true),(Two,true));
  room = List.assoc "main" (get_map j);
  level = lvl
}

(*****************************************************************************
******************************************************************************
*******************************NON-GAME SCREENS*******************************
******************************************************************************
******************************************************************************)

(* [main_view state] enters the player view to that of the main room.
val main_view : state -> state *)
let main_view st =
  failwith "unimplemented"

(* [start] starts a new game.
val start : unit -> state *)
let start () =
  failwith "unimplemented"

(* [quit] quits the level and enters the start screen.
val quit : state *)
let quit st =
  failwith "unimplemented"

(* [exit state] exits the game.
val exit : state -> unit *)
let exit st =
  failwith "unimplemented"

(* [next_level state] allows player to go to the next level if survived.
val next_level : state -> state *)
let next_level st =
  failwith "unimplemented"

(* [game_over state] allows player to restart or quit if lost.
val game_over : state -> state *)
let game_over st =
  failwith "unimplemented"

(*****************************************************************************
******************************************************************************
*************************REQUIRED STATE UPDATE********************************
******************************************************************************
******************************************************************************)

(* [update_time state] returns the state with the time increased. One night is
 * 24 minutes, ie 1 game time hour is 2.5 real time minutes.
val update_time : state -> state *)
let update_time st =
  failwith "unimplemented"

(* [update_battery num state] returns the state with the battery level
 * decreased by a given num of type [int]. Begins at 100% for each level.
 * costs:
 *  - closing door has an initial cost of 5% and 0.2% / sec door stays closed.
 *  - checking cameras has a cost of 0.1% / sec while in use.
val update_battery : int -> state -> state *)
let update_battery num st =
  failwith "unimplemented"

(* [update_monsters_location map] returns the map with updated location(s) of
 * each monster in play.
val update_monsters_location : map -> map *)
let update_monsters map =
  failwith "unimplemented"

(*****************************************************************************
******************************************************************************
******************************IN-GAME UPDATES*********************************
******************************************************************************
******************************************************************************)

(* [shift_view state dir] returns the state with a shifted camera view to
 * [dir] if player is viewing cameras.
 * requires:
 *  - [dir] is direction to shift the current camera view.
val shift_view : state -> dir -> state *)
let shift_view st dr =
  failwith "unimplemented"

(* [camera_view state] enters the player view to that of the camera(s).
val camera_view : state -> state *)
let camera_view st =
  failwith "unimplemented"

(* [update_door_status open door] returns the state with the door status of
 * [door] updated to [open].
 * requires:
 *  - [open] is whether or not the door is open
 *  - [door] is which door is to be updated
val update_door_status : bool -> door -> state *)
let update_door_status op door =
  failwith "unimplemented"


(*****************************************************************************
******************************************************************************
**********************************INTERFACE***********************************
******************************************************************************
******************************************************************************)


(* [room_view s] is the name of the room the player is viewing. *)
let room_view s =
  s.room


(* ========================== function for go ===============================*)
let go dir st =
  (* update current room *)
  try
    let room = List.assoc st.room.nameR st.map in
    let exit = List.assoc dir room.exitsR in
    {st with room = List.assoc exit st.map;}
  with
  | Not_found -> raise Illegal


(* ============================== EVAL LOOP =============================== *)
let show_room r st = (List.assoc r st.map).nameR


(* [main f] is the main entry point from outside this module
 * to load a game from file [f] and start playing it
 *)
let main file_name =
  let rec eval st =
    (* get cmd *)
    let () = print_string "> " in
    let cmd = read_line () in
    let cmd = String.lowercase_ascii cmd in
      let dir =
        match cmd with
        | "left" -> Left
        | "right" -> Right
        | "up" -> Up
        | "down" -> Down
        | _ -> raise Illegal
      in
      let st = try go dir st with
      | Illegal -> let () = print_string "Illegal command!" in eval st
      in
        let () = print_string "You did: " in
        let () = print_endline cmd in
          eval st
  in
  let j = Yojson.Basic.from_file file_name in
  let st = init_state j 0 in
  let () = print_endline (show_room st.room.nameR st) in
    eval st
