clear
close all
clc;

%time
dt=0.01;

%coeffs
Cg=1.3;
Cd=1;
minSpeed=20;

%green
greenheight=double(imread('testgreen.tiff'));
[gradX,gradY]=gradient(greenheight(:,:,1));
forceFun=@(R,RL) (RL-R)/dt*Cd + [interp2(-gradX,R(1,:),R(2,:));interp2(-gradY,R(1,:),R(2,:))]*Cg;
%forceFun=@(R,RL) [interp2(-gradX,R(1,:),R(2,:));interp2(-gradY,R(1,:),R(2,:))];
l=size(greenheight,1);

%graphics
%sph=sphere(30)
alt=70;
az=0;


% balls
startLoc=[64;400];

angles=linspace(0,2*pi,360/4+1);
angles=angles(1:end-1);
speeds=linspace(minSpeed,1000,20);

numParticles=length(speeds)*length(angles);

speeds=reshape(speeds,1,1,length(speeds));
angleVectors=[cos(angles);sin(angles)];
startConditions=bsxfun(@times,speeds,angleVectors);
startConditions=reshape(startConditions,2,length(speeds)*length(angles));

r=repmat(startLoc,1,numParticles);
rl=r-startConditions*dt;

i=0;
while sum(sum(r~=rl))
    i=i+1;
    rn=2*r-rl+(forceFun(r,rl))*dt^2;
    rl=r;
    r=rn;
    
    %static friction
    dr=rl-r;
    s=sqrt(dr(1,:).^2+dr(2,:).^2)/dt;
    
    %walls
    haltBallsEdge=(r>l)|(r<1);
    haltBalls=(haltBallsEdge(1,:)|haltBallsEdge(2,:))|(s<minSpeed);
    
    r(:,haltBalls)=rl(:,haltBalls);
    
    if mod(i,10)==0
        figure(1)
        surf(greenheight,'edgecolor','none')
        hold on
%         scatter3(r(1,1),r(2,1),greenheight(floor(r(2,1)),floor(r(1,1))),'wo','filled')
%         hold off
%         az=az+1;
%         view([az alt])
        imshow(greenheight,[min(min(greenheight)),max(max(greenheight))],'colormap',colormap('parula'))
        hold on
        scatter(r(1,:),r(2,:),'w.')
        hold off
        title(num2str(s(1)))
    end
end