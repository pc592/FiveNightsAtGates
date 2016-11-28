open Async.Std
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

type dir = | Left | Right | Up | Down | Elsewhere

type room = {
  nameR: string;
  imageR: string;
  exitsR: (dir*string) list;
  monsterR: monster option
}

type map = (string*room) list

type state = {
  monsters: (string*monster) list;
  player: string;
  map: map;
  startTime: float;
  time: float;
  battery: float;
  doorStatus: (door*bool)*(door*bool);
  room: room;
  level: int
}

(*****************************************************************************
******************************************************************************
**************************MONSTER MOVEMENT ALGORITHMS*************************
******************************************************************************
******************************************************************************)

(* select random element from list *)
let random_element lst =
    let n = Random.int (List.length lst) in
    List.nth lst n

(* select random element from list *)
let random_time max =
    float_of_int (Random.int max)

(* [random_goal room map] returns the next room using random goal oriented
 * traversal. Random goal oriented traversal randomly chooses a room and moves
 * there as directly as possible, briefly pausing in each room. When goal is
 * reached, pauses for a longer amount of time. Chooses a new random goal when
 * goal is reached.
 * TODO: LONGEST PAUSE TIME is 5 seconds
 * requires:
 *  - [room] is the details of the current room
 *  - [map] is the map of the game for the AI to traverse
val random_goal : room -> map -> room Deferred.t *)
let random_goal room map : room Deferred.t =
  let _, goal = random_element map in
  let rec move room map goal =
    (* choose exit, stay seconds randomly *)
    (* TODO: ignore direction now *)
    if goal.nameR = room.nameR then return room else
    let dir, exit = random_element room.exitsR in
    let next_room = List.assoc exit map in
    let stay = random_time 5 in
    (* wait random seconds using [after] *)
    after (Core.Std.sec stay) >>= fun () ->
    (* print out "done" using [printf] *)
    printf "%s\n" "monster randomly moved!";
    (* move to next room *)
    move next_room map goal
  in
  move room map goal

(*
(* [random_goal room map monster] guides a monster's movement. The monster goes
  chooses a random room and goes there. Stops in each room on its way random seconds
  of time up to LONGEST PAUSE TIME. Returns goal room after it finished moving
 * LONGEST PAUSE TIME is 5 seconds in a room
 * requires:
 *  - [room] is the details of the current room
 *  - [map] is the map of the game for the AI to traverse
val random_goal : room -> map -> room Deferred.t *)
let random_goal room map monster: room Deferred.t =
  let _, goal = random_element map in
  let rec move room map goal = 
    (* choose exit, stay seconds randomly *)
    (* TODO: ignore direction now *)
    if goal.nameR = room.nameR then return room else
    let dir, exit = random_element room.exitsR in
    let next_room = List.assoc exit map in
    let stay = random_time 5 in

    (* wait random seconds using [after] *)
    after (Core.Std.sec stay) >>= fun () ->
    (* print out "done" using [printf] *)
    printf "%s%s\n" "monster randomly moved to" next_room.nameR;
    (* move to next room *)
    move next_room map goal
  in 
  move room map goal
*)

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
        | _ -> print_endline "Not a valid exit direction in this .json."; raise Illegal
      in
      let exitid exit = exit |> member "room_id" |> to_string in
      (direction exit,exitid exit)
    in List.map makeExit exitsList
let getMonster room = None

(* Helper function to make room record. *)
let makeRoom room = {
  nameR = getName room;
  imageR = getImage room;
  exitsR = getExits room;
  monsterR = getMonster room;
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
val insert_monster : yojson -> int -> (string*monster) list *)
let insert_monster j lvl =
  (j |> member "monsters" |> to_list) |> List.map makeMonster
  |> List.filter (fun monstRec -> (monstRec.levelM < lvl))
  |> List.map (fun monstRec -> (monstRec.nameM, monstRec))

let new_map j lvl map =
  let monsters = insert_monster j lvl in
  let rec nextMonster mons map' =
    match mons with
    | [] -> map'
    | (monsName,monsRec)::t -> let newMap =
                List.map (fun (roomName,roomRec) ->
                if monsRec.currentRoomM = roomName then
                  let newRoom = {roomRec with monsterR = Some monsRec} in
                    (roomName,newRoom)
                else (roomName,roomRec)) map'
              in nextMonster t newMap
  in nextMonster monsters map

(* [init_state lvl] returns an initial state based on the current level.
val init_state : yojson -> int -> state *)
let init_state j lvl = {
  monsters = (insert_monster j lvl);
  player = "Student";
  map = (get_map j);
  startTime = Unix.time();
  time = 0.;
  battery = 100.;
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
  {st with room = List.assoc "main" st.map}
  (* is this supposed to display it too...? *)

(* [start] starts a new game.
val start : yojson -> state *)
let start j =
  init_state j 0

(* [next_level state] allows player to go to the next level if survived.
val next_level : state -> state *)
let next_level j st =
  init_state j (st.level +1)

(* [quit state] quits the game.
val quit : state -> unit *)
let quit st =
  failwith "unimplemented"

(*****************************************************************************
******************************************************************************
*************************REQUIRED STATE UPDATE********************************
******************************************************************************
******************************************************************************)

(* 1 second real time is 24 seconds game time.*)
let update_time_and_battery st =
  let now = Unix.time() in
  let cameraPenalty =
    if st.room.nameR <> "main" then 0.1 else 0. in
  let doorPenalty =
    let doors = st.doorStatus in
      if (snd (fst doors)) && (snd (snd doors)) then 0.
      else if not ((snd (fst doors)) || (snd (snd doors))) then 0.4
      else 0.2
    in
  let newBatt = st.battery -. cameraPenalty -. doorPenalty in
  {st with time = (now -. st.startTime)*.24.;
           battery = if newBatt < 0. then 0. else newBatt;}

(* [update_battery num state] returns the state with the battery level
 * decreased by a given num of type [int]. Begins at 100% for each level.
 * costs:
 *  - closing door has an initial cost of 5% and 0.2% / sec door stays closed.
 *  - checking cameras has a cost of 0.1% / sec while in use.
val update_battery : int -> state -> state *)
let update_battery_close_door st =
  {st with battery = st.battery -. 2.;}

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

let shift_view st dir =
  try
    let exit = List.assoc dir st.room.exitsR in
    {st with room = List.assoc exit st.map;}
  with
  | Not_found -> raise Illegal

let camera_view st =
  try
    let exit = List.assoc Right st.room.exitsR in
    {st with room = List.assoc exit st.map;}
  with
  | Not_found -> try
    let exit = List.assoc Left st.room.exitsR in
    {st with room = List.assoc exit st.map;}
  with
  | Not_found -> try
    let exit = List.assoc Up st.room.exitsR in
    {st with room = List.assoc exit st.map;}
  with
  | Not_found -> try
    let exit = List.assoc Down st.room.exitsR in
    {st with room = List.assoc exit st.map;}
  with
  | Not_found -> print_endline "There are no other rooms, you are trapped."; quit st

let update_door_status st op door =
  match door with
  | One -> let st = if ((snd (fst st.doorStatus)) <> (op)) then
                      update_battery_close_door st
                    else st in
      {st with doorStatus = ((One, op), (snd st.doorStatus));}
  | Two -> let st = if ((snd (snd st.doorStatus)) <> (op)) then
                      update_battery_close_door st
                    else st in
      {st with doorStatus = ((fst st.doorStatus),(Two, op));}

(*****************************************************************************
******************************************************************************
**********************************INTERFACE***********************************
******************************************************************************
******************************************************************************)

(* ============================== EVAL LOOP =============================== *)

let rec eval j st =
  let st = update_time_and_battery st in
    print_endline ("Time elapsed is: " ^ (string_of_float st.time));
    print_endline ("Battery level is: " ^ (string_of_float st.battery));
    print_endline ("You are currently in: " ^ (st.room.nameR));
  let () =
    if (st.time >= 34560.) then
      print_endline "You've survived the night! Next night? (Next/Quit)"
    else if (st.battery <= 0.) then
      print_endline "You're out of battery.... (Quit/Restart)"
  in
  print_string "\n> ";
  let cmd = Pervasives.read_line () in
  let cmd = String.lowercase_ascii cmd in
  let st =
    if st.time >= 34560. then
      match cmd with
      | "next" -> next_level j st
      | "quit" -> quit st
      | _ -> print_endline ("Illegal command '" ^ cmd ^ "'"); st
    else if st.battery <= 0. then
      match cmd with
      | "quit" -> quit st
      | "restart" -> start j
      | _ -> print_endline ("Illegal command '" ^ cmd ^ "'"); st
    else if (st.room.nameR <> "main") &&
      (cmd = "left" || cmd = "right" || cmd = "up" || cmd = "down") then
      let dir =
        match cmd with
        | "left" -> Left
        | "right" -> Right
        | "up" -> Up
        | "down" -> Down
        | _ -> Elsewhere
      in
      try shift_view st dir with
        | Illegal -> print_endline ("Illegal command '" ^ cmd ^ "'"); st
    else
      match cmd with
      | "main" ->  main_view st
      | "camera" -> camera_view st
      | "close one" -> update_door_status st false One
      | "close two" -> update_door_status st false Two
      | "open one"  -> update_door_status st true One
      | "open two"  -> update_door_status st true Two
      | "restart" -> start j
      | "quit" -> quit st
      | _ -> print_endline ("Illegal command '" ^ cmd ^ "'"); st
  in eval j st

(* [main f] is the main entry point from outside this module
 * to load a game from file [f] and start playing it. *)
let rec main fileName =
  let nest_main fileName =
    let j = Yojson.Basic.from_file fileName in
    let st = start j in
      eval j st
  in try nest_main fileName with
  | Sys_error(_) | Illegal ->
    print_endline "\nThat's not a valid .json file.";
    print_endline "Please enter the name of the game file you want to load.\n";
    print_string  "> ";
    let fileName = Pervasives.read_line () in main fileName