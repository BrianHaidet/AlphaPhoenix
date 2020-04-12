# A* (Astar / A Star) search algorithm. Easy to use 

Can handle any heigth and width of occupancy grid?  <strong>YES</strong>

Possible to specify multiple goal nodes? <strong>YES</strong>

Fast and efficient? <strong>YES</strong>

Possible to specify connecting distance to other nodes? <strong>YES</strong> (in other words the algorithm is not restriced to 8-directions) 

In the version 1.0 there are no nested functions, subfunctions, plotters, or any other mess in the actual pathfinder script. Version2 is a bit faster, but possibly a bit harder to understand. 

-----------------

Algorithm has simple inputs: An occupancy grid. A goal Matrix, the start node and preffered connecting distance. 
The zip file includes an example on the use of the script 


The <strong>Connecting Distance</strong> determines the connections from each node to neighbooring cells.  This means that the algorithm is not restriced to 4 or 8-directions (which often is the case in other implementations). In general a longer connecting distance require some more computation time.  

See the following examples for <strong>Connecting Distance</strong> varying between 1, 4 and 8;

<img src="https://github.com/EinarUeland/Astar-Algorithm/blob/TestRnd/Figures/ASTARSHOWCon1.png"   width="430" height="323"> <img src="https://github.com/EinarUeland/Astar-Algorithm/blob/TestRnd/Figures/ASt3arC1.gif"   width="430" height="323">

<img src="https://github.com/EinarUeland/Astar-Algorithm/blob/TestRnd/Figures/ASTARSHOWCon4.png"   width="430" height="323"> <img src="https://github.com/EinarUeland/Astar-Algorithm/blob/TestRnd/Figures/ASt3arC4.gif"   width="430" height="323">

<img src="https://github.com/EinarUeland/Astar-Algorithm/blob/TestRnd/Figures/ASTARSHOWCon8.png"   width="430" height="323"> <img src="https://github.com/EinarUeland/Astar-Algorithm/blob/TestRnd/Figures/ASt3arC10.gif"   width="430" height="323">


In the above example, the A-Star algorithm needed to explore most cells. Efficiency can be improved by using the <strong>2-sided</strong> solver as seen here;  

<p align="center"><img src="https://github.com/EinarUeland/Astar-Algorithm/blob/TestRnd/Figures/2Sided.gif"   width="430" height="323"> 

<strong>Multiple goal nodes</strong> can be specified. In the below example, there is 4 different goal cells.
<p align="center"><img src="https://github.com/EinarUeland/Astar-Algorithm/blob/TestRnd/Figures/Multiple.gif"   width="430" height="323"> 

An example of use of provided method is the use in <em>Frontier Based Exploration</em>  where the "robot" search for the nearest unexplored cell:
<p align="center"><img src="https://github.com/EinarUeland/Astar-Algorithm/blob/TestRnd/Figures/FRONTIER.gif"   width="430" height="323"> 

See example video [here](https://www.youtube.com/watch?v=BUihBGbhfDA&list=UU1A6Jx2ywuj62UYKbIAUcOQ&index=3&t=0s "Youtube")

By modifying the <strong>weight map</strong> for traversing cells, one can penalize paths that are near objects, and generally create smoother paths: 
<p align="center"><img src="https://github.com/EinarUeland/Astar-Algorithm/blob/TestRnd/Figures/GFF.gif"   width="430" height="323"> 



-----------------

This code was written for a project, which I have written a paper about: 
http://proceedings.asmedigitalcollection.asme.org/proceeding.aspx?articleid=2655682
This paper provides some more details on the code, and how it can be applied in a practical example. If you use the code for academic work/publishing I will appreciate if you could cite the above paper.



