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

%print out to images
%close all;
v=VideoWriter(['outMovie' num2str(now()) '.mp4'],'MPEG-4');
v.FrameRate = 30;
open(v);

numFrames = length(dir('c:\MatlabOutput\CsClSimFrames\data'))

breakearly=35404-1
breakearly=3500

tic
iteration = 0;
while true
    if iteration==breakearly
        break;
    end
    iteration = iteration + 1;
    if exist(['c:\MatlabOutput\CsClSimFrames\data\data' num2str(iteration,'%05d') '.mat'],'file')
        load(['c:\MatlabOutput\CsClSimFrames\data\data' num2str(iteration,'%05d') '.mat'])
    else
        break;
    end
    clf;
    figure(1)
    set(gcf, 'Position', [0 0 1920, 1080]); %<- Set size
    pause(.02);
            plotter(iteration);
        drawnow()
        
%     plotter(iteration);
    writeVideo(v,getframe(gcf));
    disp(['Printing frame ' num2str(iteration) '/' num2str(numFrames) '   |   Est Completion Time: ' datestr(addtodate(now,floor((1000*toc/(iteration)*(numFrames-iteration))),'millisecond'))]);
end
close(v)
