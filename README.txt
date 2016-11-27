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


Nov 23:
No idea what's up with .mli's or anything, but created engine2.ml to select just
the functions that we want/need. Also ended up having to change the types of
some things and adding fields, etc. Put failwiths on functions that need to be
implemented.

Nov 24: Also not 100% certain interface is correct. Will need to implement
async soon, probably, if the game itself will run without problems, as the next
step in the game would be monsters/time/battery, which all need to be asynced in.

NOTE:
IF you want to check more types with make check, open checktypes.sh and add
to where it says "EDIT HERE TO CHECK TYPES". Make sure you use Engine.* and
not Game.* as what shipped with A2 has Game.* and had to be modified. Follow
the format of the given type checks.

**** MAKE SURE TO MAKE CLEAN BEFORE YOU ADD COMMIT AND PUSH. ****

IMPORTANT NOTE:
I(Ruoyan) deleted/renamed the engine mli file tempararily just because it's easier to test without that annoying <abstr> thing. We can add it back after finish testing

added makefile, testfile. Those are still basically based on the solution I had for the text adventure game before(they should be mostly correct/working). But should be easy to change into our desired format(without AI, async and graphics).

also changed the engine mli (have some syntax errors)