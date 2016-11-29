

(* getKey () functions like read_line ().
 * Return the string equivalent so that process_cmd is still the same.*)
let cmd =
  let rec getKey () =
    match wait_event () with
    | KEYDOWN {keysym=KEY_UP} -> "up"
    | KEYDOWN {keysym=KEY_DOWN} -> "down"
    | KEYDOWN {keysym=KEY_RIGHT} -> "right"
    | KEYDOWN {keysym=KEY_LEFT} -> "left"
    | KEYDOWN {keysym=KEY_SPACE} -> "next"
    | KEYDOWN {keysym=KEY_ESCAPE} -> "quit"
    | KEYDOWN {keysym=KEY_a} -> "close one"
    | KEYDOWN {keysym=KEY_s} -> "close_two"
    | KEYDOWN {keysym=KEY_d} -> "open one"
    | KEYDOWN {keysym=KEY_f} -> "open two"
    | KEYDOWN {keysym=Key_w} -> "main"
    | KEYDOWN {keysym=Key_e} -> "camera"
    | event -> print_endline (string_of_event event) ^ " is not a valid command";
               getKey ()