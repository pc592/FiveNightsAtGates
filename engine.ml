type state = {
  current_room: string; 
  score: int; 
  inv: string list; 
  turns: int; 
  visited: string list;
  locations: (string * string) list;
  (* [(room_id, [(direction, exit)])] *)
  map: (string * ((string * string) list)) list;
  (* [(room_id, (description, points))] *)
  rooms_info: (string * (string * int)) list; 
  (* [(item_id, (description, points))] *)
  items_info: (string * (string * int)) list; 
  (* [(item_id, room_id)] *)
  treasure_info: (string * string) list;
}

(* [Illegal] is raised by [do'] to indicate that a command is illegal;
 * see the documentation of [do'] below. *)
exception Illegal

(*****************************************************************************
******************************************************************************
*******************************START GAME/LEVEL*******************************
******************************************************************************
******************************************************************************)
(* 
  store item info as (item_id, (description, points)) in a list
 *)
let init_item_info j =
  let open Yojson.Basic.Util in
  let items = j |> member "items" |> to_list in
  List.map 
    (fun subj -> 
      (member "id" subj |> to_string, 
      (member "description" subj |> to_string, member "points" subj |> to_int))
    )
    items

let get_item_point i st = let (_, points) = List.assoc i st.items_info in points

(* 
  store room info as (room_id, (description, points)) in a list
 *)
let init_room_info j =
  let open Yojson.Basic.Util in
  let rooms = j |> member "rooms" |> to_list in
  List.map 
    (fun subj -> 
      (member "id" subj |> to_string, 
      (member "description" subj |> to_string, member "points" subj |> to_int)))
    rooms

let get_room_point r st = let (_, points) = List.assoc r st.rooms_info in points

(* 
  store (item_id, room_id) in a list
 *)
let init_treasure_info j =
  let open Yojson.Basic.Util in
  let rooms = j |> member "rooms" |> to_list in
  let rec helper l = 
    match l with
    | [] -> []
    | r::rs -> 
      List.map 
        (fun item -> (item, member "id" r |> to_string)) 
        (member "treasure" r |> to_list |> filter_string) 
      @ (helper rs)
  in
  helper rooms

(* 
  store (room_id, [(direction, exit)]) in a list - uses adjacency list approach
 *)
let init_map j =
  let open Yojson.Basic.Util in
  let rooms = j |> member "rooms" |> to_list in
  let rec helper l = 
    match l with
    | [] -> []
    | r::rs -> 
      (member "id" r |> to_string, 
      List.map 
        (fun exit -> (member "direction" exit |> to_string, 
                      member "room_id" exit |> to_string)) 
        (member "exits" r |> to_list))
      :: 
      (helper rs)
  in
  helper rooms

(* get score from items being in their treasure room *)
let init_treasure_score st =
  List.fold_left 
    (fun acc (item, loc) -> 
      match List.assoc item st.treasure_info with
      | exception Not_found -> 0 
      | treasure_loc -> 
        acc + if treasure_loc = loc 
              then get_item_point item st 
              else 0
    ) 
    st.score st.locations


(* [init_state j] is the initial state of the game as
 * determined by JSON object [j] *)
let init_state j =
  let open Yojson.Basic.Util in
  let start_room = j |> member "start_room" |> to_string in
  let inv = j |> member "start_inv" |> to_list |> filter_string in
  (* let pages = j |> member "pages" |> to_int in *)
  let locations = j |> member "start_locations" |> to_list in
  let locations = List.map 
    (fun subj -> (member "item" subj |> to_string, 
                  member "room" subj |> to_string))
    locations in
  let st = 
        {current_room=start_room; 
        score=0; 
        inv=inv; 
        turns=0; 
        visited=[start_room]; 
        locations=locations; 
        map=init_map j; 
        rooms_info=init_room_info j; 
        treasure_info=init_treasure_info j;
        items_info=init_item_info j
        }
  in
  let score = get_room_point start_room st + init_treasure_score st
  in {st with score=score}



(*****************************************************************************
******************************************************************************
**************************MONSTER MOVEMENT ALGORITHMS*************************
******************************************************************************
******************************************************************************)


(*****************************************************************************
******************************************************************************
**************************INTERFACE(GUI should use this)*************************
******************************************************************************
******************************************************************************)
(* this section should include NON-GAME SCREENS, REQUIRED STTAE UPDATE, INGAME UPDATE *)

(* [max_score s] is the maximum score for the adventure whose current
 * state is represented by [s]. *)
let max_score s =
  let f acc (_,(_,points)) = acc+points in
  let room_score = List.fold_left f 0 s.rooms_info in
  let item_score = List.fold_left f 0 s.items_info in
  room_score + item_score

(* [score s] is the player's current score. *)
let score s =
  s.score

(* [turns s] is the number of turns the player has taken so far. *)
let turns s =
  s.turns

(* [current_room_id s] is the id of the room in which the adventurer
 * currently is. *)
let current_room_id s =
  s.current_room

(* [inv s] is the list of item id's in the adventurer's current inventory.
 * No item may appear more than once in the list.  Order is irrelevant. *)
let inv s =
  s.inv

(* [visited s] is the list of id's of rooms the adventurer has visited.
 * No room may appear more than once in the list.  Order is irrelevant. *)
let visited s =
  s.visited

(* [locations s] is an association list mapping item id's to the
 * id of the room in which they are currently located.  Items
 * in the adventurer's inventory are not located in any room.
 * No item may appear more than once in the list.  The relative order
 * of list elements is irrelevant, but the order of pair components
 * is essential:  it must be [(item id, room id)]. *)
let locations s =
  s.locations


(* ================ helpers for do' =========================================*)
let go d st = 
  (* update current room *)
  match List.assoc d (List.assoc st.current_room st.map) with
  | exception Not_found -> raise Illegal
  | exit -> 
    let st = {st with current_room=exit; turns = st.turns+1} in
    (* update turns, visited and score *)
    if List.mem exit st.visited then st 
    else {st with 
          visited = exit::st.visited; 
          score = st.score+get_room_point exit st; }
            
let take o st = 
  match List.assoc o st.locations with
  | exception Not_found -> raise Illegal
  | loc_room -> if loc_room <> st.current_room then raise Illegal else
      let locations = List.remove_assoc o st.locations in
      let inv = if List.exists (fun x -> x=o) st.inv then st.inv 
                else o::st.inv in
      let treasure_room = List.assoc o st.treasure_info in
      let score = if treasure_room = st.current_room
                  then st.score - get_item_point o st 
                  else st.score
      in 
      {st with locations = locations; score = score; inv=inv; turns=st.turns+1}

let drop o st = 
  if List.exists (fun x -> x=o) st.inv then
    match List.assoc o st.treasure_info with
    | exception Not_found -> raise Illegal
    | treasure_room -> 
        let locations = (o, st.current_room)::st.locations in
        let inv = List.filter (fun x -> x <> o) st.inv in
        let score = if treasure_room = st.current_room
                    then st.score + get_item_point o st 
                    else st.score
        in
    {st with locations = locations; score = score; inv=inv; turns=st.turns+1}
  else raise Illegal


(* [do' c st] is [st'] if it is possible to do command [c] in
 * state [st] and the resulting new state would be [st'].  The
 * function name [do'] is used because [do] is a reserved keyword.
 *   - The "go" (and its shortcuts), "take" and "drop" commands
 *     either result in a new state, or are not possible because
 *     their object is not valid in state [st] hence they raise [Illegal].
 *       + the object of "go" is valid if it is a direction by which
 *         the current room may be exited
 *       + the object of "take" is valid if it is an item in the
 *         current room
 *       + the object of "drop" is valid if it is an item in the
 *         current inventory
 *       + if no object is provided (i.e., the command is simply
 *         the bare word "go", "take", or "drop") the behavior
 *         is unspecified
 *   - The "quit", "look", "inventory", "inv", "score", and "turns"
 *     commands are always possible and leave the state unchanged.
 *   - The behavior of [do'] is unspecified if the command is
 *     not one of the commands given in the assignment writeup.
 * The underspecification above is in order to enable karma
 * implementations that provide new commands. *)
let do' c st =
  let open Str in
  if c="quit" || c="look" || c="inventory" || c="inv" || c="score" || c="turns" 
  then st 
  else
  (* Not shorthand. split into VERB OBJECT *)
  match bounded_split (regexp " ") c 2 with 
    | v::o::[] -> if v="go" then go o st 
      else if v="take" then take o st
      else if v="drop" then drop o st
      else st (* unspecified behavior = return unchanged *)
    | d::[] -> if (* check direction shorthand *)
        match List.assoc d (List.assoc st.current_room st.map) with
        | exception Not_found ->  false
        | _ -> true
        then go d st 
        else st (* unspecified behavior = return unchanged *)
    | _ -> st (* unspecified behavior = return unchanged *)



(* ================= EVAL LOOP ============================================ *)
let show_room r st = 
  let (desc, _) = List.assoc st.current_room st.rooms_info in desc
let show_inv st = 
  List.fold_left (fun acc x -> if acc = "" then x else x ^ "\n" ^ acc) "" st.inv


(* [main f] is the main entry point from outside this module
 * to load a game from file [f] and start playing it
 *)
let main file_name =
  let rec eval st = 
    (* get cmd *)
    let () = print_string "> " in
    let cmd = read_line () in 
    let cmd = String.lowercase_ascii cmd in
      if cmd = "quit" then () 
      else if cmd = "look" then 
        let () = print_endline (show_room st.current_room st) in
        eval st
      else if cmd = "inventory" || cmd = "inv" then 
        let () = print_endline (show_inv st) in
        eval st
      else if cmd = "score" then 
        let () = print_endline (string_of_int (score st)) in
        eval st
      else if cmd = "turns" then 
        let () = print_endline (string_of_int (turns st))in
        eval st
      else 
        let st = try do' cmd st with Illegal -> 
                let () = print_string "Illegal command!" in st 
        in
        let () = print_string "You did: " in
        let () = print_endline cmd in
        let () = print_endline (show_room st.current_room st) in
        eval st
  in
  let st = Yojson.Basic.from_file file_name |> init_state in
  (* display room *)
  let () = print_endline (show_room st.current_room st) in
  eval st



