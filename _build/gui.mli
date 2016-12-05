
(* A [gui] opens screens and updates the graphics accordingly. Along with
 * tracking for user keyboard inputs. Provides the functions for the user to
 * interface with the game graphics and interface. *)

(*[create_disp ()] initializes the screen for the game. Hard coded to be
  800*600 Pixels*)
val create_disp : unit -> Sdlvideo.surface

(* [update_disp oldIm newIm window] takes in the name of the room
[roomname], the image name [new_image], initialized screen [screen]
an int representing the hours [hours], and  battery
doors *)
val update_disp : string -> string -> Sdlvideo.surface -> string -> string -> bool * bool -> unit

(*[poll_event ()] Initializes the functions to gather keyboard input from the
user. returns event of type [Sdlevent.event option]*)
val poll_event : unit -> Sdlevent.event option

(* [collect_commands ()] Launches the Sdlevent function pump to collect user
keyboard *)
val collect_commands : unit -> unit

(*[menu ()] Begins the menu loop. It ends with producing the user keyboard
requests.*)
val menu : unit -> string


(*[interim ()] Provides the project end and final screens, outputs the user
pressed command.
*)
val interim : int -> Sdlvideo.surface -> string

(*[kill_screen screen monster] updates the screen with the death screen from
the monster and then presents the game over window.*)
val kill_screen : Sdlvideo.surface -> string -> string

val read_string : ?default:string -> Sdlevent.event -> string

