convention:
use snake case for functions.
use camel case for variables and types.


TODO:
figure out taking in commands while running script == async!!
others: engine, AIs, graphics
Connie : Graphics
Pui Lam : Engine
Jovan : Async
Ruoyan : AI

NOTE:
IF you want to check more types with make check, open checktypes.sh and add
to where it says "EDIT HERE TO CHECK TYPES". Make sure you use Engine.* and
not Game.* as what shipped with A2 has Game.* and had to be modified. Follow
the format of the given type checks.

**** MAKE SURE TO MAKE CLEAN BEFORE YOU ADD COMMIT AND PUSH. ****

Nov 27: From Jovan:
When integrating async, remove eval from eval loop, make eval non-recursive.
When doing graphics, do: st.room.nameR ^ st.room.monsterR.nameM ^ .jpg

Nov 24: Will need to implement async soon, probably, if the game itself will
run without problems, as the next step in the game would be
monsters/time/battery, which all need to be asynced in.

Nov 23:
.mli will need updating. Put failwiths on functions that need to be implemented.

IMPORTANT NOTE:
I(Ruoyan) deleted/renamed the engine mli file tempararily just because it's easier to test without that annoying <abstr> thing. We can add it back after finish testing

added makefile, testfile. Those are still basically based on the solution I had for the text adventure game before(they should be mostly correct/working). But should be easy to change into our desired format(without AI, async and graphics).

also changed the engine mli (have some syntax errors)