% 3D molecular dynamics (GPU vectorized)
% by Brian Haidet for AlphaPhoenix
% published 12/15/2018
% CC non-commercial, attribution

% Don't copy this straight into homework or something ridiculous - I'm
% posting this so people can hopefully learn from it! It's not the cleanest
% code, but I added a few more comments in the areas that need
% explaining. And deleted all the extra bits of commented-out code that had
% built up. Feel free to ask more questions on youtube here!
% https://youtu.be/6DlRsPo-dxY

% Skim through the program before running - it will automatically start
% saving frame files and backup runtime files when you start the program,
% so be ready for that (actually it'll probably glitch out if you don't have
% the folders already, but still). It also needs "plotter.m' or
% "plotterFast.m" in the same MATLAB path folder to read said frame files 
% and output pictures.

close all;
clear;
clc;
tic;
if exist('SavePointB.mat', 'file') == 2 % if there is a simulation already running
    if exist('SavePointA.mat', 'file') == 2
        load('SavePointA','t');
        tA=t;
        load('SavePointB','t');
        tB=t;
        if tA<tB % pick the oldest save file (rewind up to 200 iterations before starting again)
            load('SavePointA');
        else
            load('SavePointB');
        end
    end
else %if there's not a save file, go through initialization routines
    
    % ---- usar vars (end-progrom conditions) ---------------------------------
    finalNum = 4096 *4%2^14*10;      % maximum number of particles (stop early if you hit it)
    nucleateNum = 64;   % number before flipping settings from time limited to temp limited
    maxNum=2;
    
    annealing=false;
    annealNum=1024; %above 2048, annealing instead of instachilling
    annealMedianSpeed=.022; %cool until this is the median speed of the simulation
    finalAnnealRate=1E-5; %change in anneal median speed per frame during final cool
    % ------------------`s it will add a small time and coresponding memory
    % until it thinks it's done.
    % -------------------------------------------------------------------------
    
    % ---- define initial positions -------------------------------------------
    
    %load('seed64.mat');                            % contains 'charge', 'r'
    r=[1;1;1];  %will have a 3xn list of all particl positions
    charge=[1]; %will have a 1xn list of all particle charges (+-1)
    rl=r;       %will have a 3xn list of the LAST particle positions for determining speed
    numParticles=size(r,2);
    numParticlesSeed=numParticles;
    nucleating=true;
    frozenThreshold=.01;
    sinkNum=1;
    
    % ---- define box from (0,0,0) to (boxWall,boxWall,boxWall) ---------------
    displFun=@(np) (np)^(1/3) *2;
    lFun=@(disl) disl*1.5;
    displ=displFun(nucleateNum);
    l=lFun(displ);              % box side length
    
    dt=.001;                                       % timestep
    dt2=dt^2;                                      % timestep squared
    gpuIterLoops=15;
    forceEq=@(r,c) max(min( 2400*r.^-7 - 4800*r.^-13 - 4800*c.*r.^-2,10000),-10000); % max force set to prevent explosions
    chillDamp=.99;                        % velocity removed every 15 timesteps
    speedLimit = .4                                % simulation-level speed limit
    hotWallsMax=1.02; % 1% increase in speed upon bouncing
    
    
    % ---- add new particles --------------------------------------------------
    gasFraction=.05;                        %fraction of the particles allowed to be "hot"
    gasFraction2=.0025;
    numEnergeticAllowed=floor(numParticles*gasFraction);
    coldThreshold=.06;                     % in units per dt, what is considered "cold" and therefore part of the solid?
    
    launchSpeed=.05;                        % in units per dt
    newCharge=@(charge) charge(end)*-1;
    
    % ---- plotting and feedback ----------------------------------------------
    framerate=60;   %currently useless
    azim = 90+45;   %starting camera angle
    alti = 22.5;
    % computation time
    compTime=0; %seconds
    
% time iterator %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t=0;
stop=false;
iteration=0;
end


% computation time
lastTime=now;


% time iterator %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while stop==false
%     if iteration>14000
%         break;
%     end
    tic
    iteration = iteration +1
    t=t+dt*gpuIterLoops;
    
    % ==== Start GPU Gack =================================================
    rG=gpuArray(r);
    rlG=gpuArray(rl);
    cG=gpuArray(charge);

    
    chunkSize=ceil(8192^2/numParticles); %this is the size of data to send to the GPU at once. I run out of memory (6GB) around 9000 particles so I put 8192 here as my max process unit. 

    for o=1:gpuIterLoops %do it gpuIterLoops times - send chunks of data to the GPU for seperate processing so as to not overload gpu memory
        % ---------------------------- calculate forces -------------------
        totForces=gpuArray(zeros(3,numParticles));
        for i=1:ceil(numParticles/chunkSize) %for each chunk
            cInds=(i-1)*chunkSize+1 : min((i)*chunkSize,numParticles);%indeces of particles to calculate (it's ALL particles until I have over 8192 at once, then it splits up by memory. by 16384, it needs 4 trips to the GPU per timestep
            
            numPcurr=length(cInds);
            IP=rG(:,cInds)'*rG(:,:);
            forces=gpuArray([]);
            forces=bsxfun(@times,reshape(forceEq(sqrt(abs(bsxfun(@plus,sum(rG(:,cInds)'.^2,2),sum(rG(:,:).^2,1))-2*IP)),cG(cInds)*cG(:)'),1,numPcurr,numParticles),bsxfun(@minus,reshape(rG(:,:),3,1,numParticles),rG(:,cInds))); %this is the magic line that does all the distance and force calculations between all the particles. it was a pain to write, and weirdly it actually ran faster once when the force summation on the next line wasn't added in at the same time so I left it as two lines.
            totForces(:,cInds)=sum(forces,3);
            
        end
        % ---------------------------- Energy Verlet: ---------------------
        rNewG=2*rG-rlG+dt2*totForces;
        rlG=rG;
        rG=rNewG;
    end
    % -------------------------------- Measure it -------------------------
    speeds=gather(sqrt(sum((rG-rlG).^2,1)));
    speedsS=sort(speeds);
    % -------------------------------- Chill it ---------------------------

    if ~annealing
        chillPs=gpuArray(1:sinkNum);%gpuArray(1:2:numParticles/10);
        rlG(:,chillPs)=rlG(:,chillPs)+(rG(:,chillPs)-rlG(:,chillPs)).*chillDamp; % cut velocity of sink particles to 1%
    else
        if speedsS(ceil(numParticles/2))>annealMedianSpeed
            chillPs=gpuArray(1:sinkNum);%gpuArray(1:2:numParticles/10);
            rlG(:,chillPs)=rlG(:,chillPs)+(rG(:,chillPs)-rlG(:,chillPs)).*chillDamp; % cut velocity of sink particles to 1%
        end
    end
    % -------------------------------- Center it --------------------------
    deltaRecenter=repmat(mean(rG(:,1),2)-[l/2;l/2;l/2],1,numParticles);
    rG=rG-deltaRecenter;
    rlG=rlG-deltaRecenter;
    % -------------------------------- Speed limit ------------------------

    if speedsS(end)>speedLimit %check if particles are going too fast and if they are, modify rl(previous position) to slow them down
        for eParticle=find(speeds>speedLimit)
            rlG(:,eParticle)=rG(:,eParticle)+(rlG(:,eParticle)-rG(:,eParticle))*speedLimit/sqrt(sum((rlG(:,eParticle)-rG(:,eParticle)).^2));
        end
    end
    % -------------------------------- Add new particles ------------------

    if numParticles<maxNum %this system for adding particles to the simulation over time (and in a couple different modes) gets kinda soupy. I can take some pretty heavy liberties with the ifs and loops in this part of the program cause its computation time is still tiny compared to the force calculation above.
        if speedsS(end-numEnergeticAllowed)<coldThreshold
            for newptry=1:ceil(numParticles/100)
                if numParticles<maxNum
                    % pick a random spot to put the new particle
                    theta = 2*pi*rand();
                    phi = acos(2*rand()-1);
                    launchInLoc = [cos(theta)*sin(phi);sin(theta)*sin(phi);cos(phi)]*displ+[l;l;l]*.5;
                    if min(sum(abs(bsxfun(@minus,rG,gpuArray(launchInLoc))),1))>3 %if nothing in the way (within a 6x6x6 box around the prospective location)
                        %add a particle
                        numParticles=numParticles+1;
                        lastParticlet=t;
                        rG=[rG,launchInLoc];
                        if nucleating
                            rlG=[rlG,(rG(:,end)+[cos(theta)*sin(phi);sin(theta)*sin(phi);cos(phi)]*launchSpeed)]; % previous location (aim inwards)
                        else
                            rlG=[rlG,rG(:,end)+rand(3,1)*launchSpeed];
                            displ=displFun(numParticles);
                            l=lFun(displ); % launch-in spots (a bit bigger than the "radius" of crystal)
                        end
                        charge=[charge;newCharge(charge)];
                        
                        if numParticles<finalNum*.5
                            numEnergeticAllowed=floor(numParticles*gasFraction);
                        else
                            gasFraction=gasFraction2;
                            numEnergeticAllowed=floor(numParticles*gasFraction);
                        end
                        %                 if numParticles>2000
                        %                     disp(['add particle ' num2str(numParticles)]);
                        %                 else
                        if mod(numParticles,100)==0
                            disp(['add particle ' num2str(numParticles)]);
                        end
                    end
                else
                    break;
                end
                
            end
        end
    end
    % -------------------------------- Identify runaway particles ---------
    runaways=gather(find(sum((rG<0)+(rG>l),1)>0)); %stuff outside the simulation
    % -------------------------------- Bring it home to the CPU -----------
    r=gather(rG);
    rl=gather(rlG);
    % ==== End GPU Gack ===================================================

    % ==== Heat the walls =================================================
    for eParticle=runaways %if particle escaped, throw it back in from the other side

        %add bouncy walls (particles move 2% faster every bounce)
        hotWalls=1+(hotWallsMax-1)*(speedsS(end)<speedLimit/2); %stop heating the walls if anything is going faster than half the speed limit
        if r(1,eParticle)<0
            rl(1,eParticle) = r(1,eParticle) - hotWalls*abs(r(1,eParticle)-rl(1,eParticle));
        elseif r(1,eParticle)>l
            rl(1,eParticle) = r(1,eParticle) + hotWalls*abs(r(1,eParticle)-rl(1,eParticle));
        end
        if r(2,eParticle)<0
            rl(2,eParticle) = r(2,eParticle) - hotWalls*abs(r(2,eParticle)-rl(2,eParticle));
        elseif r(2,eParticle)>l
            rl(2,eParticle) = r(2,eParticle) + hotWalls*abs(r(2,eParticle)-rl(2,eParticle));
        end
        if r(3,eParticle)<0
            rl(3,eParticle) = r(3,eParticle) - hotWalls*abs(r(3,eParticle)-rl(3,eParticle));
        elseif r(3,eParticle)>l
            rl(3,eParticle) = r(3,eParticle) + hotWalls*abs(r(3,eParticle)-rl(3,eParticle));
        end
    end
    
    % ==== Stage/step control =============================================
    if numParticles>=maxNum % if max number of particles hit
        if annealing || (numParticles == annealNum)
            if speedsS(end) < coldThreshold % and the nucleus is cold, not frozen
                if numParticles < finalNum % and the final number has not been reached
                    sinkNum=floor(numParticles/2);
                    maxNum=min(maxNum*2,finalNum);
                    chillDamp=.1;
                    annealing=true;
                else % final number has been reached - freeze it completely
                    annealMedianSpeed=annealMedianSpeed-finalAnnealRate; %start by freezing it slowly
                    if annealMedianSpeed<=frozenThreshold
                        annealing=false;
                        frozenThreshold=frozenThreshold/10; %end by freezing it completely
                    end
                end
            end
        else
            if speedsS(end) < frozenThreshold % and the nucleus is frozen
                if numParticles < finalNum % and the final number has not been reached
                    if maxNum>=nucleateNum
                        nucleating=false;
                        chillDamp=.9;
                    end
                    sinkNum=floor(numParticles/2);
                    maxNum=min(maxNum*2,finalNum);
                else % final number has been reached
                    break; % end the simulation - it's done and cold
                end
            end
        end
    end
    
    % ==== output =========================================================
    %it saves a file for every frame, then tells the plotter to run, and
    %what frame number's file to read. this is probably best suited to an
    %SSD if you have one
    currentTime=now;
    compTime = compTime + (currentTime-lastTime)*86400;
    lastTime=currentTime;
    if mod(iteration,200)==1
        pause(1)
        GpuT=nvsmiQueryGpuTemperature;
        vars={'cG','chillPs','deltaRecenter','forces','IP','rG','rlG'};
        clear(vars{:});
        save('SavePointA.mat');
    end
    if mod(iteration,200)==101
        pause(1)
        GpuT=nvsmiQueryGpuTemperature;
        vars={'cG','chillPs','deltaRecenter','forces','IP','rG','rlG'};
        clear(vars{:});
        save('SavePointB.mat');
    end
    save(['c:\MatlabOutput\CsClSimFrames\data\data' num2str(iteration,'%05d') '.mat'], 'r','charge','maxNum','speedsS','iteration','compTime','l','GpuT');
    
    % ==== plotting and live feedback =====================================
    %if toc>framerate
    if mod(iteration, 10)==1%draw a frame every 10 iterations (I actually ran this at 300 i think)
        clf
        plotterFast(iteration);
        set(gcf, 'Position', [100 100 1920*.85, 1080*.85]); %<- Set size
        drawnow()
        
    end
    toc
end
vars={'cG','chillPs','deltaRecenter','forces','IP','rG','rlG'};
clear(vars{:});
save(['finalData' num2str(now()) '.mat'])
clear
close all
MovieMakerIndividualSaveCombiner

