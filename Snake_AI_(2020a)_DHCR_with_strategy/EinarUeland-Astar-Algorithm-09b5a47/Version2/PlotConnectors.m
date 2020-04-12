function PlotConnectors(ConnectingDistance)
NeighboorCheck=ones(2*ConnectingDistance+1);
Dummy=2*ConnectingDistance+2;
Mid=ConnectingDistance+1;
for i=1:ConnectingDistance-1
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
Neighboors=[row col]-(ConnectingDistance+1);
for p=1:size(Neighboors,1)
  i=Neighboors(p,1);
       j=Neighboors(p,2);
      
     plot([0 i],[0 j],'k')
 hold on
 axis equal
grid on
title(['Connecting distance=' num2str(ConnectingDistance)] )

end

end