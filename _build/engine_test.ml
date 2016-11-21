open OUnit2
open Engine

let j = Yojson.Basic.from_file "test.json"

(* tests json parsing and initial state *)
let json_tests = 
[
	(* helper tests *)
  "start item info" >:: (fun _ -> assert_equal [
  	("black hat", ("a black fedora", 100));
  	("white hat", ("a white panama", 1000)); 
  	("red hat", ("a red fez", 10000))] 
  	(j |> init_item_info));

  (* "start treasure" >:: (fun _ -> assert_equal [
  	("white hat", "room1"); 
  	("red hat", "room1"); 
  	("black hat", "room2")]   (j |> init_treasure_info));

  "start room info" >:: (fun _ -> assert_equal [
  	("room1", ("This is Room 1.  There is an exit to the north.\nYou should drop the white hat here.",1));
  	("room2", ("This is Room 2.  There is an exit to the south.\nYou should drop the black hat here.",  10))
  	] 
  	(j |> init_room_info));

  "start map" >:: (fun _ -> assert_equal [
  	("room1", [("north", "room2")]); 
  	("room2", [("south", "room1")])
  	] 
  	(j |> init_map));

  "start room" >:: (fun _ -> assert_equal "room1" 
  	(j |> init_state |> current_room_id));

  "start inv" >:: (fun _ -> assert_equal ["white hat"] 
  	(j |> init_state |> inv));

  "start location" >:: (fun _ -> assert_equal 
  	[("black hat", "room1"); ("red hat", "room1")] 
  	(j |> init_state |> locations));

  (* main signature tests *)
  "max" >:: (fun _ -> assert_equal 11111 (j |> init_state |> max_score));

  "init_state" >:: (fun _ -> assert_equal  
		{current_room = "room1"; score = 10001;
		 inv = ["white hat"]; turns = 0;                         
		 visited = ["room1"];                                                                      
		 locations = [("black hat", "room1"); ("red hat", "room1")];
		 map = [("room1", [("north", "room2")]); ("room2", [("south", "room1")])];
		 rooms_info =
		  [("room1",
		    ("This is Room 1.  There is an exit to the north.\nYou should drop the white hat here.",
		     1));
		   ("room2",
		    ("This is Room 2.  There is an exit to the south.\nYou should drop the black hat here.",
		     10))];
		 items_info =
		  [("black hat", ("a black fedora", 100));
		   ("white hat", ("a white panama", 1000)); ("red hat", ("a red fez", 10000))];
		 treasure_info =
		  [("white hat", "room1"); ("red hat", "room1"); ("black hat", "room2")]}
   (j |> init_state)); *)

]

(* tests command line eval loop *)
let print_tests = 
[
  (* "room description" >:: (fun _ -> assert_equal 
  	"This is Room 1.  There is an exit to the north.\nYou should drop the white hat here." 
  	(show_room "room1" (init_state j)) ); *)
]


let do_tests =
[
	(* "go north" >:: (fun _ -> assert_equal  
		{current_room = "room2"; score = 10011;
		 inv = ["white hat"]; turns = 1;                         
		 visited = ["room2";"room1"];                                                                      
		 locations = [("black hat", "room1"); ("red hat", "room1")];
		 map = [("room1", [("north", "room2")]); ("room2", [("south", "room1")])];
		 rooms_info =
		  [("room1",
		    ("This is Room 1.  There is an exit to the north.\nYou should drop the white hat here.",
		     1));
		   ("room2",
		    ("This is Room 2.  There is an exit to the south.\nYou should drop the black hat here.",
		     10))];
		 items_info =
		  [("black hat", ("a black fedora", 100));
		   ("white hat", ("a white panama", 1000)); ("red hat", ("a red fez", 10000))];
		 treasure_info =
		  [("white hat", "room1"); ("red hat", "room1"); ("black hat", "room2")]}
	(go "north" (init_state j))
	);

	"go north then south" >:: (fun _ -> assert_equal  
		{current_room = "room1"; score = 10011;
		 inv = ["white hat"]; turns = 2;                         
		 visited = ["room2";"room1"];                                                                      
		 locations = [("black hat", "room1"); ("red hat", "room1")];
		 map = [("room1", [("north", "room2")]); ("room2", [("south", "room1")])];
		 rooms_info =
		  [("room1",
		    ("This is Room 1.  There is an exit to the north.\nYou should drop the white hat here.",
		     1));
		   ("room2",
		    ("This is Room 2.  There is an exit to the south.\nYou should drop the black hat here.",
		     10))];
		 items_info =
		  [("black hat", ("a black fedora", 100));
		   ("white hat", ("a white panama", 1000)); ("red hat", ("a red fez", 10000))];
		 treasure_info =
		  [("white hat", "room1"); ("red hat", "room1"); ("black hat", "room2")]}
	(go "south" (go "north" (init_state j)))
	);

	"drop white hat" >:: (fun _ -> assert_equal  
		{current_room = "room1"; score = 11001;
		 inv = []; turns = 1;                         
		 visited = ["room1"];                                                                      
		 locations = [("white hat", "room1"); ("black hat", "room1"); ("red hat", "room1")];
		 map = [("room1", [("north", "room2")]); ("room2", [("south", "room1")])];
		 rooms_info =
		  [("room1",
		    ("This is Room 1.  There is an exit to the north.\nYou should drop the white hat here.",
		     1));
		   ("room2",
		    ("This is Room 2.  There is an exit to the south.\nYou should drop the black hat here.",
		     10))];
		 items_info =
		  [("black hat", ("a black fedora", 100));
		   ("white hat", ("a white panama", 1000)); ("red hat", ("a red fez", 10000))];
		 treasure_info =
		  [("white hat", "room1"); ("red hat", "room1"); ("black hat", "room2")]}
	(drop "white hat" (init_state j))
	);

	"take red hat" >:: (fun _ -> assert_equal  
		{current_room = "room1"; score = 1;
		 inv = ["red hat"; "white hat"]; turns = 1;                         
		 visited = ["room1"];                                                                      
		 locations = [("black hat", "room1")];
		 map = [("room1", [("north", "room2")]); ("room2", [("south", "room1")])];
		 rooms_info =
		  [("room1",
		    ("This is Room 1.  There is an exit to the north.\nYou should drop the white hat here.",
		     1));
		   ("room2",
		    ("This is Room 2.  There is an exit to the south.\nYou should drop the black hat here.",
		     10))];
		 items_info =
		  [("black hat", ("a black fedora", 100));
		   ("white hat", ("a white panama", 1000)); ("red hat", ("a red fez", 10000))];
		 treasure_info =
		  [("white hat", "room1"); ("red hat", "room1"); ("black hat", "room2")]}
	(take "red hat" (init_state j))
	);

	"take red hat drop white hat" >:: (fun _ -> assert_equal  
		{current_room = "room1"; score = 1001;
		 inv = ["red hat"]; turns = 2;                         
		 visited = ["room1"];                                                                      
		 locations = [("white hat", "room1");("black hat", "room1")];
		 map = [("room1", [("north", "room2")]); ("room2", [("south", "room1")])];
		 rooms_info =
		  [("room1",
		    ("This is Room 1.  There is an exit to the north.\nYou should drop the white hat here.",
		     1));
		   ("room2",
		    ("This is Room 2.  There is an exit to the south.\nYou should drop the black hat here.",
		     10))];
		 items_info =
		  [("black hat", ("a black fedora", 100));
		   ("white hat", ("a white panama", 1000)); ("red hat", ("a red fez", 10000))];
		 treasure_info =
		  [("white hat", "room1"); ("red hat", "room1"); ("black hat", "room2")]}
	(drop "white hat" (take "red hat" (init_state j)))
	);

	"do is equivalent to calling take/drop" >:: (fun _ -> assert_equal  
		{current_room = "room1"; score = 1001;
		 inv = ["red hat"]; turns = 2;                         
		 visited = ["room1"];                                                                      
		 locations = [("white hat", "room1");("black hat", "room1")];
		 map = [("room1", [("north", "room2")]); ("room2", [("south", "room1")])];
		 rooms_info =
		  [("room1",
		    ("This is Room 1.  There is an exit to the north.\nYou should drop the white hat here.",
		     1));
		   ("room2",
		    ("This is Room 2.  There is an exit to the south.\nYou should drop the black hat here.",
		     10))];
		 items_info =
		  [("black hat", ("a black fedora", 100));
		   ("white hat", ("a white panama", 1000)); ("red hat", ("a red fez", 10000))];
		 treasure_info =
		  [("white hat", "room1"); ("red hat", "room1"); ("black hat", "room2")]}
	(do' "drop white hat" (do' "take red hat" (init_state j)))
	);

	"take illegal obj" >:: (fun _ -> assert_raises Illegal 
		(fun () -> take "illegal" (init_state j)) );

	"drop illegal obj" >:: (fun _ -> assert_raises Illegal 
		(fun () -> drop "illegal" (init_state j)) );

	"go illegal direction" >:: (fun _ -> assert_raises Illegal 
		(fun () -> go "illegal" (init_state j)) );

	"cmds like quit is allowed and doesn't change state" >:: (fun _ -> assert_equal  
		{current_room = "room1"; score = 10001;
		 inv = ["white hat"]; turns = 0;                         
		 visited = ["room1"];                                                                      
		 locations = [("black hat", "room1"); ("red hat", "room1")];
		 map = [("room1", [("north", "room2")]); ("room2", [("south", "room1")])];
		 rooms_info =
		  [("room1",
		    ("This is Room 1.  There is an exit to the north.\nYou should drop the white hat here.",
		     1));
		   ("room2",
		    ("This is Room 2.  There is an exit to the south.\nYou should drop the black hat here.",
		     10))];
		 items_info =
		  [("black hat", ("a black fedora", 100));
		   ("white hat", ("a white panama", 1000)); ("red hat", ("a red fez", 10000))];
		 treasure_info =
		  [("white hat", "room1"); ("red hat", "room1"); ("black hat", "room2")]}
	(do' "quit" (init_state j))) *)
]

let suite =
  "Adventure test suite"
  >::: json_tests @ print_tests @ do_tests

let _ = run_test_tt_main suite
