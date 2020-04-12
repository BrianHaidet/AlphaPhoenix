     function [OptimalPath,OpenedMAT]=ASTARPATH2SIDED(StartX,StartY,MAP,GoalX,GoalY,Connecting_Distance,NeighboorsTable)
%Version 1.0
% clear
% load INN
% GoalX=110;
% GoalY=80;
% By Einar Ueland 2nd of May, 2016
% clear
%  load IN0IN
% load NeighboorsTable NeighboorsTable
% StartX=41;
% StartY=85;
% ZZ
% INSTOP=5000
 for i=1:(2*Connecting_Distance+1)
    for j=1:(2*Connecting_Distance+1)
G_scoreMat(i,j)=norm( [i-(Connecting_Distance+1) j-(Connecting_Distance+1)]);
    end
end
% ASTAR0Run
% Connecting_Distance=6;
%FINDING ASTAR PATH IN AN OCCUPANCY GRID
%nNeighboor=3;
% Preallocation of Matrices
[Height,Width]=size(MAP); %Height and width of matrix
GScore4=zeros(Height,Width);           %Matrix keeping track of G-scores 
FSparce4=sparse(Height,Width);     %Matrix keeping track of F-scores (only open list) 
Hn=single(zeros(Height,Width));       %Heuristic matrix
OpenMAT4=int8(zeros(Height,Width));    %Matrix keeping of open grid cells
ClosedMAT=int8(zeros(Height,Width));  %Matrix keeping track of closed grid cells
ClosedMAT(MAP==1)=1;                  %Adding object-cells to closed matrix
ParentX4=int16(zeros(Height,Width));   %Matrix keeping track of X position of parent
ParentY4=int16(zeros(Height,Width));   %Matrix keeping track of Y position of parent
FScore4=single(inf(Height,Width));     %Matrix keeping track of F-scores (only open list) 

GScoreEnd=zeros(Height,Width);           %Matrix keeping track of G-scores 
FSparceEnd=sparse(Height,Width);     %Matrix keeping track of F-scores (only open list) 
HnEnd=single(zeros(Height,Width));       %Heuristic matrix
OpenMATEnd=int8(zeros(Height,Width));    %Matrix keeping of open grid cells
ClosedMATEnd=int8(zeros(Height,Width));  %Matrix keeping track of closed grid cells
ClosedMATEnd(MAP==1)=1;                  %Adding object-cells to closed matrix
ParentXEnd=int16(zeros(Height,Width));   %Matrix keeping track of X position of parent
ParentYEnd=int16(zeros(Height,Width));   %Matrix keeping track of Y position of parent
FScoreEnd=single(inf(Height,Width));     %Matrix keeping track of F-scores (only open list) 






OpenedMAT=zeros(Height,Width);
%%% Setting up matrices representing neighboors to be investigated
NeighboorCheck=ones(2*Connecting_Distance+1);
Dummy=2*Connecting_Distance+2;
Mid=Connecting_Distance+1;
for i=1:Connecting_Distance-1
NeighboorCheck(i,i)=0;
NeighboorCheck(Dummy-i,i)=0;
NeighboorCheck(i,Dummy-i)=0;
NeighboorCheck(Dummy-i,Dummy-i)=0;
NeighboorCheck(Mid,i)=0;
NeighboorCheck(Mid,Dummy-i)=0;
NeighboorCheck(i,Mid)=0;
NeighboorCheck(Dummy-i,Mid)=0;
end
NeighboorCheck(Mid,Mid)=0;

[row, col]=find(NeighboorCheck==1);
Neighboors=[row col]-(Connecting_Distance+1);
N_Neighboors=size(col,1);
%%% End of setting up matrices representing neighboors to be investigated
Height0=Connecting_Distance*2+1;

IndicesSmall0=[repmat([0:Height0-1]',1,Height0)*Height0+repmat([1:Height0],Height0,1)]';
IndicesBig0=[repmat([0:Height0-1]',1,Height0)*Height+repmat([1:Height0],Height0,1)]';

%%%%%%%%% Creating Heuristic-matrix based on distance to nearest  goal node
COL(1,1,:)=GoalY;
ROW(1,1,:)=GoalX;
CoordinatesX=repmat(1:Width,Height,1);
CoordinatesY=repmat([1:Height]',1,Width);
Hn=((CoordinatesX-ROW).^2+(CoordinatesY-COL).^2).^0.5;

COL(1,1,:)=StartY;
ROW(1,1,:)=StartX;
CoordinatesX=repmat(1:Width,Height,1);
CoordinatesY=repmat([1:Height]',1,Width);
% save AQ
HnEnd=((CoordinatesX-ROW).^2+(CoordinatesY-COL).^2).^0.5;


%Initializign start node with FValue and opening first node.
FSparce4(StartY,StartX)=Hn(StartY,StartX);    
FScore4(StartY,StartX)=Hn(StartY,StartX);         
FSparceEnd(GoalY,GoalX)=HnEnd(GoalY,GoalX);    
FScoreEnd(GoalY,GoalX)=HnEnd(GoalY,GoalX);         

OpenMAT4(StartY,StartX)=1;   
OpenMATEnd(GoalY,GoalX)=1;   

% A=min(nonzeros (FSparce4))
%  [CurrentY4,CurrentX4]=(find(FSparce4==A))
% 
% FScore4(logical(OpenMAT4))
% find(FScore4(logical(OpenMAT4)))
% F=double(FScore4)
% H=sparse(F)
% F(F==inf)=0;
% A=min(nonzeros (FSparce4))
%  [CurrentY4,CurrentX4]=(find(FSparce4==A))
% % A=tic
% % D=13
% for i=1:13
%     for j=1:13
% G_scoreMat(i,j)=norm( [i-7 j-7])
%     end
% end
POINTLOG=[];
C=0;
D=0;
while 1==1 %Code will break when path found or when no path exist
    %%% REPEAT IT ALL, BUT FROM THE END
[NZero]=nonzeros(FSparceEnd);
[Indexes]=find(FSparceEnd);
[MINopenFScoreEnd b]=min(nonzeros(FSparceEnd));
Indexes(b(1));
    if MINopenFScoreEnd==inf
    %Failuere!
    OptimalPath=[inf];
    RECONSTRUCTPATH=0;
     break
    end
      CurrentYEnd=mod(Indexes(b(1)),Height);
      CurrentXEnd=(Indexes(b(1))-CurrentYEnd)/Height+1;

    CurrentYEnd=CurrentYEnd(end);
    CurrentXEnd=CurrentXEnd(end);
    if (CurrentYEnd==StartY)&&(CurrentXEnd==StartX)
        RECONSTRUCTPATH=1;
        break
    end
    OpenMATEnd(CurrentYEnd,CurrentXEnd)=0;
    FSparceEnd(CurrentYEnd,CurrentXEnd)=0;
    ClosedMATEnd(CurrentYEnd,CurrentXEnd)=1;
    OpenedMATEnd(CurrentYEnd,CurrentXEnd)=1;
    MATRIX2=NeighboorCheck;
iMin=max([1 Connecting_Distance+1-CurrentXEnd+1]);
iMax=min([2*Connecting_Distance+1 Width-CurrentXEnd+(Connecting_Distance+1)]);
jMin=max([1 Connecting_Distance+1-CurrentYEnd+1]);
jMax=min([2*Connecting_Distance+1 Height-CurrentYEnd+Connecting_Distance]);
MATRIX2=NeighboorCheck;
for i=iMin:iMax
    for j=jMin:jMax
        if MAP(CurrentYEnd+j-Connecting_Distance-1,CurrentXEnd+i-Connecting_Distance-1)==1 %CLOSED OR LE 
            MATRIX2(NeighboorsTable{i,j})=0;
        end
    end
end
MATRIX2=MATRIX2(iMin:iMax,jMin:jMax);
XShift=CurrentXEnd-(Connecting_Distance+1);
YShift=CurrentYEnd-(Connecting_Distance+1);
IndicesBig=(YShift+XShift*Height)+IndicesBig0(jMin:jMax,iMin:iMax);
IndicesSmall=IndicesSmall0(jMin:jMax,iMin:iMax);
ClosedMATSub=ClosedMATEnd(IndicesBig);
MATRIX2=min(int8(MATRIX2'), 1-ClosedMATSub) ;
if C==0
    XShift0=XShift;
end
Height0=(2*Connecting_Distance+1);
RelevantIndSmall=IndicesSmall(logical(MATRIX2));
RelevantIndBig=IndicesBig(logical(MATRIX2));
ToBeOpened=OpenMATEnd(RelevantIndBig)==0; 
OpenMATEnd(RelevantIndBig(ToBeOpened))=1;
tentative_GScoreEnd = GScoreEnd(CurrentYEnd,CurrentXEnd)+G_scoreMat(RelevantIndSmall);
GUpdateIndex=tentative_GScoreEnd<GScoreEnd(RelevantIndBig); %%FIX .
UpdateIndex=max([ToBeOpened GUpdateIndex]')';
GUpdate=RelevantIndBig(UpdateIndex);
GUpdateVal=tentative_GScoreEnd(UpdateIndex);
GUpdateSmall=RelevantIndSmall(UpdateIndex);
ParentXEnd(GUpdate)=CurrentXEnd;
if C==0
    GLog=GUpdate;
    RelevantIndBigLog=RelevantIndBig;
end
ParentYEnd(GUpdate)=CurrentYEnd;
GScoreEnd(GUpdate)=GUpdateVal;
% P4=ParentY4(80:100,40:55);
FScoreEnd(GUpdate)= GUpdateVal+HnEnd(GUpdate);
FSparceEnd(GUpdate)= GUpdateVal+HnEnd(GUpdate);
C=C+1;
%%% OTRO
    
[NZero]=nonzeros(FSparce4);
[Indexes]=find(FSparce4);
[MINopenFScore4 b]=min(nonzeros(FSparce4));

Indexes(b(1));
    if MINopenFScore4==inf
    %Failuere!
    OptimalPath=[inf];
    RECONSTRUCTPATH=0;
     break
    end
      CurrentY4=mod(Indexes(b(1)),Height);
      CurrentX4=(Indexes(b(1))-CurrentY4)/Height+1;

    CurrentY4=CurrentY4(end);
    CurrentX4=CurrentX4(end);


    if (CurrentY4==GoalY)&&(CurrentX4==GoalX)
        RECONSTRUCTPATH=1;
        break
    end    
    OpenMAT4(CurrentY4,CurrentX4)=0;
    FSparce4(CurrentY4,CurrentX4)=0;
    ClosedMAT(CurrentY4,CurrentX4)=1;
    OpenedMAT(CurrentY4,CurrentX4)=1;
    MATRIX2=NeighboorCheck;
iMin=max([1 Connecting_Distance+1-CurrentX4+1]);
iMax=min([2*Connecting_Distance+1 Width-CurrentX4+(Connecting_Distance+1)]);
jMin=max([1 Connecting_Distance+1-CurrentY4+1]);
jMax=min([2*Connecting_Distance+1 Height-CurrentY4+Connecting_Distance]);
MATRIX2=NeighboorCheck;
for i=iMin:iMax
    for j=jMin:jMax
        if MAP(CurrentY4+j-Connecting_Distance-1,CurrentX4+i-Connecting_Distance-1)==1 %CLOSED OR LE 
            MATRIX2(NeighboorsTable{i,j})=0;
        end
    end
end
MATRIX2=MATRIX2(iMin:iMax,jMin:jMax);
XShift=CurrentX4-(Connecting_Distance+1);
YShift=CurrentY4-(Connecting_Distance+1);
IndicesBig=(YShift+XShift*Height)+IndicesBig0(jMin:jMax,iMin:iMax);
IndicesSmall=IndicesSmall0(jMin:jMax,iMin:iMax);
ClosedMATSub=ClosedMAT(IndicesBig);
MATRIX2=min(int8(MATRIX2'), 1-ClosedMATSub) ;
if C==0
    XShift0=XShift;
end
Height0=(2*Connecting_Distance+1);
RelevantIndSmall=IndicesSmall(logical(MATRIX2));
RelevantIndBig=IndicesBig(logical(MATRIX2));
ToBeOpened=OpenMAT4(RelevantIndBig)==0; 
OpenMAT4(RelevantIndBig(ToBeOpened))=1;
tentative_GScore4 = GScore4(CurrentY4,CurrentX4)+G_scoreMat(RelevantIndSmall);
GUpdateIndex=tentative_GScore4<GScore4(RelevantIndBig); %%FIX .
UpdateIndex=max([ToBeOpened GUpdateIndex]')';
GUpdate=RelevantIndBig(UpdateIndex);
GUpdateVal=tentative_GScore4(UpdateIndex);
GUpdateSmall=RelevantIndSmall(UpdateIndex);
ParentX4(GUpdate)=CurrentX4;
if C==0
    GLog=GUpdate;
    RelevantIndBigLog=RelevantIndBig;
end
ParentY4(GUpdate)=CurrentY4;
GScore4(GUpdate)=GUpdateVal;
P4=ParentY4(80:100,40:55);
FScore4(GUpdate)= GUpdateVal+Hn(GUpdate);
FSparce4(GUpdate)= GUpdateVal+Hn(GUpdate);
C=C+1;

if ClosedMAT(CurrentYEnd,CurrentXEnd)==1
    ClosedMATEnd(CurrentYEnd,CurrentXEnd)
    CurrentY4=CurrentYEnd;CurrentX4=CurrentXEnd;

    RECONSTRUCTPATH=1;
break
end
end
% save AQ 
% a=ASL
if RECONSTRUCTPATH
[OptimalPath]=ReconstructPath(CurrentX4,CurrentY4,ParentX4,ParentY4,StartX,StartY)  
[OptimalPathEnd]=ReconstructPath(CurrentXEnd,CurrentYEnd,ParentXEnd,ParentYEnd,GoalX,GoalY)  
end

 OptimalPath=[flipud(OptimalPath); (OptimalPathEnd)];

