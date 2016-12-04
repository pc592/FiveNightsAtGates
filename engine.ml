
open Gui
open MUSIC_FX

(* A [GameEngine] regulates and updates the state of a FNAG game state.
 * The updated state is used by other parts to set up the graphics
 * and interface. *)


(*****************************************************************************
******************************************************************************
*********************************GLOBAL CONSTANTS*****************************
******************************************************************************
******************************************************************************)
let loopiloop = ref 0
let monsterProb = ref 50000 (*probability 1/monsterProb that the monster will move*)
let gameNight = ref 36000. (*10 hours in seconds; game time elapsed*)
let levelMaxTime = ref 30. (* 1200. *) (*20 minutes in seconds; real time elapsed*)
let monsterTime = ref 3000. (*game time seconds monster allows user before
                               killing them; 3000 is ~5 seconds. *)
let maxLevel = ref (-1) (*number of levels - 1 (levels start at 0)*)
let cPen = ref 0.001 (*battery penalty for using camera*)
let dPen = ref 0.002 (*battery penalty for opening/closing door*)

(*****************************************************************************
******************************************************************************
*************************************TYPES************************************
******************************************************************************
******************************************************************************)

type monster = {
  nameM: string;
  levelM: int;
  imageM: string;
  currentRoomM: string;
  modusOperandiM: string;
  timeToMoveM: float;
  teleportRoomM: string list
}

type door = | One | Two

type dir = | Left | Right | Up | Down | Elsewhere

type room = {
  nameR: string;
  imageR: string;
  valueR: int;
  exitsR: (dir*string) list;
  monsterR: monster option;
  lastCheckR: float
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
  lost: bool;
  printed: bool;
}

(*****************************************************************************
******************************************************************************
**************************MONSTER MOVEMENT ALGORITHMS*************************
******************************************************************************
******************************************************************************)

(*Bug where sometimes the monster may move despite being right next door. :/*)

let rec random_walk room map =
  let current = List.assoc room.nameR map in
  let exits = current.exitsR in
  let numExits = List.length exits in
  let random = Random.int numExits in
  let (dir,name) = List.nth exits random in
    if (name = "main") || ((List.assoc name map).monsterR <> None) then
      random_walk room map
    else List.assoc name map

let rec weighted_movement room map monster =
  let current = List.assoc room.nameR map in
  let exits = current.exitsR in
  if (current.valueR-1) = 0 then
    match monster.teleportRoomM with
      | [] -> failwith "Impossible."
      | h::t -> List.assoc h map
  else
    let roomsRecs = List.map (fun (dir,rName) -> (List.assoc rName map)) exits in
    let f r = (r.valueR <= current.valueR) in
    let roomsOfVal = List.filter f roomsRecs in
    let num = List.length roomsOfVal in
    let random = Random.int num in
    let (dir,name) = List.nth exits random in
      if ((List.assoc name map).monsterR <> None) then
        weighted_movement room map monster
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
let getValue room =
  room |> member "value" |> to_int
let getExits room =
  let exitsList = room |> member "exits" |> to_list in
    let makeExit exit =
      let direction exit = let e = (exit |> member "direction" |> to_string) in
        match e with
        | "left" -> Left
        | "right" -> Right
        | "up" -> Up
        | "down" -> Down
        | _ -> Pervasives.print_endline ("Non valid exit direction " ^
                                            "in this .json."); raise Illegal
      in
      let exitid exit = exit |> member "room_id" |> to_string in
      (direction exit,exitid exit)
    in List.map makeExit exitsList

(* Helper function to make room record. *)
let makeRoom room = {
  nameR = getName room;
  imageR = getImage room;
  valueR = getValue room;
  exitsR = getExits room;
  monsterR = None;
  lastCheckR = 0.;
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
let getTelepRoom monster =
  let telRooms = (monster |> member "teleportRoom" |> to_list) in
  if (List.length telRooms)=0 then
        (Pervasives.print_endline ("Teleport room must exist."); raise Illegal)
  else List.map to_string telRooms

(* Helper function to make monster record. *)
let makeMonster monster = {
  nameM = getNameM monster;
  levelM = getLevelM monster;
  imageM = getImageM monster;
  currentRoomM = getStartRoom monster;
  modusOperandiM = getModusOp monster;
  timeToMoveM = 2.*.Unix.time();
  teleportRoomM = getTelepRoom monster;
}

let insert_monster j lvl =
  let monsterList = (j |> member "monsters" |> to_list) in
  maxLevel := (List.length monsterList)-1;
  List.map makeMonster monsterList
  |> List.filter (fun monstRec -> (monstRec.levelM <= lvl))
  |> List.map (fun monstRec -> (monstRec.nameM, monstRec))

let get_map j lvl map =
  let monsters = insert_monster j lvl in
  let rec nextMonster mons map' =
    match mons with
    | [] -> map'
    | (monsName,monsRec)::t ->
        let newMap =
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
  lost = false;
  printed = false
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
****************************REQUIRED STATE UPDATE*****************************
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

(*****************************************************************************
******************************************************************************
*************************MONSTER MOVE STATE UPDATE****************************
******************************************************************************
******************************************************************************)

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
let update_monsters_monster_move newRoom mons monsters timeNow =
  List.map (fun (monsName,monsRec) ->
    if mons.nameM = monsName then
      let newMons = {mons with currentRoomM = newRoom.nameR;
                               timeToMoveM = timeNow} in
        (monsName, newMons)
    else (monsName,monsRec)) monsters

let update_state_monster_move mons newRoom st =
  let upd_room = if st.room.nameR = newRoom.nameR then newRoom else st.room in
  let mons_room = List.assoc mons.currentRoomM st.map in
  {st with monsters = update_monsters_monster_move newRoom mons st.monsters st.time;
           map = (update_map_monster_move mons_room newRoom st.map
                       {mons with currentRoomM = newRoom.nameR});
           room = upd_room;}

(*****************************************************************************
******************************************************************************
*****************************USER INPUT UPDATES*******************************
******************************************************************************
******************************************************************************)

let update_map_camera_view map newRoom time =
  let replace_room (roomName,room) =
    if (room = newRoom) then
      (roomName,{room with lastCheckR=time;})
    else (roomName,room)
  in List.map replace_room map

let shift_camera_view st dir =
  let now = Unix.time() in
  let timeMultiplier = (!gameNight)/.(!levelMaxTime) in
  let time = ((now -. st.startTime)*.timeMultiplier) in
  try
    let exit = List.assoc dir st.room.exitsR in
    let newRoom = List.assoc exit st.map in
    {st with room = {newRoom with lastCheckR=time};
             map = update_map_camera_view st.map newRoom time;}
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
  | Not_found -> Pervasives.print_endline ("You are trapped!");
    {st with lost = true;}

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

(* Helper function to decide whether or not to move the monster, and if
 * yes, moves the monster. Returns state after monster moved or same state
 * if no move. *)
let move_monster monsName st =
  let randN = Random.int !monsterProb in
  let move = (randN = 0) in
  if move then
    let monster = List.assoc monsName st.monsters in
    let oldMonsR = (List.assoc monster.currentRoomM st.map) in
    let newMonsR =
      if monster.modusOperandiM = "weighted movement" then
        weighted_movement oldMonsR st.map monster
      else (*default to random walk*)
        random_walk oldMonsR st.map
    in
    let () = Pervasives.print_endline (monsName^" moved to "^newMonsR.nameR) in
      update_state_monster_move monster newMonsR st
  else st

(* Helper function to iterate through monsters and move/not move. *)
let rec move_monsters monsters st =
  match monsters with
  | [] -> st
  | (monsName,mons)::t ->
      try (let movedOneMonsSt = move_monster monsName st in
             move_monsters t movedOneMonsSt) with
      | Not_found -> move_monsters t st

(* Helper function to check if there is a monster in a room connecting main. *)
let is_monster st =
  let mainExits = (List.assoc "main" st.map).exitsR in
  let roomOne = List.assoc (snd (List.nth mainExits 0)) st.map in
  let roomTwo = List.assoc (snd (List.nth mainExits 1)) st.map in
    ( ((roomOne.monsterR <> None) && (snd (fst st.doorStatus))) ||
      ((roomTwo.monsterR <> None) && (snd (snd st.doorStatus))) )

(* Helper function to check if the monster has been in the room too long. *)
let rec check_time monsters st =
  match monsters with
  | [] -> st
  | (monsName,mons)::t ->
      let monsTime = mons.timeToMoveM in
        if st.time -. monsTime >= !monsterTime then
          {st with lost = true}
        else check_time t st


(*****************************************************************************
**********************************EVAL LOOP***********************************
******************************************************************************)

let rec eval j st cmd =
  let winTime = !gameNight in
  let winLvl = !maxLevel in
  if (cmd = "restart") then
    let () = (Pervasives.print_endline "Back to Day 0\n") in (start j)
  else if (cmd = "next" && st.time >= winTime) then
    (Pervasives.print_endline ("\nDay "^(string_of_int (st.level+1))^"\n");
      (next_level j st))
  else
    let st = update_time_and_battery st in
    let st =
      if (st.lost || st.printed) then st else
        let newSt = move_monsters st.monsters st in
        if is_monster newSt then
          check_time newSt.monsters newSt
        else newSt
    in
    let st =
      if (st.time >= winTime && st.level = winLvl) then
        let st =
          if not st.printed then (* victory music *)
            let () = Pervasives.print_endline ("You've survived all the projects. "
              ^ "Congratulations? (Quit/Restart)\n") in {st with printed = true}
          else st in
        match cmd with
        | "quit" -> quit st
        | "restart" -> start j
        | _ -> st
      else if st.time >= winTime then
        let st =
          if not st.printed then (* Pass_level music *)
            let () = Pervasives.print_endline ("You've survived the night! "
              ^ "Next night? (Next/Quit)\n") in {st with printed = true}
          else st in
        match cmd with
        | "next" ->
            (Pervasives.print_endline ("\nDay "^(string_of_int (st.level+1))^"\n");
            (next_level j st))
        | "quit" -> quit st
        | _ -> st
      else if st.lost then
        let st =
          if not st.printed then  (* failure music *)
            let () = Pervasives.print_endline ("IT'S HERE! (Quit/Restart)") in
              {st with printed = true}
          else st in
        match cmd with
        | "quit" -> quit st
        | "restart" -> start j
        | _ -> st
      else if st.battery <= 0. then
        let st =
          if not st.printed then (* failure music *)
            let () = Pervasives.print_endline ("You're out of battery.... "
              ^ "(Quit/Restart)") in
              {st with lost = true; printed = true}
          else st in
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
        let newView =
          try shift_camera_view st dir with
            | Illegal -> Pervasives.print_endline
                           ("Illegal command '" ^cmd ^ "'"); st
        in
        let newRoom = newView.room in
          if (newRoom.monsterR <> None) then
            match newRoom.monsterR with
            | Some mons ->
                Pervasives.print_endline (mons.nameM ^ " present!"); newView
            | None -> newView
          else newView
      else if (st.room.nameR = "main") && (cmd = "one" || cmd = "two") then
          let truCmd =
            match cmd with
            | "one" -> if (snd (fst st.doorStatus)) then "close one" else "open one"
            | "two" -> if (snd (snd st.doorStatus)) then "close two" else "open two"
            | _ -> failwith "how did you even get here."; raise Illegal
          in
            match truCmd with
            | "close one" -> Pervasives.print_endline "Door one closed.";
                               update_door_status st false One
            | "close two" -> Pervasives.print_endline "Door two closed.";
                               update_door_status st false Two
            | "open one"  -> Pervasives.print_endline "Door one opened.";
                               update_door_status st true One
            | "open two"  -> Pervasives.print_endline "Door two opened.";
                               update_door_status st true Two
            | _ -> Pervasives.print_endline ("Illegal command '" ^ cmd ^ "'"); st
      else
        match cmd with
        | "camera" -> if st.room.nameR = "main" then
                        camera_view st
                      else main_view st
        | "quit" -> quit st
        | "" -> st
        | _ -> Pervasives.print_endline ("Illegal command '" ^ cmd ^ "'"); st
    in
      if (cmd = "" || st.printed) then st else
        let () = Pervasives.print_endline ("You are now in: " ^ (st.room.nameR)) in
        let () = if st.room.nameR = "main" then
                   let hours = floor (st.time/.3600.) in
                   let minutes = floor ((st.time -. (hours*.3600.))/.60.) in
                     Pervasives.print_endline ("Time elapsed in hh:mm is: "
                         ^ pretty_string hours ^ ":" ^ pretty_string minutes);
                     Pervasives.print_endline ("Battery level is: "
                        ^ (string_of_float st.battery) ^ "%");
                   else ();
        in
        Pervasives.print_string "\n"; st

let update screen hours st=
  if ((!loopiloop) = 1000) then
    let () = loopiloop := 0 in
    Gui.update_disp "" "main.jpg" screen hours (string_of_float st.battery)
  else ()

let rec go j st screen=
  (* updates the image after set amount of recursive calls*)
  loopiloop := !loopiloop + 1;
  let cmd_opt = Gui.poll_event () in
  let cmd = (match cmd_opt with |None -> "" |Some x -> Gui.read_string x) in
  let cmd = String.lowercase_ascii cmd in
    if (cmd = "quit" || st.quit = true) then () else
    let new_state = (eval j st cmd) in
    let hours = (string_of_int (int_of_float (floor (st.time/.3600.)))) in
    update screen hours st;
    go j new_state screen


(*****************************************************************************
******************************************************************************
*********************************START GAME***********************************
******************************************************************************
******************************************************************************)

let intro =(
  "\n\n\n\n\n\n" ^
  "Introduction:\n" ^
  "It's late at night and you have CS3110 assignments to do, due tomorrow!.\n" ^
  "But there's monsters lurking around every corner....\n" ^
  "\n" ^
  "You must keep track of the monsters roaming around Gates. If they get\n" ^
  "into the main room, they'll ruin your project and you'll fail! Luckily,\n" ^
  "you have access to the security cameras placed in each room.\n"^
  "\n" ^
  "Doubly lucky, the [main] room you've chosen to be in is well fortified--\n" ^
  "it has only two doors, which you may open or close using your laptop to\n" ^
  "keep the monsters out.\n" ^
  "\n" ^
  "The catch? Viewing the security cameras increases the drainage of your\n" ^
  "battery, as does keeping the doors closed. Opening or closing the doors\n" ^
  "also takes battery. Additionally, your laptop is only able to either view\n" ^
  "the security camera footage or handle the doors, it cannot do both.\n" ^
  "Of course, if you run out of battery, you will be unable to finish the\n" ^
  "project, and you will fail.\n" ^
  "\n" ^
  "Can you finish all the projects and survive every night?\n" ^
  "\n\n")

(* The gameplay instructions for what commands are valid. *)
let commands =
      "\n\n\n\n\n" ^
      "Legal commands you may use:\n" ^
      " - [return]: restarts the game\n" ^
      " - [space]: will bring you in and out of camera mode\n" ^
      "    + while in camera mode you may also use:\n" ^
      "       [w]: up\n" ^
      "       [a]: left\n" ^
      "       [s]: down\n" ^
      "       [d]: right\n" ^
      " - [u]: opens/closes door one\n" ^
      " - [i]: opens/closes door two\n" ^
      " - [n]: starts the next level if you survive\n" ^
      " - [esc]: quits the game\n\n"

(* [main f] is the main entry point from outside this module
 * to load a game from file [f] and start playing it. *)
let rec main fileNameIn =
  let nest_main fileName =
    if fileName = "quit" then () else
    let j = Yojson.Basic.from_file fileName in
    let st = start j in
    let _o = Sys.command "clear" in
    Pervasives.print_endline commands;
    Pervasives.print_endline  "Press [enter] to continue.";
    let _n = Pervasives.read_line () in
    let _p = Sys.command "clear" in
    let () = Pervasives.print_endline ("\n\n\n\n\n") in
    Pervasives.print_endline ("Day 0\n");
    (* Music_FX.init_music (); *) (* need to play background music without stopping everything *)
    Gui.collect_commands ();
    let screen = Gui.create_disp () in
    go j st screen
  in try nest_main fileNameIn with
  | Sys_error(_) ->
    Pervasives.print_endline "\nYou must choose.";
    Pervasives.print_string  "> ";
    let input = String.lowercase_ascii (Pervasives.read_line ()) in
    let fileName =
      if input = "yes" || input = "y" then
        let _m = Sys.command "clear" in
        let () = (Printf.printf "%s" intro) in
          Pervasives.print_string "Press [enter] to continue.";
        let _n = Pervasives.read_line () in "map.json"
      else if input = "no" || input = "n" || input = "quit" then "quit"
      else "gibberish"
    in main fileName
  | Illegal -> Pervasives.print_endline "\nSomething is wrong with the .json"