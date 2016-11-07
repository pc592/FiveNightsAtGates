(* An [GameEngine] regulates the state of a FNAG game state
* The state can be used by other parts to set up the graphics
* and interface. *)
module type GameEngine = sig

(*A type that stores game relevant information about a monster
* Stores:
  Name: The identifier for the monster
  Image: Image location for the monster
  startingRoom: Where the monster will first appear
  modusOperandi: Details on how to determine where the monster will move
  next and how long it will spend in one room
  timeToMove: How long before the monster moves to the next room.
* *)
type monster

(*A type that stores game relevant information about the map
  Stores:
  Names: The names of the rooms
  images: The images stored for the locations
  exits: The exits associated with each room
  monster: type Monster
* *)

type map
(*A type that stores everything about the game.
* Stores:
  Monsters: stores multiples of type Monster
  Map: type Map
  Time [int]: the time left before the end of the level
  Battery [int]: How much energy in the battery before the game ends
  next and how long it will spend in one room
  timeToMove [int]: How long before the monster moves to the next room.
  DoorStatus [bool * bool] - a tuple controlling the status of the two doors
  that lead into the main room
  view [string]: The current view the camera is taking
  Level [int]: The current level (night) the character is in
* *)
type state


  val init_state : int -> state

  val insert_monster : monster -> state -> state

  val update_time : state -> state

  val update_monster_location : state -> state

  val update_door_status : bool -> string -> state

  val update_battery_power : int -> state -> state


end



