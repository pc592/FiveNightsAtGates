Game Goals: Survive 10 in-game hours to finish assignment and get through the night while avoiding monsters
————————————————————————————————————————————————————————————————
Convention (informally. we all have different coding preferences, but we're trying):
use snake case for functions.
use camel case for variables and types.

To compile the game please have these modules installed on your computer.
REQUIRED:
Sdl for OCaml (Simple DirectMedia Layer) [instructions below]
OPTIONAL (FEATURES NOT FINISHED)
ANSITerminal
async (and async_parallel, installed by running [opam install async_parallel]
  in the terminal window)

**NOTE/WARNING: ONLY PROVEN TO WORK IN VIRTUALBOX WITH UBUNTU GUEST**

To play the game:
Run make play (or make). Entering “Escape” at any point of game play, or in the
beginning for file input, exits out of the game entirely.

**Make sure you are on the game window in your taskbar when playing--otherwise
your commands will not be registered. This is indicated by an outlined clear
rectangle rather than the regular solid rectangle in the terminal window.**

————————————————————————————————————————————————————————————————

To install oCamlSDL for VM:

* Run the following code in the terminal to install dependency packages for SDL2:

sudo apt-get install build-essential xorg-dev libudev-dev libgl1-mesa-dev libglu1-mesa-dev libasound2-dev libpulse-dev libopenal-dev libogg-dev libvorbis-dev libaudiofile-dev libpng12-dev libfreetype6-dev libusb-dev libdbus-1-dev zlib1g-dev libdirectfb-dev


* Then run the following code in the terminal to install SDL:

sudo apt-get install libsdl2-dev

* From the terminal, navigate to the included folder "ocamlsdl-0.9.1"
* Run the following line by line.

sudo apt-get install libsdl-ttf2.0-dev
sudo apt-get install libsdl-image1.2-dev
sudo apt-get install libsdl-mixer1.2-dev
sudo apt-get install libsdl-gfx1.2-dev
./configure
make
make install
make clean

* Now you can return to the previous folder and play!

————————————————————————————————————————————————————————————————

To install for MacOS:
* if you have ports, install with instructions in https://vog.github.io/ocamlsdl-tutorial/
* if you have brew,

brew install sdl2
brew install ocamlsdl

*then
opam install ocamlsdl

————————————————————————————————————————————————————————————————

Background Music and Sound Credits (unimplemented):
ThrillShowX: https://www.youtube.com/channel/UC6aGkyktim54QjAIVqrx2sg
Ross Bugden - Music: https://www.youtube.com/channel/UCQKGLOK2FqmVgVwYferltKQ
FreeSFX: http://www.freesfx.co.uk

