Here's my folder of matlab code from the golf phase space project!

https://youtu.be/b-pLRX3L-fg

Legal: released only for educational use (CC non-commercial, attribution), originally by Brian Haidet for AlphaPhoenix.

testthrowball.m is a good place to start to understand the code cause it's a stripped-down early version of the "engine" - there's not really much to it...

The file "smoother" transforms a blotchy image (ie from paint) into a smooth "green" by applying a huge gaussian blurr.

That "green*.tiff" file then gets fed to a file like "bankexample.m", which takes that file, locates a ball and a pin, and set of initial conditions, and putts all the balls at once. if you enable the line 119 "saveas(..." then it automatically makes a directory and starts dumping frames into it for a video.

the phase space pops up in a new figure as soon as all balls have stopped moving.

lines 9-11 "coeffs" control drag and the strength of gravity. These are different in almost every file to get it to do what I wanted for the sake of the video. I cut a few but included most of the other runnable files, so enjoy!