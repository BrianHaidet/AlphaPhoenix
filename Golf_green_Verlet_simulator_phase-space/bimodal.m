clear
close all
clc;

%time
dt=0.01;

%coeffs
Cg=200.;
Cd=.2;
minSpeed=10;

name='greenbimodal3.png.tiff'
sanitizedname=[strrep(name,'.','') '_fast']
mkdir([sanitizedname 'outputdir'])
%green
%greenheight=double(imread('testgreen.tiff'))/256*1.7;
%greenheight=double(imread('greencone.tiff'))/256*.3;
%greenheight=double(imread('greenconeinv.tiff'))/256*.3;
greenheight=fliplr(rot90(rot90(double(imread(name))/256*.1)));
greenheightPLOT=fliplr(rot90(rot90(double(imread(name))/256*.1)));
[gradX,gradY]=gradient(greenheight(:,:,1));
forceFun=@(R,RL) (RL-R)/dt*Cd + [interp2(-gradX,R(1,:),R(2,:));interp2(-gradY,R(1,:),R(2,:))]*Cg;
%forceFun=@(R,RL) [interp2(-gradX,R(1,:),R(2,:));interp2(-gradY,R(1,:),R(2,:))];
l=size(greenheight,1);

%pin
holeLoc=size(greenheight)'/2;
holeRadius=3;

%graphics
%sph=sphere(30)
alt=30.85;
az=-39+20-90;
cmapgreen=flipud([181,228,138; 160,220,104; 124,216,87; 81,212,76; 52,188,67; 37,167,60; 32,154,61; 1,114,56; 0,86,19]/255);
stickX=[holeLoc(1),holeLoc(1)];
stickY=[holeLoc(2),holeLoc(2)];
stickZ=[greenheight(floor(holeLoc(1)),floor(holeLoc(1))),greenheight(floor(holeLoc(1)),floor(holeLoc(1)))+100];
flagX=[stickX;stickX+40];
flagY=[stickY;stickY];
flagZ=[stickZ(2),stickZ(2)-30;stickZ(2),stickZ(2)-30];
flagC=zeros(2,2,3);
flagC(:,:,1)=.9;

% balls
startLoc=[64;64]+16;

%angles=(45)*pi/180;
%speeds=400;
%angles=linspace((45-15)*pi/180,(45+15)*pi/180,10);%-pi/4;
angles=linspace((45-90)*pi/180,(45+90)*pi/180,51);%-pi/4;
speeds=linspace(10,135,51);

numParticles=length(speeds)*length(angles);

speeds=reshape(speeds,1,1,length(speeds));
angleVectors=[cos(angles);sin(angles)];
startConditions=bsxfun(@times,speeds,angleVectors);
startConditions=reshape(startConditions,2,length(speeds)*length(angles));

r=repmat(startLoc,1,numParticles);
rl=r-startConditions*dt;

rstart=r;
rlstart=rl;

%sequentialhits staging
%each ball laucnhes after 1/4 second (300 iters/4) = 80 ticks
launchTicks=80

i=0;
while sum(sum(r~=rl))
    %energy verlet + drag
    i=i+1;
    rn=2*r-rl+(forceFun(r,rl))*dt^2;
    rl=r;
    r=rn;
    
    %%%LAUNCH CONDITIONS
    if i<50
        r=rstart;
        rl=rlstart;
    end
    
    %%%STOP CONDITIONS
    %static friction
    dr=rl-r;
    s=sqrt(dr(1,:).^2+dr(2,:).^2)/dt;
    %walls
    haltBallsEdge=(r>l)|(r<1);
    %in the hole
    distToHole=bsxfun(@minus,holeLoc,rl);%use rl not r to check if the ball is in the hole so it can't escape
    distToHole=sqrt(distToHole(1,:).^2+distToHole(2,:).^2);
    %stop those in stop conditions
    holeBalls=(distToHole<holeRadius);
    rl(:,holeBalls)=repmat(holeLoc,1,sum(holeBalls));
    haltBalls=(haltBallsEdge(1,:)|haltBallsEdge(2,:))|(s<minSpeed)|(distToHole<holeRadius);
    r(:,haltBalls)=rl(:,haltBalls);
    
    if mod(i,10)==0
        figure(1)
        surf(greenheightPLOT,'edgecolor','none')
        colormap(cmapgreen)
        set(gca,'DataAspectRatio',[1 1 1])
        hold on
        scatter3(r(1,:),r(2,:),3+greenheightPLOT(sub2ind(size(greenheightPLOT), floor(r(2,:)),floor(r(1,:)))),'wo','filled')
        plot3(stickX,stickY,stickZ,'k-')
        surf(flagX,flagY,flagZ,flagC,'edgecolor','none')
        hold off
        az=az+.1;
        view([az alt])
%         imshow(greenheight,[min(min(greenheight)),max(max(greenheight))],'colormap',colormap('parula'))
        hold on
        %rectangle('Position',[holeLoc(1)-holeRadius holeLoc(2)-holeRadius holeRadius*2 holeRadius*2],'Curvature',[1,1],'FaceColor','black');
        %scatter(r(1,:),r(2,:),'w.')
        hold off
        xlim([0,512])
        ylim([0,512])
        %title(num2str(s(1)))
        set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
        %saveas(gcf,[[sanitizedname 'outputdir'] '\' num2str(i/10,'%05i') '.png'])
    end
end

%phase space

figure(2)
maxDist=256;
maxColor=reshape([1,0,0],1,1,3);
minColor=reshape([1,1,1],1,1,3);
dists=fliplr(flipud(reshape(distToHole,length(angles),length(speeds))'));
imshow(dists,[holeRadius,maxDist],'colormap',colormap('jet'))
hold on
h=imshow(repmat(ones(size(dists)),1,1,3));
hold off
set(h,'AlphaData',dists<holeRadius);
ylabel('Putt speed')
xlabel('putt angle')