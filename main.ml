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
    "\n\nWelcome to the 3110 Text Adventure Game engine.\n");
  Pervasives.print_endline "Please enter the name of the game file you want to load.\n";
  Pervasives.print_string  "> ";
  let file_name = Pervasives.read_line () in
  Engine.main file_name