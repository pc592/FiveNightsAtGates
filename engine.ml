
(* A [GameEngine] regulates and updates the state of a FNAG game state.
 * The updated state is used by other parts to set up the graphics
 * and interface. *)

type monster = {
  nameM: string;
  levelM: int;
  imageM: string;
  currentRoomM: string;
  modusOperandiM: string;
  timeToMoveM: float
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
  quit: bool;
  lost: bool
}

let gameNight = ref 36000. (*10 hours in seconds; game time elapsed*)
let levelMaxTime = ref 1200. (*20 minutes in seconds; real time elapsed*)
let maxLevel = ref 1 (*number of levels - 1 (levels start at 0)*)
let cPen = ref 0.1
let dPen = ref 0.2

(*****************************************************************************
******************************************************************************
**************************MONSTER MOVEMENT ALGORITHMS*************************
******************************************************************************
******************************************************************************)

(* [weighted_movement room map monster] returns the next room using weighted
 * movement traversal. Weighted movement traversal requires that each room
 * has a value, with movement towards a lower value more likely. In general,
 * rooms near the main room are lower valued than paths leading away. If the
 * current room is next to the main room and a new room must be selected,
 * or the lower valued room has been reached (ie all other rooms are of equal
 * or higher value) then the rooms will be randomly revalued. Returned room
 * will not be main nor have another monster in it already.
 * requires:
 *  - [room] is the details of the current room
 *  - [map] is the map of the game for the AI to traverse *)
let weighted_movement room map monster =
  failwith "unimplemented"

(*Bug where sometimes the monster may move despite being right next door. :/*)
let rec random_walk room map monster =
  let current = List.assoc room.nameR map in
  let exits = current.exitsR in
  let numExits = List.length exits in
  let random = Random.int numExits in
  let (dir,name) = List.nth exits random in
    if (name = "main") || ((List.assoc name map).monsterR <> None) then
      random_walk room map monster
    else List.assoc name map

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
        | _ -> Pervasives.print_endline "Not a valid exit direction in this .json.";
                 raise Illegal
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

let get_map_no_monsters j =
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

(* Helper function to make monster record. *)
let makeMonster monster = {
  nameM = getNameM monster;
  levelM = getLevelM monster;
  imageM = getImageM monster;
  currentRoomM = getStartRoom monster;
  modusOperandiM = getModusOp monster;
  timeToMoveM = 2.*.Unix.time();
}

let insert_monster j lvl =
  (j |> member "monsters" |> to_list) |> List.map makeMonster
  |> List.filter (fun monstRec -> (monstRec.levelM <= lvl))
  |> List.map (fun monstRec -> (monstRec.nameM, monstRec))

let get_map j lvl map =
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

let init_state j lvl = {
  monsters = (insert_monster j lvl);
  player = "Student";
  map = get_map j lvl (get_map_no_monsters j);
  startTime = Unix.time();
  time = 0.;
  battery = 100.;
  doorStatus = ((One,true),(Two,true));
  room = List.assoc "main" (get_map_no_monsters j);
  level = lvl;
  quit = false;
  lost = false
}

(*****************************************************************************
******************************************************************************
*******************************NON-GAME SCREENS*******************************
******************************************************************************
******************************************************************************)

let main_view st =
  {st with room = List.assoc "main" st.map}

let start j =
  init_state j 0

let next_level j st =
  init_state j (st.level +1)

let quit st = {st with quit = true;}

(*****************************************************************************
******************************************************************************
*************************REQUIRED STATE UPDATE********************************
******************************************************************************
******************************************************************************)

let update_time_and_battery st =
  let now = Unix.time() in
  let timeMultiplier = (!gameNight)/.(!levelMaxTime) in
  let camPenalty = !cPen in
  let doorPenalty = !dPen in
  let cameraPenalty =
    if st.room.nameR <> "main" then camPenalty else 0. in
  let doorPenalty =
    let doors = st.doorStatus in
      if (snd (fst doors)) && (snd (snd doors)) then 0.
      else if not ((snd (fst doors)) || (snd (snd doors))) then doorPenalty*.2.
      else doorPenalty
    in
  let newBatt = st.battery -. cameraPenalty -. doorPenalty in
  {st with time = (now -. st.startTime)*.timeMultiplier;
           battery = if newBatt < 0. then 0. else newBatt;}

(* Helper function to update map after monster move. *)
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

(* Helper function to update monsters after monster move. *)
let update_monsters_monster_move newRoom mons monsters =
  List.map (fun (monsName,monsRec) ->
    if mons.nameM = monsName then
      let newMons = {mons with currentRoomM = newRoom.nameR;
                               timeToMoveM = Unix.time()} in
        (monsName, newMons)
    else (monsName,monsRec)) monsters

let update_state_monster_move mons newRoom st =
  let upd_room = if st.room.nameR = newRoom.nameR then newRoom else st.room in
  let mons_room = List.assoc mons.currentRoomM st.map in
  {st with monsters = update_monsters_monster_move newRoom mons st.monsters;
           map = update_map_monster_move mons_room newRoom st.map {mons with currentRoomM = newRoom.nameR};
           room = upd_room;}

(*****************************************************************************
******************************************************************************
******************************USER IN UPDATES*********************************
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
  let penalty = st.battery -. 2. in
  match door with
  | One -> let st = if ((snd (fst st.doorStatus)) <> (op)) then
                      {st with battery = if penalty < 0. then 0. else penalty;}
                    else st in
      {st with doorStatus = ((One, op), (snd st.doorStatus));}
  | Two -> let st = if ((snd (snd st.doorStatus)) <> (op)) then
                      {st with battery = if penalty < 0. then 0. else penalty;}
                    else st in
      {st with doorStatus = ((fst st.doorStatus),(Two, op));}

(*****************************************************************************
******************************************************************************
**********************************INTERFACE***********************************
******************************************************************************
******************************************************************************)

(* Helper function to format [num] printed to be a double-digit. *)
let pretty_string num =
  if int_of_float num < 10 then "0" ^ (string_of_int (int_of_float num))
  else string_of_int (int_of_float num)

(* Helper function to decide whether or not to move the monster, and if yes,
 * moves the monster. Returns state after monster moved or same state if no move. *)
let move_monster monsName st =
  let randN = Random.int 20 in
  let move = (randN = 0) in
  if move then
    let monster = List.assoc monsName st.monsters in
    let oldMonsR = (List.assoc monster.currentRoomM st.map) in
    let newMonsR = random_walk oldMonsR st.map monster in
    let () = Pervasives.print_endline (monsName^" moved to "^newMonsR.nameR) in
      update_state_monster_move monster newMonsR st
  else st

(* Helper function to iterate through monsters and move/not move. *)
let rec move_monsters monsters st =
  match monsters with
  | [] -> st
  | (monsName,mons)::t -> let movedOneMonsSt = move_monster monsName st in
                           move_monsters t movedOneMonsSt

(* Helper function to check if there is a monster in a room connecting main. *)
let is_monster st =
  let mainExits = (List.assoc "main" st.map).exitsR in
  let roomOne = List.assoc (snd (List.nth mainExits 0)) st.map in
  let roomTwo = List.assoc (snd (List.nth mainExits 1)) st.map in
    if ((roomOne.monsterR <> None) && (snd (fst st.doorStatus))=true) then true
    else if ((roomTwo.monsterR <> None) && (snd (snd st.doorStatus))=true) then true
    else false

(* Helper function to check if the monster has been in the room too long. *)
let rec check_time monsters st =
  match monsters with
  | [] -> st
  | (monsName,mons)::t -> let monsTime = mons.timeToMoveM in
                          if monsTime -. st.startTime >= 2. then
                            {st with lost = true}
                          else check_time t st

(* ============================== EVAL LOOP =============================== *)

open Async.Std

let rec eval j st cmd =
  let winTime = !gameNight in
  let winLvl = !maxLevel in
  let st = update_time_and_battery st in
  let st =
    if st.lost then st else
      let newSt = move_monsters st.monsters st in
      if is_monster newSt then
        check_time newSt.monsters newSt
      else newSt
    in
  let st =
    if (st.time >= winTime && st.level = winLvl) then
      let () = Pervasives.print_endline ("You've survived all the projects. "
        ^ "Congratulations? (Quit/Restart)") in
      match cmd with
      | "quit" -> quit st
      | "restart" -> start j
      | _ -> st
    else if st.time >= winTime then
      let () = Pervasives.print_endline ("You've survived the night! "
        ^ "Next night? (Next/Quit)") in
      match cmd with
      | "next" -> st
      | "quit" -> quit st
      | _ -> st
    else if st.lost then
      let () = Pervasives.print_endline ("IT'S HERE! (Quit/Restart)") in
      match cmd with
      | "quit" -> quit st
      | "restart" -> start j
      | _ -> st
    else if st.battery <= 0. then
      let () = Pervasives.print_endline ("You're out of battery.... (Quit/Restart)") in
      match cmd with
      | "quit" -> quit st
      | "restart" -> start j
      | _ -> st
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
    else if (st.room.nameR = "main") &&
      (cmd = "close one" || cmd = "close two" || cmd = "open one" || cmd = "open two") then
        match cmd with
        | "close one" -> update_door_status st false One
        | "close two" -> update_door_status st false Two
        | "open one"  -> update_door_status st true One
        | "open two"  -> update_door_status st true Two
        | _ -> Pervasives.print_endline ("Illegal command '" ^ cmd ^ "'"); st
    else
      match cmd with
      | "main" ->  main_view st
      | "camera" -> camera_view st
      | "restart" -> start j
      | "quit" -> quit st
      | "" -> st
      | _ -> Pervasives.print_endline ("Illegal command '" ^ cmd ^ "'"); st
  in
    if cmd = "" then st else
    let hours = floor (st.time/.3600.) in
    let minutes = floor ((st.time -. (hours*.3600.))/.60.) in
      Pervasives.print_endline ("You are now in: " ^ (st.room.nameR));
      Pervasives.print_endline ("Time elapsed in hh:mm is: "
          ^ pretty_string hours ^ ":" ^ pretty_string minutes);
      Pervasives.print_endline ("Battery level is: "
          ^ (string_of_float st.battery) ^ "%\n");
  st


let stdin = Lazy.force Reader.stdin
(*
let rec go j st =
  let winTime = 28800. in
    let timed max = Clock.with_timeout (Core.Std.sec max) (Reader.read_line stdin) in
    let t = try timed 2. with | _ -> return `Timeout in
    Pervasives.print_endline "sigh";
    upon t (fun r -> (match r with
      | `Result (`Ok cmd) -> Pervasives.print_endline "cmd"; let cmd = String.lowercase_ascii cmd in
          Pervasives.print_endline cmd;
          if (cmd = "quit" || st.quit = true) then ()
          else if (cmd = "restart") then go j (start j)
          else if (cmd = "next" && st.time >= winTime) then go j (next_level j st)
          else go j (eval j st cmd)
      | `Result (`Eof) | `Timeout -> Pervasives.print_endline "none";go j (eval j st "") ) )
 *)

let rec go j st =
  let winTime = !gameNight in
  let cmd =
    if (* <no input> *) false then ""
    else (* let () = Pervasives.print_string "\n> " in *) Pervasives.read_line()
  in let cmd = String.lowercase_ascii cmd in
    if (cmd = "quit" || st.quit = true) then () else
    let newSt =
      if (cmd = "restart") then (Pervasives.print_endline "Back to Day 0"; (start j))
      else if (cmd = "next" && st.time >= winTime) then
        (Pervasives.print_endline ("Day"^(string_of_int (st.level+1)));(next_level j st))
      else (eval j st cmd)
    in go j newSt

(* [main f] is the main entry point from outside this module
 * to load a game from file [f] and start playing it. *)
let rec main fileName =
  let nest_main fileName =
    if fileName = "quit" then () else
    let j = Yojson.Basic.from_file fileName in
    let st = start j in
    Pervasives.print_endline ( "\n" ^
      "Legal commands you may use:\n" ^
      " - main: will bring you back to your main room\n" ^
      " - camera: allows you to move around\n" ^
      "    + while in camera mode you may also use: up / down / left / right\n" ^
      " - close one: closes door one\n" ^
      " - close two: clses door two\n" ^
      " - open one: opens door one\n" ^
      " - open two: opens door two\n" ^
      " - restart: restarts the game\n" ^
      " - next: starts the next level if you survive\n" ^
      " - quit: quits the game\n\n" ^
      "Day 0");
      go j st
  in try nest_main fileName with
  | Sys_error(_) | Illegal ->
    Pervasives.print_endline "\nYou must choose.";
    Pervasives.print_string  "> ";
    let input = String.lowercase_ascii (Pervasives.read_line ()) in
    let fileName =
      if input = "yes" then "map.json"
      else if input = "no" then "quit"
      else "gibberish"
    in main fileName