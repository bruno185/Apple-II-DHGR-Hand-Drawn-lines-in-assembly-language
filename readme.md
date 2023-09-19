# Apple II : "Hand Drawn lines", using Graphics Primitives (in Mouse Graphics Toolkit) and Merlin32 syntax

Here's a program for Apple II that imitates hand-drawn lines.
It draws a set of predefined lines in a deliberately clumsy way, like a child ! 
The design is never the same, since variations are random. 

It's written in assembler (Merlin32) and uses the "Graphics Primitives" library included in Apple's "Mouse Graphics Tool Kit". The source files are fully commented, for a clear understanding of the code.

The Mouse Graphics Toolkit is the Apple IIe / IIc ancestor of the Apple IIGS and Macintosh Toolbox. It's an excellent way to familiarize yourself with event-driven programming and Apple's "guidelines".  Graphics Primitives" are part of this library, and contain numerous graphics functions in double high-resolution (DHGR).

The lines data are in de source file "data.s". 
You can integrate your own designs. A small program for Windows is also included in this archive. It's very simple: just load a bmp image, and click to generate the desired lines. The data are generated on the right-hand side of the image. Copy them, paste them into the data.s source file and recompile the program with Merlin32.

## Use
This archive contains a ProDOS disk image (asmdemo.po) to be used it your favourite Apple II emulator or your Apple II.
* Start your Apple II or emulator with the "asmdemo.po" disk.
* The startup basic program will launch the demo program.
* The welcome screen gives all the instructions.

For amazing graphical effects, I suggest running the program on an emulator like AppleWin, at maximum speed.

## Technique
The program does not use ROM routines for floating-point calculations. There seems to be an incompatibility between the graphics library and these ROM routines. Instead, fixed-point division routines are used (see fplib.s file).

## Requirements to compile and run

Here is my configuration:

* Visual Studio Code with 2 extensions :

-> [Merlin32 : 6502 code hightliting](marketplace.visualstudio.com/items?itemName=olivier-guinart.merlin32)

-> [Code-runner :  running batch file with right-clic.](marketplace.visualstudio.com/items?itemName=formulahendry.code-runner)

* [Merlin32 cross compiler](brutaldeluxe.fr/products/crossdevtools/merlin)

* [Applewin : Apple IIe emulator](github.com/AppleWin/AppleWin)

* [Applecommander ; disk image utility](applecommander.sourceforge.net)

* [Ciderpress ; disk image utility](a2ciderpress.com)

Compilation notes :

DoMerlin.bat puts it all together. If you want to compile yourself, you will have to adapt the path to the Merlin32 directory, to Applewin and to Applecommander in DoMerlin.bat file.

DoMerlin.bat is to be placed in project directory.
It compiles source (*.s) with Merlin32, copy 6502 binary to a disk image (containg ProDOS), and launch Applewin with this disk in S6,D1.

