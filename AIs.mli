(* [AIs] houses all the algorithms for monster movement. Any given AI takes in
 * a current room and returns the next room to move to. *)
module type AI = sig

(* [currentRoom] is the details of the current room. *)
type currentRoom = room

(* [nextRoom] is the details of the next room. *)
type nextRoom = room

(* [random_goal currentRoom map] randomly chooses a room and makes its way
 * there as directly as possible before pausing for some set amount of time.
 * requires:
 *  - [currentRoom] is the details of the current room
 *  - [map] is the map of the game for the AI to traverse *)
val random_goal : currentRoom -> map -> nextRoom


(* [weighted_movement currentRoom map] moves along higher weighted edges/paths,
 * in which paths towards the main room are higher weighted than paths away. If
 * next to main room and called, next room is random and algorithm is restarted.
 * requires:
 *  - [currentRoom] is the details of the current room
 *  - [map] is the map of the game for the AI to traverse *)
val weighted_movement : currentRoom -> map -> nextRoom

(* [ranom_walk currentRoom map] is a random walk implementation.
 * requires:
 *  - [currentRoom] is the details of the current room
 *  - [map] is the map of the game for the AI to traverse *)
val random_walk : currentRoom -> map -> nextRoom

end