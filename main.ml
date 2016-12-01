(* Author: CS 3110 course staff *)

(* IMPORTANT NOTE:
 * You should not need to modify this file, though perhaps for karma
 * reasons you might choose to do so.  The reason this file is factored
 * out from [game.ml] is for testing purposes:  if we're going to unit
 * test the [Game] module, it can't itself invoke its [main] function;
 * if it did, the game would try to launch and would interfere with OUnit.
 *)

let () =
  ANSITerminal.(print_string [red]
    "\n\nDo you want to play a game? (Yes/No)\n");
  Pervasives.print_string  "> ";
  let input = String.lowercase_ascii (Pervasives.read_line ()) in
  let fileName =
    if input = "yes" then "map.json"
    else if input = "no" then "quit"
    else "gibberish"
  in
  Engine.main (String.lowercase_ascii fileName)