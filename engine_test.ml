open OUnit2
open Engine

let j = Yojson.Basic.from_file "test.json"

let map = [("main",                                                                         {nameR = "main"; imageR = "main"; valueR = 0;                                 
   exitsR = [(Left, "Gimme!"); (Right, "kitchen")]; monsterR = None;
   lastCheckR = 0.});
	 ("kitchen",
	  {nameR = "kitchen"; imageR = "kitchen"; valueR = 1;
	   exitsR = [(Left, "main"); (Down, "hallway"); (Up, "Gimme!")];
	   monsterR = None; lastCheckR = 0.});
	 ("hallway",
	  {nameR = "hallway"; imageR = "hallway"; valueR = 2;
	   exitsR = [(Up, "kitchen"); (Left, "CSOffices"); (Down, "lectureHall")];
	   monsterR = None; lastCheckR = 0.});
	 ("lectureHall",
	  {nameR = "lectureHall"; imageR = "lectureHall"; valueR = 3;
	   exitsR = [(Up, "hallway"); (Down, "CSOffices"); (Left, "copyRoom")];
	   monsterR = None; lastCheckR = 0.});
	 ("CSOffices",
	  {nameR = "CSOffices"; imageR = "CSOffices"; valueR = 3;
	   exitsR = [(Right, "lectureHall"); (Up, "hallway"); (Left, "studySpaces")];
	   monsterR = None; lastCheckR = 0.});
	 ("studySpaces",
	  {nameR = "studySpaces"; imageR = "studySpaces"; valueR = 4;
	   exitsR = [(Right, "CSOffices"); (Left, "CSUGLab"); (Up, "gradLounge")];
	   monsterR = None; lastCheckR = 0.});
	 ("CSUGLab",
	  {nameR = "CSUGLab"; imageR = "CSUGLab"; valueR = 3;
	   exitsR = [(Up, "profOffices"); (Down, "studySpaces"); (Right, "copyRoom")];
	   monsterR = None; lastCheckR = 0.});
	 ("copyRoom",
	  {nameR = "copyRoom"; imageR = "copyRoom"; valueR = 4;
	   exitsR =
	    [(Right, "lectureHall"); (Up, "gradLounge"); (Left, "CSUGLab");
	     (Down, "ClarksonOffice")];
	   monsterR = None; lastCheckR = 0.});
	 ("ClarksonOffice",
	  {nameR = "ClarksonOffice"; imageR = "ClarksonOffice"; valueR = 5;
	   exitsR = [(Up, "copyRoom")]; monsterR = None; lastCheckR = 0.});
	 ("gradLounge",
	  {nameR = "gradLounge"; imageR = "gradLounge"; valueR = 3;
	   exitsR = [(Up, "profOffices"); (Down, "copyRoom"); (Right, "studySpaces")];
	   monsterR = None; lastCheckR = 0.});
	 ("profOffices",
	  {nameR = "profOffices"; imageR = "profOffices"; valueR = 2;
	   exitsR = [(Right, "Gimme!"); (Left, "CSUGLab"); (Down, "gradLounge")];
	   monsterR = None; lastCheckR = 0.});
	 ("Gimme!",
	  {nameR = "Gimme!"; imageR = "Gimme!"; valueR = 1;
	   exitsR = [(Right, "main"); (Up, "kitchen"); (Left, "profOffices")];
	   monsterR = None; lastCheckR = 0.})]

let map_with_monsters = [("main",                                                                         {nameR = "main"; imageR = "main"; valueR = 0;                                 
   exitsR = [(Left, "Gimme!"); (Right, "kitchen")]; monsterR = None;            
   lastCheckR = 0.});
 ("kitchen",
  {nameR = "kitchen"; imageR = "kitchen"; valueR = 1;
   exitsR = [(Left, "main"); (Down, "hallway"); (Up, "Gimme!")];
   monsterR = None; lastCheckR = 0.});
 ("hallway",
  {nameR = "hallway"; imageR = "hallway"; valueR = 2;
   exitsR = [(Up, "kitchen"); (Left, "CSOffices"); (Down, "lectureHall")];
   monsterR = None; lastCheckR = 0.});
 ("lectureHall",
  {nameR = "lectureHall"; imageR = "lectureHall"; valueR = 3;
   exitsR = [(Up, "hallway"); (Down, "CSOffices"); (Left, "copyRoom")];
   monsterR = None; lastCheckR = 0.});
 ("CSOffices",
  {nameR = "CSOffices"; imageR = "CSOffices"; valueR = 3;
   exitsR = [(Right, "lectureHall"); (Up, "hallway"); (Left, "studySpaces")];
   monsterR = None; lastCheckR = 0.});
 ("studySpaces",
  {nameR = "studySpaces"; imageR = "studySpaces"; valueR = 4;
   exitsR = [(Right, "CSOffices"); (Left, "CSUGLab"); (Up, "gradLounge")];
   monsterR = None; lastCheckR = 0.});
 ("CSUGLab",
  {nameR = "CSUGLab"; imageR = "CSUGLab"; valueR = 3;
   exitsR = [(Up, "profOffices"); (Down, "studySpaces"); (Right, "copyRoom")];
   monsterR = None; lastCheckR = 0.});
 ("copyRoom",
  {nameR = "copyRoom"; imageR = "copyRoom"; valueR = 4;
   exitsR =
    [(Right, "lectureHall"); (Up, "gradLounge"); (Left, "CSUGLab");
     (Down, "ClarksonOffice")];
   monsterR =
    Some
     {nameM = "Camel"; levelM = 0; imageM = "Camel"; currentRoomM = "copyRoom";
      modusOperandiM = "random walk"; timeToMoveM = 2961804918.;
      teleportRoomM = ["copyRoom"]};
   lastCheckR = 0.});
 ("ClarksonOffice",
  {nameR = "ClarksonOffice"; imageR = "ClarksonOffice"; valueR = 5;
   exitsR = [(Up, "copyRoom")]; monsterR = None; lastCheckR = 0.});
 ("gradLounge",
  {nameR = "gradLounge"; imageR = "gradLounge"; valueR = 3;
   exitsR = [(Up, "profOffices"); (Down, "copyRoom"); (Right, "studySpaces")];
   monsterR = None; lastCheckR = 0.});
 ("profOffices",
  {nameR = "profOffices"; imageR = "profOffices"; valueR = 2;
   exitsR = [(Right, "Gimme!"); (Left, "CSUGLab"); (Down, "gradLounge")];
   monsterR = None; lastCheckR = 0.});
 ("Gimme!",
  {nameR = "Gimme!"; imageR = "Gimme!"; valueR = 1;
   exitsR = [(Right, "main"); (Up, "kitchen"); (Left, "profOffices")];
   monsterR = None; lastCheckR = 0.})]


(* tests json parsing and initial state *)
let json_tests = 
[
  "insert_monster" >:: (fun _ -> assert_equal [("Camel",                                                                        
  	{nameM = "Camel"; levelM = 0; imageM = "Camel"; 
  	currentRoomM = "copyRoom";    
   modusOperandiM = "random walk"; 
   timeToMoveM = 2.*.Unix.time(); (* have to test with this function *)
   teleportRoomM = ["copyRoom"]})]
  (insert_monster j 0));

  "get_map_no_monsters" >:: (fun _ -> assert_equal 
  	map
  (get_map_no_monsters j));

	"init_state" >:: (fun _ -> assert_equal {
	  monsters = [("Camel",                                                                        
	  	{nameM = "Camel"; levelM = 0; imageM = "Camel"; 
	  	currentRoomM = "copyRoom";    
	   modusOperandiM = "random walk"; 
	   timeToMoveM = 2.*.Unix.time();
	   teleportRoomM = ["copyRoom"]})];
	  player = "Student";
	  map = get_map j 0 map;
	  startTime = Unix.time();
	  time = 0.;
	  battery = 100.;
	  doorStatus = ((One,true),(Two,true));
	  room = List.assoc "main" map;
	  level = 0;
	  quit = false;
	  lost = false;
	  printed = false
	  }
		(init_state j 0));
]


let level1_state = 
{monsters =                                                                       [("Camel",                                                                    
    {nameM = "Camel"; levelM = 0; imageM = "Camel"; currentRoomM = "copyRoom";
     modusOperandiM = "random walk"; timeToMoveM = 2.*.Unix.time();
     teleportRoomM = ["copyRoom"]});
   ("Bed",
    {nameM = "Bed"; levelM = 1; imageM = "Bed"; currentRoomM = "CSOffices";
     modusOperandiM = "weighted movement"; timeToMoveM = 2.*.Unix.time();
     teleportRoomM = ["studySpaces"]})];
 player = "Student";
 map =
  [("main",
    {nameR = "main"; imageR = "main"; valueR = 0;
     exitsR = [(Left, "Gimme!"); (Right, "kitchen")]; monsterR = None;
     lastCheckR = 0.});
   ("kitchen",
    {nameR = "kitchen"; imageR = "kitchen"; valueR = 1;
     exitsR = [(Left, "main"); (Down, "hallway"); (Up, "Gimme!")];
     monsterR = None; lastCheckR = 0.});
   ("hallway",
    {nameR = "hallway"; imageR = "hallway"; valueR = 2;
     exitsR = [(Up, "kitchen"); (Left, "CSOffices"); (Down, "lectureHall")];
     monsterR = None; lastCheckR = 0.});
   ("lectureHall",
    {nameR = "lectureHall"; imageR = "lectureHall"; valueR = 3;
     exitsR = [(Up, "hallway"); (Down, "CSOffices"); (Left, "copyRoom")];
     monsterR = None; lastCheckR = 0.});
   ("CSOffices",
    {nameR = "CSOffices"; imageR = "CSOffices"; valueR = 3;
     exitsR = [(Right, "lectureHall"); (Up, "hallway"); (Left, "studySpaces")];
     monsterR =
      Some
       {nameM = "Bed"; levelM = 1; imageM = "Bed"; currentRoomM = "CSOffices";
        modusOperandiM = "weighted movement"; timeToMoveM = 2.*.Unix.time();
        teleportRoomM = ["studySpaces"]};
     lastCheckR = 0.});
   ("studySpaces",
    {nameR = "studySpaces"; imageR = "studySpaces"; valueR = 4;
     exitsR = [(Right, "CSOffices"); (Left, "CSUGLab"); (Up, "gradLounge")];
     monsterR = None; lastCheckR = 0.});
   ("CSUGLab",
    {nameR = "CSUGLab"; imageR = "CSUGLab"; valueR = 3;
     exitsR = [(Up, "profOffices"); (Down, "studySpaces"); (Right, "copyRoom")];
     monsterR = None; lastCheckR = 0.});
   ("copyRoom",
    {nameR = "copyRoom"; imageR = "copyRoom"; valueR = 4;
     exitsR =
      [(Right, "lectureHall"); (Up, "gradLounge"); (Left, "CSUGLab");
       (Down, "ClarksonOffice")];
     monsterR =
      Some
       {nameM = "Camel"; levelM = 0; imageM = "Camel";
        currentRoomM = "copyRoom"; modusOperandiM = "random walk";
        timeToMoveM = 2.*.Unix.time(); teleportRoomM = ["copyRoom"]};
     lastCheckR = 0.});
   ("ClarksonOffice",
    {nameR = "ClarksonOffice"; imageR = "ClarksonOffice"; valueR = 5;
     exitsR = [(Up, "copyRoom")]; monsterR = None; lastCheckR = 0.});
   ("gradLounge",
    {nameR = "gradLounge"; imageR = "gradLounge"; valueR = 3;
     exitsR = [(Up, "profOffices"); (Down, "copyRoom"); (Right, "studySpaces")];
     monsterR = None; lastCheckR = 0.});
   ("profOffices",
    {nameR = "profOffices"; imageR = "profOffices"; valueR = 2;
     exitsR = [(Right, "Gimme!"); (Left, "CSUGLab"); (Down, "gradLounge")];
     monsterR = None; lastCheckR = 0.});
   ("Gimme!",
    {nameR = "Gimme!"; imageR = "Gimme!"; valueR = 1;
     exitsR = [(Right, "main"); (Up, "kitchen"); (Left, "profOffices")];
     monsterR = None; lastCheckR = 0.})];
 startTime = Unix.time(); time = 0.; battery = 100.;
 doorStatus = ((One, true), (Two, true));
 room =
  {nameR = "main"; imageR = "main"; valueR = 0;
   exitsR = [(Left, "Gimme!"); (Right, "kitchen")]; monsterR = None;
   lastCheckR = 0.};
 level = 1; quit = false; lost = false; printed = false}

let update_tests = 
[
	"next_level" >:: (fun _ -> assert_equal 
		level1_state
		(next_level j (init_state j 0)));

	"next_level" >:: (fun _ -> assert_equal 
		map
		(update_map_camera_view map {nameR = "kitchen"; imageR = "kitchen"; valueR = 1;
		   exitsR = [(Left, "main"); (Down, "hallway"); (Up, "Gimme!")];
		   monsterR = None; lastCheckR = 0.} 0.));

	"next_level" >:: (fun _ -> assert_equal 
		map
		(update_map_camera_view map {nameR = "kitchen"; imageR = "kitchen"; valueR = 1;
		   exitsR = [(Left, "main"); (Down, "hallway"); (Up, "Gimme!")];
		   monsterR = None; lastCheckR = 0.} 0.));

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
  " test suite"
  >::: json_tests @ update_tests @ do_tests

let _ = run_test_tt_main suite
