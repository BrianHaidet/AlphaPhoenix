%Example on the use of AStar Algorithm in an occupancy grid. 
clear
%%% Generating a MAP
%1 represent an object that the path cannot penetrate, zero is a free path
MAP=int8(zeros(128,140));
MAP(1:64,1)=1;
MAP(121,2)=1;
MAP(120,3:100)=1;
MAP(125:128,40:60)=1;
MAP(120:128,100:120)=1;
MAP(126,100:118)=0;
MAP(120:126,118)=0;
MAP(100:120,100)=1;
MAP(114:124,112:118)=0;
MAP(1,1:128)=1;
MAP(128,1:128)=1;
MAP(100,1:130)=1;
MAP(50,28:128)=1;
MAP(20:30,50)=1;
MAP(1:128,1)=1;
MAP(1:65,128)=1;
MAP(1,1:128)=1;
MAP(128,1:128)=1;
MAP(10,1:50)=1;
MAP(25,1:50)=1;
MAP(40,40:50)=1;
MAP(40,40:45)=1;
MAP(80,20:40)=1;
MAP(80:100,40)=1;
MAP(80:100,120)=1;
MAP(120:122,120:122)=1;
MAP(120:122,20:25)=1;
MAP(120:122,10:11)=1;
MAP(125:128,10:11)=1;
MAP(100:110,30:40)=1;
MAP(1:20,100:128)=1;
MAP(10:20,80:128)=1;
MAP(20:40,80:90)=1;
MAP(1:40,90:90)=1;
MAP(100:105,70:80)=1;


%Start Positions
StartX=15;
StartY=15;

% a=ASl
%Start Positions
% StartX=5;
% StartY=99;

%Generating goal nodes, which is represented by a matrix. In 2sided version
%only one goal node can be specified
GoalX=80;
GoalY=110;


%CONNECTING DISTANCEA
Connecting_Distance=11;


% A MORE EFFICIENT SOLVER
load NeighboorsTable2 NeighboorsTable
Neighboors=NeighboorsTable{Connecting_Distance};


%THE MOST EFFICIENT SOLVER; TWO SIDED SOVLER (ALSO 
OptimalPath=ASTARPATH2SIDED(StartX,StartY,MAP,GoalX,GoalY,Connecting_Distance,Neighboors)
if size(OptimalPath,2)>1
figure(10)
imagesc(MAP)

    colormap(flipud(gray));

hold on
plot(OptimalPath(1,2),OptimalPath(1,1),'o','color','k')
plot(OptimalPath(end,2),OptimalPath(end,1),'o','color','b')
plot(OptimalPath(:,2),OptimalPath(:,1),'r')
legend('Goal','Start','Path')

%USE LENGTH TO NEAREST WALL IN OCCUPANCY GRID AS A SIMPLE GRIDDER TO UPDATE CLOSEMAP?. LOGIC?

%Version 1.0

else 
     pause(1);
 h=msgbox('Sorry, No path exists to the Target!','warn');
 uiwait(h,5);
 end









showNeighboors=0; %Set to 1 if you want to visualize how the possible directions of path. The code
%below are purley for illustrating purposes. 
if showNeighboors==1
        figure('name','Con1')
PlotConnectors(Connecting_Distance)
end