% 3D molecular dynamics (GPU vectorized)
% by Brian Haidet for AlphaPhoenix
% published 12/15/2018
% CC non-commercial, attribution

% Don't copy this straight into a homework or something rediculous - I'm
% posting this so people can hopefully learn from it! It's not the cleanest
% code, but I added a few more comments in the areas that need
% explaining. and deleted all the extra bits of commented-out code that had
% built up. Feel free to ask more questions on youtube here!
% https://youtu.be/6DlRsPo-dxY

function [] = plotter(iteration)
    load(['c:\MatlabOutput\CsClSimFrames\data\data' num2str(iteration,'%05d') '.mat'])
    %load(['H:\MatlabOutput\CsClSimFrames\data32krun\' num2str(iteration,'%05d') '.mat'])
    
%PLOTTER Summary of this function goes here
%   Detailed explanation goes here
spheresize=20;
[X,Y,Z]=sphere(spheresize-1);
cdb=zeros(spheresize,spheresize,3);
cdb(:,:,3)=ones(spheresize,spheresize)+((Z-1)/2);
cdr=zeros(spheresize,spheresize,3);
cdr(:,:,1)=ones(spheresize,spheresize)+((Z-1)/2);
X=.7*X;
Y=.7*Y;
Z=.7*Z;
    

gasFraction=.05;
gasFraction2=.0025;
coldThreshold=.06;
annealNum=1024; %above 2048, annealing instead of instachilling
annealMedianSpeed=.022; %cool until this is the median speed of the simulation
speedLimit=.4;

set(gcf,'color','w');
subplot(3,3,[2,3,5,6,8,9]);
hold on;
xlim([-1-1,l+1+1]);
ylim([-1-1,l+1+1]);
zlim([-1-1,l+1+1]);
axis vis3d;
axis off;
zoom;
setAxes3DPanAndZoomStyle(zoom(gcf),gca,'camera');
view(45+iteration*.5,15);
numParticles=size(r,2);

% ---------------------------- calculate which particles to draw -------------------
% thresholdDist=1.25; %between 2nd and 3rd nearest neighbors
% thresholdCount=14; %number of nearest and 2nd nearest neighbors
% rG=gpuArray(r);
% totForces=gpuArray(zeros(1,numParticles));
% chunkSize=ceil(8192^2/numParticles);
% for i=1:ceil(numParticles/chunkSize) %for each chunk
%     cInds=(i-1)*chunkSize+1 : min((i)*chunkSize,numParticles);
%     
%     numPcurr=length(cInds);
%     IP=rG(:,cInds)'*rG(:,:);
%     forces=gpuArray([]);
%     distances=(sqrt(abs(bsxfun(@plus,sum(rG(:,cInds)'.^2,2),sum(rG(:,:).^2,1))-2*IP))<thresholdDist);
%     totForces(cInds)=sum(distances,2);
% end
% drawParticles=totForces<thresholdCount;
% drawPartsIndex=find(drawParticles);
% ----------------------------------------------------------------------------------


% for p=drawPartsIndex
for p=1:numParticles
        delta=mean(r(:,1),2)-[l/2;l/2;l/2];
        %saveData(:,:,f) = saveData(:,:,f) -
        if charge(p)==1
            h=surface(X+r(1,p)-delta(1),Y+r(2,p)-delta(2),Z+r(3,p)-delta(3),cdr);
        else
            h=surface(X+r(1,p)-delta(1),Y+r(2,p)-delta(2),Z+r(3,p)-delta(3),cdb);
        end
        set(h,'edgecolor','none');
end
hold off;
% set(gcf, 'Position', [0 0 1920, 1080]); %<- Set size
% %set(gcf, 'renderer', 'opengl');

subplot(3,3,[4])
[counts,centers] = hist(speedsS*10*30,200);
%semilogy(centers, counts, 'ro', 'MarkerFace', 'r');
semilogy(centers, smooth(counts), 'b-');
xlabel('Distribution of Particle Speeds (units/second)');
xlim([0,max(.15*10*30,speedsS(end)*10*30)]);

title(['CsCl Crystal Structure (equal sized ions)' char(10) ...
    char(10)...
    'Computation Time: ' datestr(compTime/86400, 'DD:HH:MM:SS.FFF') char(10) ...%'GPUTemp: ' num2str(GpuT) ' Celcius' char(10) ...
    char(10) ...
    'Simulation Time: ' datestr(iteration/30/86400, 'HH:MM:SS.FFF') char(10) ...
    'Current Step: ' num2str(maxNum) char(10) ...
    'Number of Particles: ' num2str(numParticles) char(10) ...
    char(10) ...
    'Nucleating until 64 particles' char(10) ...
    'Annealed growth past ' num2str(annealNum) ' particles' char(10) ...
    'Currently cooling crystal with ' num2str(ceil(maxNum/4)) ' sink particles.' char(10) ...
    'Heated walls (2% increase in speed per bounce).' char(10) ...
    'Global speed limit of ' num2str(speedLimit*10*30) ' units/second'])

subplot(3,3,7)
plot(speedsS*10*30, 'b.');%arrayfun(@(it) norm(r(:,it)-rl(:,it)),1:numParticles));
hold on
plot([0,numParticles],[coldThreshold*10*30,coldThreshold*10*30],'r-')
plot([numParticles*(1-gasFraction)],[coldThreshold*10*30],'rx')
plot([numParticles*(1-gasFraction2)],[coldThreshold*10*30],'rx')
plot([0,numParticles],[annealMedianSpeed*10*30,annealMedianSpeed*10*30],'c-')
plot([numParticles*(.5)],[annealMedianSpeed*10*30],'cx')
hold off
ylim([0,max(.15*10*30,speedsS(end)*10*30)]);
xlim([0,numParticles]);
xlabel('All particles (sorted by speed)')
ylabel('Particle velocities')
%drawnow();
% saveas(gcf,['H:\MatlabOutput\CsClSimFrames\frames\Frame' num2str(iteration,'%05i') '.png']);
%fighand = gcf;
end

