(* [AIs] houses all the algorithms for monster movement. Any given AI takes in
 * a current room and returns the next room to move to. *)
module type AI = sig

(* [random_goal room map] returns the next room using random goal oriented
 * traversal. Random goal oriented traversal randomly chooses a room and moves
 * there as directly as possible, briefly pausing in each room. When goal is
 * reached, pauses for a longer amount of time. Chooses a new random goal when
 * goal is reached.
 * requires:
 *  - [room] is the details of the current room
 *  - [map] is the map of the game for the AI to traverse *)
val random_goal : room -> map -> room


(* [weighted_movement room map] returns the next room using weighted
 * movement traversal. Weighted movement traversal weights each path between
 * rooms as a 2-way edge and favors moving along higher weighted edges. In
 * general, paths leaing towards the main room are higher weighted than paths
 * leading away. If the current room is next to the main room and a new room
 * must be selected, the new room is randomly selected and reached before
 * algorithm is restarted.
 * requires:
 *  - [room] is the details of the current room
 *  - [map] is the map of the game for the AI to traverse *)
val weighted_movement : room -> map -> room

(* [ranom_walk room map] returns the next room using random walk.
 * requires:
 *  - [room] is the details of the current room
 *  - [map] is the map of the game for the AI to traverse *)
val random_walk : room -> map -> room

end