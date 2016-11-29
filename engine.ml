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
  level: int;
  quit: bool
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

let monster_move mons st =
  (* choose exit, stay seconds randomly *)
  (* TODO: ignore direction now *)
  let dir, exit = random_element st.room.exitsR in
  let next_room = List.assoc exit st.map in
  let stay = random_time 5 in
  (* wait random seconds using [after] *)
  after (Core.Std.sec stay) >>= fun () ->
  (* Pervasives.print out "done" using [printf] *)
  printf "%s%s\n" "monster randomly moved to " next_room.nameR;
  (* move to next room *)
  return st.room

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
(* let random_goal room map : room Deferred.t =
  let _, goal = random_element map in
  move room map goal *)


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
let rec random_walk room map monster =
  let current = List.assoc room.nameR map in
  let exits = current.exitsR in
  let numExits = List.length exits in
  let random = Random.int numExits in
  let (dir,name) = List.nth exits random in
    if name = "main" then random_walk room map monster else
    List.assoc name map

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
        | _ -> Pervasives.print_endline "Not a valid exit direction in this .json."; raise Illegal
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
  |> List.filter (fun monstRec -> (monstRec.levelM <= lvl))
  |> List.map (fun monstRec -> (monstRec.nameM, monstRec))

let get_map_with_monsters j lvl map =
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
  map = get_map_with_monsters j lvl (get_map j);
  startTime = Unix.time();
  time = 0.;
  battery = 100.;
  doorStatus = ((One,true),(Two,true));
  room = List.assoc "main" (get_map j);
  level = lvl;
  quit = false
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
let quit st = {st with quit = true;}

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
  {st with time = (now -. st.startTime)*.20.;
           battery = if newBatt < 0. then 0. else newBatt;}


(* [update_battery num state] returns the state with the battery level
 * decreased by a given num of type [int]. Begins at 100% for each level.
 * costs:
 *  - closing door has an initial cost of 5% and 0.2% / sec door stays closed.
 *  - checking cameras has a cost of 0.1% / sec while in use.
val update_battery : int -> state -> state *)
let update_battery_close_door st =
  {st with battery = st.battery -. 2. ;}

(*update map after monster move*)
let update_map_monster_move oldRoom newRoom map monster =
  let midMap = List.map (fun (roomName,roomRec) ->
                if oldRoom.nameR = roomName then
                  let noMons = {roomRec with monsterR = None} in
                    (roomName,noMons)
                else (roomName,roomRec)) map
    in
  let newMap = List.map (fun (roomName,roomRec) ->
                if newRoom.nameR = roomName then
                  let someMons = {roomRec with monsterR = Some monster} in
                    (roomName,someMons)
                else (roomName,roomRec)) midMap
    in newMap

(*update monsters after monster move*)
let update_monsters_monster_move newRoom mons monsters =
  List.map (fun (monsName,monsRec) ->
    if mons.nameM = monsName then
      let newMons = {mons with currentRoomM = newRoom.nameR} in
        (monsName, newMons)
    else (monsName,monsRec)) monsters

(*update state after monster move *)
let update_state_monster_move mons newRoom st =
  let mons_room = List.assoc mons.currentRoomM st.map in
  {st with monsters = update_monsters_monster_move newRoom mons st.monsters;
           map = update_map_monster_move mons_room newRoom st.map mons;
           room = newRoom;}

(*update state after all monsters move. This is used in eval *)
let update_state_monster_move st : state Deferred.t=
  (* TODO: list.hd failed *)
  (* let _, mons = List.hd st.monsters in *)
  let mons = snd (List.hd st.monsters) in
  monster_move mons st >>= fun newRoom ->
  let mons_room = List.assoc mons.currentRoomM st.map in
  let st = {st with monsters = update_monsters_monster_move newRoom mons st.monsters;
           map = update_map_monster_move mons_room newRoom st.map mons;
           room = newRoom;}
  in
  return st

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
  | Not_found -> Pervasives.print_endline "There are no other rooms, you are trapped."; quit st

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

let pretty_string num =
  if int_of_float num = 0 then "00"
  else if int_of_float num < 10 then "0" ^ (string_of_int (int_of_float num))
  else string_of_int (int_of_float num)


let print_time st =
  let hours = floor (st.time/.3600.) in
  let minutes = floor ((st.time -. (hours*.3600.))/.60.) in
  let seconds = st.time -. hours*.3600. -. minutes*.60. in
    ("Time elapsed in hh:mm is: " ^
        pretty_string hours ^ ":" ^ pretty_string minutes)

(* ============================== EVAL LOOP =============================== *)
let global_state = ref (start (Yojson.Basic.from_file "test.json"))

let process_cmd cmd j st =
  let st = !global_state in
  let cmd = String.lowercase_ascii cmd in
  let st =
    if (st.time >= 28800. && st.level = 1) then
      let () = Pervasives.print_endline ("You've survived all the projects. "
        ^ "Congratulations? (Quit/Restart)") in
      match cmd with
      | "quit" -> quit st
      | "restart" -> start j
      | _ -> Pervasives.print_endline ("Illegal command '" ^ cmd ^ "'"); st
    else if st.time >= 28800. then
      let () = Pervasives.print_endline ("You've survived the night! "
        ^ "Next night? (Next/Quit)") in
      match cmd with
      | "next" -> next_level j st
      | "quit" -> quit st
      | _ -> Pervasives.print_endline ("Illegal command '" ^ cmd ^ "'"); st
    else if st.battery <= 0. then
      let () = Pervasives.print_endline "You're out of battery.... (Quit/Restart)" in
      match cmd with
      | "quit" -> quit st
      | "restart" -> start j
      | _ -> Pervasives.print_endline ("Illegal command '" ^ cmd ^ "'"); st
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
        | Illegal -> Pervasives.print_endline ("Illegal command '" ^ cmd ^ "'"); st
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
      | _ -> Pervasives.print_endline ("Illegal command '" ^ cmd ^ "'"); st
  in
  global_state := st


(**
 * [stdin] is used to read input from the command line.
 * [Reader.read_line stdin] will return a deferred that becomes determined
 * when the user types in a line and presses enter.
 *)
let stdin : Reader.t = Lazy.force Reader.stdin

let rec update st : unit =
  upon (after (Core.Std.sec 1.)) (fun _ ->
    let st = update_time_and_battery st in
    match Deferred.peek(update_state_monster_move st) with
    | None -> ()
    | Some st' ->
      global_state := st';
      printf "%s\n" "updated";
      update st'
  )

let rec get_input j st =
  Pervasives.print_endline (print_time st);
  Pervasives.print_endline ("Battery level is: " ^ (string_of_float st.battery) ^ "%");
  Pervasives.print_endline ("You are currently in: " ^ (st.room.nameR) ^ "\n");
  Pervasives.print_string "> ";
  let r = Reader.read_line stdin in
  upon r (fun result ->
    match result with
    | `Eof -> ()
    | `Ok cmd ->
        process_cmd cmd j global_state;
        if !global_state.quit then () else
        get_input j st
  )

let rec eval j st : unit =
  get_input j st;
  update st


(* [main f] is the main entry point from outside this module
 * to load a game from file [f] and start playing it. *)
let rec main fileName =
  let nest_main fileName =
    let j = Yojson.Basic.from_file fileName in
    let st = start j in
      eval j st
  in try nest_main fileName with
  | Sys_error(_) | Illegal ->
    Pervasives.print_endline "\nThat's not a valid .json file.";
    Pervasives.print_endline "Please enter the name of the game file you want to load.\n";
    Pervasives.print_string  "> ";
    let fileName = Pervasives.read_line () in main fileName

