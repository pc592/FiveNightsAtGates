(* Author: CS 3110 course staff *)
(* But heavily modified. *)

let () =
  ANSITerminal.(print_string [red]
    "\n\nDo you want to play a game? (Yes/No)\n");
  Pervasives.print_string  "> ";
  let input = String.lowercase_ascii (Pervasives.read_line ()) in
  let fileName =
    if input = "yes" then "map.json"
    else if input = "no" || input = "quit" then "quit"
    else "gibberish"
  in
  Engine.main (String.lowercase_ascii fileName)