(*I'm a f-boi, I'm sorry*)

module type GameEngine = sig
type player
type monster
type state


  val init_state : int -> state

  val insert_monster : monster -> state -> state

  val update_time : state -> state

  val update_monster_location : state -> state

  val update_door_status : bool -> string -> state

  val update_battery_power : int -> state -> state


end



