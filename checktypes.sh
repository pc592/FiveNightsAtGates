#!/bin/bash
# DO NOT EDIT THIS FILE

ocamlbuild -pkgs oUnit,yojson,str,ANSITerminal,async main.byte engine.byte
if [[ $? -ne 0 ]]; then
  cat <<EOF
===========================================================
WARNING

Your code currently does not compile.  You will receive
little to no credit for submitting this code. Check the
error messages above carefully to determine what is wrong.
See a consultant for help if you cannot determine what is
wrong.
===========================================================
EOF
  exit 1
fi

cat >checktypes.ml <<EOF
(* EDIT HERE TO CHECK TYPES *)
let e:exn = Engine.Illegal

let check_get_map : Yojson.Basic.json -> (string*Engine.room) list = Engine.get_map
let check_insert_monster : Yojson.Basic.json -> int -> (string * Engine.monster) list = Engine.insert_monster
let check_init_state : Yojson.Basic.json -> int -> Engine.state = Engine.init_state
EOF

if ocamlbuild -pkgs oUnit,yojson,str,ANSITerminal,async checktypes.byte ; then
  cat <<EOF
===========================================================
Your function names and types look good to me.
Congratulations!
===========================================================
EOF
else
  cat <<EOF
===========================================================
WARNING

Your function names and types look broken to me.  The code
that you submit might not compile on the grader's machine,
leading to heavy penalties.  Please fix your names and
types.  Check the error messages above carefully to
determine what is wrong.  See a consultant for help if you
cannot determine what is wrong.
===========================================================
EOF
fi

