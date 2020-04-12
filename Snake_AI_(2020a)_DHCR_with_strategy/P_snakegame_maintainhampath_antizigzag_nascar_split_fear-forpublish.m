% Snake AI: Dynamic Hamiltonian Cycle Repair (with some strategic stuff)
% by Brian Haidet for AlphaPhoenix
% published 4/11/2020
% CC non-commercial, attribution
% See readme for details

%clear
%clc
rendervideo=false
simpleview=true
%VIDEO__________________________________________
if rendervideo
    writerObj = VideoWriter(['myVideo' num2str(datenum(datetime('now'))) '.mp4'],'MPEG-4');
    writerObj.Quality  = 95;
    open(writerObj);
end
%________________________________________________

playableSpace=30;%edge length - must be even for my simple hampath generator to work
l=playableSpace;
field = zeros(l,l);

nodenum=prod(size(field));
nodenames=1:nodenum;
blankfield=field;
allblankfield=zeros(l);
head = ceil(nodenum/2+ceil(l/2));%head of snake
snake = [head,head+1,head+2]; %allnodes part of snake

coords=@(indnum) [mod(indnum-1,l)+1,ceil(indnum/l)];
inds=@(coordnum) coordnum(:,1)+(coordnum(:,2)-1)*l;

%drop apple in un-snaked region
openfield = nodenames;
openfield(snake)=[];
apple = openfield(ceil(rand()*length(openfield)));

%generate initial hamiltonian path
hampath=zeros(nodenum,1);
hamgrid=zeros(l,l);
hamgrid(1,:)=nodenum:-1:nodenum-l+1;
for n=1:l
    hamgrid(2:end,n)=n*(l-1)-l+2:n*(l-1);
    if mod(n,2)==0
        hamgrid(2:end,n)=flipud(hamgrid(2:end,n));
    end
end
hamgridflat=reshape(hamgrid,nodenum,1);
[~,hampathinds]=sort(hamgridflat);
headlocham=find(hampathinds==snake(1));
hampathinds=hampathinds(mod(headlocham:nodenum+headlocham-1,nodenum)+1);
hampath=coords(hampathinds);


nascarovershoot=3;


field=blankfield;
field(snake)=1;

optimalPath=[-50,-50];
needtoupdate=true;
paths=[-1,0;
    0,1;
    1,0;
    0,-1];
pathsind=[-1;l;1;-l];
pathsparity=[-1;1;-1;1];
paths8=[-1,-1;
    -1,0;
    -1,1;
    0,1;
    1,1;
    1,0;
    1,-1;
    0,-1;];

newcycle=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% THE GAME ITERATOR %%%%%%%%%%%%%%%%%%%%%%%%%%%
gameiter=0;
appleiters=[];%endgame stats
appletocs=[];%endgame stats
nascarmode=false;
tic;
while true
    gameiter=gameiter+1;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %AI part (choose move) %%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % draw currentMap
    field=blankfield;
    field(snake)=1;
    
    needtoupdate=false;
    if sum(sum(abs(coords(snake(end))-optimalPath)<1,2)==2)>0
        %disp('recalc route - tail moved')
        needtoupdate=true;
    end
    if ~isequal(coords(apple),optimalPath(1,:))
        %disp('recalc route - not seeking apple')
        needtoupdate=true;
    end
    if size(optimalPath,1)<=1
        %disp('recalc route - arrived')
        needtoupdate=true;
    end
    if needtoupdate
        %draw goal map
        goalm=allblankfield;
        goalm(apple)=1;
        %draw current path map
        hampathgrey=zeros(l);
        dta=find(hampathinds==apple);%disttoapple
        is=mod((dta+nodenum-1:-1:dta)-1,nodenum)+1;
        for i=1:nodenum
            hampathgrey(hampathinds(is(i)))=i;
        end
        % Running PathFinder
        optimalPath=ASTARPATH_mod4neigh_modeuclidian_modhampath2(ceil(snake(1)/l),mod(snake(1)-1,l)+1,field,goalm,1,hampathgrey);
        optimalPathAstar=ASTARPATH_mod4neigh(ceil(snake(1)/l),mod(snake(1)-1,l)+1,field,goalm,1);
        splitfield=field;
        
        splitfield(inds(optimalPathAstar))=1;
        segmented=bwlabel(~splitfield);
        numblobs=max(segmented(:));
        
        if numblobs>1 %if the path would clice the board in half or more, only make one kind of turn to get home
            nascarmode=nascarovershoot;
        else
            nascarmode=nascarmode-1;
        end
        if (nascarmode>0)
            delta=coords(snake(2))-coords(snake(1));
            [~,deltarotinit]=ismember(paths,delta,'rows');
            deltarotinit=find(deltarotinit);
            deltarot=(hampathgrey(1)<hampathgrey(2))*2-1;
            % figure deltarot special if apple is against a wall
            foundwall=false;
            for wallroti=1:9
                wallseg=inds(min(max(coords(apple)+paths8(mod(wallroti-1,8)+1,:),1),l));
                if field(wallseg) %find  wall next to the apple
                    foundwall=true;
                end
                if (~field(wallseg))&&foundwall
                    deltarot=(mod(hampathgrey(apple)-hampathgrey(snake(1))-1,nodenum)+1>mod(hampathgrey(wallseg)-hampathgrey(snake(1))-1,nodenum)+1)*2-1;
                    break;
                end
            end
            
            for roti=1:3
                rotcoord=min(max(coords(snake(1))+paths(1+mod(-1+deltarotinit+deltarot*roti,4),:),1),l);
                if field(inds(rotcoord))==0;
                    optimalPath=[rotcoord;coords(snake(1))];
                    break;
                end
            end
        end
        
        %---------------- applefearmode -------------------- %this is a
        %place where I know my algo could get better. "turn away from the
        %apple" is kinda kludgey and doesn't actually work if the snake is
        %already headed straight towards the apple
        chokepoint=[];
        fearmode=false;
        for cpi=2:length(optimalPathAstar)
            cpliberties=0;
            for cpj=1:4
                checksitecoords=optimalPathAstar(cpi,:)+paths(cpj,:);
                if (min(checksitecoords)>=1)&&(max(checksitecoords)<=l)
                    if field(inds(checksitecoords))==0
                        cpliberties=cpliberties+pathsparity(cpj);
                    end
                end
            end
            if abs(cpliberties) == 2
                chokepoint=optimalPathAstar(cpi,:);
                break;
            end
        end
        if ~isempty(chokepoint)%if there is a chokepoint
            testfield=field;
            testfield(inds(chokepoint))=1;
            testlabeled=bwlabel(~testfield);
            if max(testlabeled(:))>1 %if the chokepoint is isolating, enter apple fear mode
                fearmode=true;
                newtargetcoords=coords(snake(1))*2-optimalPathAstar(end-1,:);%look opposite A* - move away from the apple
                if (min(newtargetcoords)>=1)&&(max(newtargetcoords)<=l)%if new target is in bounds of map
                    if field(inds(newtargetcoords))==0%if there's no snake there
                        optimalPath=[newtargetcoords;coords(snake(1))];
                    end
                end
            end
        end
          
    end
    % End.
    nextStep=optimalPath(end-1,:);
    optimalPath=optimalPath(1:end-1,:);
    
    %%%%%%%%% is that smart????? %%%%%%%%%%
    needsfix=false;    
    %I think this section used to only recaclulate the paths once it
    %needed to happen, as in once the snake was forced to diverge from the
    %A* path or the tail moved out of the way, however I never got that
    %part working and jsut resolved the board on every move - it wasn't
    %actually that computationally expensive. I deleted a bunch of
    %commented lines here in the "else"s that apparently never worked
    if ~(inds(optimalPath(end,:))==hampathinds(1))% NOT~ (everything agrees and is cool)
        nextstepinds=inds(nextStep);%if you go there
        checkpath_2stageantizigzag; % seperate file
        if ~isempty(newcycle)
            hampathinds=newcycle;
        else
        end
    else % if YES everything's cool, then:
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %plotting part, pretty... %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %if length(snake)>1000
    %if you want, you can jump into the middle of a game in order to
    %diagnose something without watching the whole thing, just uncomment 
    %this line and the associated end
    if simpleview
        figure(7)
        snakecoords=coords(snake');
        applecoords=coords(apple);
        if fearmode
            plot(optimalPathAstar(:,2),optimalPathAstar(:,1),'Color',[.7 .7 .1],'LineWidth',3)
        else
            if nascarmode>0
                plot(optimalPathAstar(:,2),optimalPathAstar(:,1),'Color',[.6 .6 .6],'LineWidth',3)
            else
                plot(optimalPathAstar(:,2),optimalPathAstar(:,1),'Color',[.3 .3 .6],'LineWidth',3)
            end
        end
        xlim([0.5,l+.5]);
        ylim([0.5,l+.5]);
        axis square
        set(gca,'Ydir','reverse')
        set(gca,'Color','k')
        set(gca,'YTickLabel',[]);
        set(gca,'XTickLabel',[]);
        set(gca,'YTick',[]);
        set(gca,'XTick',[]);
        hold on
        plot(optimalPath(:,2),optimalPath(:,1),'Color',[.8 .3 .3],'LineWidth',3)
        ncc2=coords(hampathinds);
        plot(ncc2(:,2),ncc2(:,1),'Color',[.2 .4 .2]*.7,'LineWidth',1)
        if ~isempty(newcycle)
            ncc=coords(newcycle);
            plot(ncc(:,2),ncc(:,1),'Color',[.1 .2 .1]*.8,'LineWidth',1)
        end
        plot(snakecoords(:,2),snakecoords(:,1),'Color',[0 1 0],'LineWidth',16/4)
        plot(snakecoords(1,2),snakecoords(1,1),'o','Color','none','MarkerSize',16/4,'MarkerFaceColor',[0 1 0])
        plot(snakecoords(end,2),snakecoords(end,1),'s','Color','none','MarkerSize',21.5/4,'MarkerFaceColor',[0 1 0])
        plot(applecoords(2),applecoords(1),'o','Color','none','MarkerSize',20/4,'MarkerFaceColor',[1 0 0])
        hold off
    else
        %this is the window I set up to record everything for youtube in HD
        figure(7)
        set(gcf, 'Position', [1000 0 1920*1, 1080*1]); %<- Set size
        subplot(3,3,[2,3,5,6,8,9]);

        snakecoords=coords(snake');
        applecoords=coords(apple);
        if fearmode
            plot(optimalPathAstar(:,2),optimalPathAstar(:,1),'Color',[.7 .7 .1],'LineWidth',5)
        else
            if nascarmode>0
                plot(optimalPathAstar(:,2),optimalPathAstar(:,1),'Color',[.6 .6 .6],'LineWidth',5)
            else
                plot(optimalPathAstar(:,2),optimalPathAstar(:,1),'Color',[.3 .3 .6],'LineWidth',5)
            end
        end
        xlim([0.5,l+.5]);
        ylim([0.5,l+.5]);
        axis square
        set(gca,'Ydir','reverse')
        set(gca,'Color','k')
        set(gca,'YTickLabel',[]);
        set(gca,'XTickLabel',[]);
        set(gca,'YTick',[]);
        set(gca,'XTick',[]);
        hold on
        plot(optimalPath(:,2),optimalPath(:,1),'Color',[.8 .3 .3],'LineWidth',5)
        ncc2=coords(hampathinds);
        plot(ncc2(:,2),ncc2(:,1),'Color',[.2 .4 .2]*.7,'LineWidth',3)
        if ~isempty(newcycle)
            ncc=coords(newcycle);
            plot(ncc(:,2),ncc(:,1),'Color',[.1 .2 .1]*.8,'LineWidth',3)
        end
        plot(snakecoords(:,2),snakecoords(:,1),'Color',[0 1 0],'LineWidth',16)
        plot(snakecoords(1,2),snakecoords(1,1),'o','Color','none','MarkerSize',16,'MarkerFaceColor',[0 1 0])
        plot(snakecoords(end,2),snakecoords(end,1),'s','Color','none','MarkerSize',21.5,'MarkerFaceColor',[0 1 0])
        plot(applecoords(2),applecoords(1),'o','Color','none','MarkerSize',20,'MarkerFaceColor',[1 0 0])
        hold off

        subplot(3,3,[7])
        if ~isempty(appleiters)
            plot(appleiters,(1:length(appleiters))+3)
            title(['Game steps: ' num2str(appleiters(end))])
        end
        ylabel('Length of snake')
        xlabel('Number of steps')
        xlim([0,gameiter])

        subplot(3,3,[4])
        drawpathgrey=nodenum-mod(hampathgrey-hampathgrey(snake(1))-1,nodenum);
        drawpathgrey=repmat(drawpathgrey,1,1,3);
        drawpathgrey(:,:,2)=drawpathgrey(:,:,2)+(field*nodenum/2);

        imshow(drawpathgrey(:,:,:)./nodenum/2)
        title('Hamiltonian Cycle')
    end
    if rendervideo
        writeVideo(writerObj, getframe(gcf));
    end
    
    %%%%%%%% loop detection - ie. snake gets stuck in a loop and the game never ends
    if gameiter > 100000
        reported=zeros(1,900-3-1);
        reported(1:length(appleiters))=appleiters;
        appleiters=reported;
        disp('failed - hit 200k steps...')
        break;
    end
    
    %these are a few lines I didnt touch after the first few days.
    %something about resetting things so that the algorythm knows it needs
    %to recacluate everything every step. this originally wasn't supposed
    %to run on every iter
    nextstepinds=hampathinds(1);
    nextStep=coords(nextstepinds);
    hampathinds=[hampathinds(2:end);hampathinds(1)];
    optimalPath=[nextStep;coords(snake(1))];
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %not AI part, game stuff %%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if nextstepinds==apple
        %lengthen snake
        snake = [nextstepinds,snake];
        if length(snake)==nodenum
            disp(['Done! Cleared board in ' num2str(gameiter) ' moves.'])
            break;
        end
        %drop apple in un-snaked region
        field=blankfield;
        field(snake)=1;
        openfield = find(~field);
        apple = openfield(ceil(rand()*length(openfield)));
        
        %disp(['Apple eaten. Snake length ' num2str(length(snake))]);
        %keep track of efficiency stats
        appleiters=[appleiters gameiter];
        appletocs=[appletocs toc];
        %plot stats on execution time
                figure(2)
                yyaxis left
                plot(appleiters,1:length(appleiters))
                yyaxis right
                plot(appleiters(2:end),(appleiters(2:end)-appleiters(1:end-1))./(appletocs(2:end)-appletocs(1:end-1)))
                title([num2str(appletocs(end)) newline num2str(appleiters(end))])
        %disp(['positive ' num2str(sum(directions)) newline 'negative ' num2str(sum(~directions)) newline]);
    else
        %move snake without growing
        snake(2:end)=snake(1:end-1);
        snake(1)=nextstepinds;
    end
    
    
end

if rendervideo
    close(writerObj);
end