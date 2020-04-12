Snake AI: Dynamic Hamiltonian Cycle Repair (with some strategic enhancements)
2019-2020, Brian Haidet, AlphaPhoenix, youtube.com/c/alphaphoenixchannel

Provided for educational use only
CC non-commercial, attribution

I don't want to hear anybody's pasting this into their homework or some nonesense. Especially cause if I was grading it I'd ding all kinds of points for cleanliness of code and if you can clean it presumably you understand it well enough to submit it :)
Just leave a cite...

This is the source (MATLAB) for my snake-playing algorithm based on repairing and rewriting a hamiltonian cycle that provides a path to every node on the board and insures the snake cannot die.

For a more exciting summary of this project, check out youtube:
https://www.youtube.com/watch?v=TOpBcfbAgPg

The primary file ("P_snakegame...")has two bools at the top that specify what kind of plotting the code will display. if you want to go comment out ALL of the plotting, the code runs super fast, but it's not very exciting. The default is a fast-plotting mode with less information and no video being rendered (video makes it SUPER slow...). The extra file "checkpath..." isn't actually a function, just a seperate file where I put the code for repairing the hamiltonian path because it's a lot and messy and I wanted to keep it somewhere else. It still uses all the variables from the original program file. The A* algorithm is provided by code I didn't write (original license included), and that containing folder must be included in the matlab environment to run properly (or just move my modified version of the A* code to the same folder as the other two files - that should work, although maybe there are extra function calls and stuff in the A* code, i didn't look too deep I just included the folders and subfolders...)

Since the "checkpath..." file is probably the most interesting to anybody reading this code and it's pretty soupy and covered with nested nastyness, I'll give a brief summary. The program keeps track of the hamiltonian path for the snake in a couple different ways, notably, a 900-entry vector containing the numbers 1 to 900. If you walk the hamiltonian path in across the snake board, these entries are the indeces of the squares you will encounter. You can confirm this by starting the game and throwing a breakpoint as soon as the opening board is defined. the hamiltonian path for a 10x10 board (if i remember right) runs 1->10-20->12-22->30..........82->90-100->91-81-71-61-51-41-31-21-11-1. that is the zig-zag path created in the first few paragraphs of code.

to go back and forth between these style "index" coordinates and "human-meaningful" x-y coordinates, I have two functions very creatively named "coords" and"inds" used to convert back and forth between these two datatypes. Although the final path is expressed in indeces, converting to coordinates is frequently necessary to check adjacency of nodes. The program also  sometimes places the hamiltonian cycle (or just the snake as a boolean) on a 2d array to create an "image" for using matlab's built-in blob-finding algorithms like bwlabel and other image ROI-finding like kernel convolution.

I have a basic description of how the checkpath file runs as comments, but I admit it is very soupy and not the best-documented stuff out there. if anybody finds anything wrong, let me know! there are probably some latent non-catastrophic mistakes.