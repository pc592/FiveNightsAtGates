open Async.Std
open Async_parallel_deprecated.Std
open MUSIC_FX
open Gui
(* Author: CS 3110 course staff *)
(* But heavily modified. *)

(*****************************************************************************
******************************************************************************
*********************************GLOBAL CONSTANTS*****************************
******************************************************************************
******************************************************************************)
let camera_sound = ref false
let open_door = ref false
let close_door = ref false
let camera_mode = ref false
let flag = ref false

(*****************************************************************************
******************************************************************************
************************************* MAIN ***********************************
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


let main () =
  let _n = Sys.command "clear" in
  let fileName = Gui.menu () in
  (Engine.main (String.lowercase_ascii fileName) camera_sound flag)

(* let _ = Parallel.init()
let _ = Parallel.run ~where:`Local (fun y -> return (main()))
let _ = Parallel.run ~where:`Local (fun x -> (return (Music_FX.init_music ())))
let _ = Parallel.run ~where: `Local (fun z -> return (Music_FX.update_sounds open_door close_door camera_sound camera_mode))
 *)

let _ =  main()

