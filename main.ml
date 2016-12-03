(* Author: CS 3110 course staff *)
(* But heavily modified. *)

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

let () =
  let _n = Sys.command "clear" in
    ANSITerminal.(print_string [red]
      ("\n\n\n\n\n\n" ^
          "Welcome to Gates Hall.\n" ^
          "Do you want to play a game? (Yes/No)\n"));
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
  in
  Engine.main (String.lowercase_ascii fileName)