(* open Async.Std
   open Async_parallel_deprecated.Std
   open Music_FX *)

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
let cam_mode = ref false
let flag = ref false

(*****************************************************************************
******************************************************************************
************************************* MAIN ***********************************
******************************************************************************
******************************************************************************)

let main () =
  let _n = Sys.command "clear" in
  let fileName = Gui.menu () in
  (Engine.main (String.lowercase_ascii fileName) camera_sound flag)

let _ = main ()

(*****************************************************************************
 *****************************************************************************
 ************************************NOTES************************************
 ******************************************************************************)

(* These lines were purposely included in order to show our sound effects
 * functionality. We were unable to include this because we were unable to test
 * it effectively in virtual machine. This functionality was tested on through
 * a mac and it was able to run smoothly, but the actual game runs only on VM. *)
(* let _ = Parallel.init()
let _ = Parallel.run ~where:`Local (fun () -> return (main()))
let _ = Parallel.run ~where:`Local (fun () -> return (Music_FX.init_music()))
let _ = Parallel.run ~where:`Local (fun () -> return (Music_FX.master_song_controller
open_door close_door camera_sound cam_mode flag)) *)
