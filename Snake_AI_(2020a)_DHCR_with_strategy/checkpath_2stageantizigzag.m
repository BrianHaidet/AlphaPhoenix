%there are two methods that this file uses to reconstruct the hamiltonian
%cycle. first, it checks to see if the turn the snake WANTS to take splits
%the hamcycle into two closed loops. if so, it looks for a location where
%both loops have a flat edge to each other and splices the loops together.

%if that fails, there's a special method for a "loop of two" where a single
%line of two nodes was isolated and needs to be re-fused to tha path.

%if that fails, then there's a more expensive algorythm that attempts to
%draw a brand new hamiltionian cycle by expanding the current path into 
%unclaimed regions. It's not vry smart, but it does ocasionally succeed
%(but normally leaves little one-off missing nodes everywhere and doesn't
%complete.)

%if none of these methods solve for a new hamiltionian path, the snake
%follows the old hamiltionian path.

%I'm very sure that somewhere in this file there are some missing minus
%signs or some flipped indeces to matrices or vectors because i sometimes
%see the snake fail to repair the path in a way that I believe it should
%know how, but as you can see, there are an awful lot of IFs and (-)s in
%this file, and I lacked the patience to find every glitch when working on
%this initially. Apparently whatever sometimes fails simply causes this
%file to return no hamiltonian path instead of a wrong or illegal
%hamiltonian path, and that was good enough at the time. if you find
%anything, god you must be bored, but if you do, let me know!!  :)

hypsnake=[nextstepinds,snake];
newcycle=[]; % populated if sucessful

% map cycle #1 (the one with the snake)
oldcutoffpointer_pathind=find(hampathinds==nextstepinds);
cycle1=hampathinds(oldcutoffpointer_pathind:end);
%map cycle #2 (without the snake)
cycle2=hampathinds(1:oldcutoffpointer_pathind-1);
if mod(length(cycle2),2)==1
    disp("it's broken")
end
%does cycle2 close? (AND isn't a 2-node line!)
if (sum(abs(coords(cycle2(1))-coords(cycle2(end))))==1) && length(cycle2)>2 %yes it closes
    cycle1fill=zeros(l);
    cycle1fill(cycle1)=1;
    hypfield=zeros(l);
    hypfield(hypsnake)=1;
    hashperim=10*(cycle1fill-hypfield)+~cycle1fill;
    [hitx,hity]=find(conv2(hashperim,[1,1;1,1])==22);
    for c=1:length(hitx)
        %find out if the adjacent parts of the paths are "flat" ie. connectable
        %for each (manually)
        %find candidate coords
        candidatesite=[hitx(c),hity(c)]+[-1,-1;0,-1;-1,0;0,0];
        candidatesiteinds=inds(candidatesite);
        candidatechains=[0,0,0,0];%candidates belong to cycle1 (0) or cycle2 (1)
        %where does each point?
        candidatepointers=[0,0,0,0];
        cyloc=[0;0;0;0];
        for p=1:4
            if cycle1fill(inds(candidatesite(p,:)))==1
                cyloc(p)=find(cycle1==candidatesiteinds(p,:));
                candidatepointers(p)=cycle1(mod(cyloc(p),length(cycle1))+1);
            else
                candidatechains(p)=1;
                cyloc(p)=find(cycle2==candidatesiteinds(p,:));
                candidatepointers(p)=cycle2(mod(cyloc(p),length(cycle2))+1);
            end
        end
        matchers=intersect(candidatesiteinds,candidatepointers);
        if length(matchers)==2%they match!
            
            if sum((matchers(1)==candidatesiteinds)&candidatechains') % if matchers(2) belongs to cycle 1
                cy2ind=sum((matchers(1)==candidatesiteinds).*cyloc);
                cy1ind=sum((matchers(2)==candidatesiteinds).*cyloc);
            else
                cy1ind=sum((matchers(1)==candidatesiteinds).*cyloc);
                cy2ind=sum((matchers(2)==candidatesiteinds).*cyloc);
            end
            newcycle=[cycle1(mod((1:cy1ind-1)-1,length(cycle1))+1);cycle2(mod(cy2ind-1:cy2ind+length(cycle2)-2,length(cycle2))+1);cycle1(cy1ind:end)];
            break;
        end
    end
else%no it does not close
    cycle1save=cycle1;
    cycle1=[repmat([-1],l,1);cycle1(1:end-length(snake));repmat([-1],l,1)];
    if length(cycle2) <=900 %try to fix the thing
        makingprogress=false;
        madeprogress=false;
        spliced=false;
        pi=1;%segment being spliced
        while true
            spliced=false;
            if abs(cycle2(pi)-cycle2(pi+1))==1 %splicing vertical segment
                pc1=find(cycle1==cycle2(pi)-l);%look to the left of pi
                if length(pc1)==1% if that spot IS on chain 1
                    if cycle1(pc1+1)==cycle2(pi+1)-l
                        newcycle=[cycle1(1:pc1) ; cycle2(pi) ; cycle2(pi+1) ; cycle1(pc1+1:end)];
                        madeprogress=true;
                        spliced=true;
                    elseif cycle1(pc1-1)==cycle2(pi+1)-l
                        newcycle=[cycle1(1:pc1-1) ; cycle2(pi+1) ; cycle2(pi) ; cycle1(pc1:end)];
                        madeprogress=true;
                        spliced=true;
                    end
                end
                if spliced==false %look to the right if the left isnt on chain 1
                    pc1=find(cycle1==cycle2(pi)+l);%look to the right of pi
                    if length(pc1)==1 % if that spot IS on chain 1
                        if cycle1(pc1+1)==cycle2(pi+1)+l
                            newcycle=[cycle1(1:pc1) ; cycle2(pi) ; cycle2(pi+1) ; cycle1(pc1+1:end)];
                            madeprogress=true;
                            spliced=true;
                        elseif cycle1(pc1-1)==cycle2(pi+1)+l
                            newcycle=[cycle1(1:pc1-1) ; cycle2(pi+1) ; cycle2(pi) ; cycle1(pc1:end)];
                            madeprogress=true;
                            spliced=true;
                        end
                    end
                end
            else %splicing horizontal segment
                if ~(mod(cycle2(pi),l)==1) %if on top row, don't look up
                    pc1=find(cycle1==cycle2(pi)-1);%look to the up of pi
                    if length(pc1)==1 % if that spot IS on chain 1
                        if cycle1(pc1+1)==cycle2(pi+1)-1
                            newcycle=[cycle1(1:pc1) ; cycle2(pi) ; cycle2(pi+1) ; cycle1(pc1+1:end)];
                            madeprogress=true;
                            spliced=true;
                        elseif cycle1(pc1-1)==cycle2(pi+1)-1
                            newcycle=[cycle1(1:pc1-1) ; cycle2(pi+1) ; cycle2(pi) ; cycle1(pc1:end)];
                            madeprogress=true;
                            spliced=true;
                        end
                    end
                end
                if spliced==false%look to the down if the up isnt on chain 1
                    if ~(mod(cycle2(pi),l)==0) %if on bottom row, don't look down
                        pc1=find(cycle1==cycle2(pi)+1);%look to the down of pi
                        if length(pc1)==1 % if that spot IS on chain 1
                            if cycle1(pc1+1)==cycle2(pi+1)+1
                                newcycle=[cycle1(1:pc1) ; cycle2(pi) ; cycle2(pi+1) ; cycle1(pc1+1:end)];
                                madeprogress=true;
                                spliced=true;
                            elseif cycle1(pc1-1)==cycle2(pi+1)+1
                                newcycle=[cycle1(1:pc1-1) ; cycle2(pi+1) ; cycle2(pi) ; cycle1(pc1:end)];
                                madeprogress=true;
                                spliced=true;
                            end
                        end
                    end
                end
            end
            if spliced==true
                cycle2(pi:pi+1)=[];
                cycle1=newcycle;
            else
                pi=pi+2;
            end
            if isempty(cycle2)
%                 disp('stage1')
                break;
            end
            if pi>length(cycle2)
                if madeprogress
                    pi=1;
                    madeprogress=false;
%                     %%plotting for debug
%                     figure(3)
%                     plot(snakecoords(:,2),snakecoords(:,1),'Color',[0 1 0],'LineWidth',15)
%                     xlim([0.5,l+.5]);
%                     ylim([0.5,l+.5]);
%                     axis square
%                     set(gca,'Ydir','reverse')
%                     set(gca,'Color','k')
%                     hold on
%                     plot(optimalPath(:,2),optimalPath(:,1),'Color',[1 0 0],'LineWidth',5)
%                     ncc2=coords(cycle1);
%                     plot(ncc2(:,2),ncc2(:,1),'Color',[0 .3 0],'LineWidth',3)
%                     hold off
                else
%                     disp('stage1 - FAIL')
                    break;
                end
            end
            
        end
        if ~isempty(cycle2)
            makingprogress=false;
            madeprogress=false;
            spliced=false;
            pi=l+1;%segment being spliced
            while true
                spliced=false;
                if abs(cycle1(pi)-cycle1(pi+1))==1 %splicing vertical segment
                    pc2a=find(cycle2==cycle1(pi)-l);%look to the left of pi
                    pc2b=find(cycle2==cycle1(pi+1)-l);%look to the left of pi+1
                    if (length(pc2a)==1)&&(length(pc2b)==1)% if those spot ARE on chain 2
                        newcycle=[cycle1(1:pi) ; cycle2(pc2a) ; cycle2(pc2b) ; cycle1(pi+1:end)];
                        madeprogress=true;
                        spliced=true;
                    end
                    if spliced==false %look to the right if the left isnt on chain 1
                        pc2a=find(cycle2==cycle1(pi)+l);%look to the right of pi
                        pc2b=find(cycle2==cycle1(pi+1)+l);%look to the right of pi+1
                        if (length(pc2a)==1)&&(length(pc2b)==1)% if those spot ARE on chain 2
                            newcycle=[cycle1(1:pi) ; cycle2(pc2a) ; cycle2(pc2b) ; cycle1(pi+1:end)];
                            madeprogress=true;
                            spliced=true;
                        end
                    end
                else %splicing horizontal segment
                    if ~(mod(cycle1(pi),l)==1) %if on top row, don't look up
                        pc2a=find(cycle2==cycle1(pi)-1);%look to the up of pi
                        pc2b=find(cycle2==cycle1(pi+1)-1);%look to the up of pi+1
                        if (length(pc2a)==1)&&(length(pc2b)==1)% if those spot ARE on chain 2
                            newcycle=[cycle1(1:pi) ; cycle2(pc2a) ; cycle2(pc2b) ; cycle1(pi+1:end)];
                            madeprogress=true;
                            spliced=true;
                        end
                    end
                    if spliced==false%look to the down if the up isnt on chain 1
                        if ~(mod(cycle1(pi),l)==0) %if on bottom row, don't look down
                            pc2a=find(cycle2==cycle1(pi)+1);%look to the down of pi
                            pc2b=find(cycle2==cycle1(pi+1)+1);%look to the down of pi+1
                            if (length(pc2a)==1)&&(length(pc2b)==1)% if those spot ARE on chain 2
                                newcycle=[cycle1(1:pi) ; cycle2(pc2a) ; cycle2(pc2b) ; cycle1(pi+1:end)];
                                madeprogress=true;
                                spliced=true;
                            end
                        end
                    end
                end
                if spliced==true
                    cycle2([pc2a,pc2b])=[];
                    cycle1=newcycle;
                else
                    pi=pi+1;
                end
                if isempty(cycle2)
%                     disp('stage2')
                    break;
                end
                if pi>length(cycle1)-2*l
                    if madeprogress
                        pi=l+1;
                        madeprogress=false;
%                         %%plotting for debug
%                         figure(3)
%                         plot(snakecoords(:,2),snakecoords(:,1),'Color',[0 1 0],'LineWidth',15)
%                         xlim([0.5,l+.5]);
%                         ylim([0.5,l+.5]);
%                         axis square
%                         set(gca,'Ydir','reverse')
%                         set(gca,'Color','k')
%                         hold on
%                         plot(optimalPath(:,2),optimalPath(:,1),'Color',[1 0 0],'LineWidth',5)
%                         ncc2=coords(cycle1);
%                         plot(ncc2(:,2),ncc2(:,1),'Color',[0 .3 .7],'LineWidth',3)
%                         hold off
                    else
%                         disp('stage2 - FAIL')
                        break;
                    end
                end
                
            end
        end
        if madeprogress
            newcycle=[newcycle(l+1:end-l); cycle1save(end-length(snake)+1:end)];
        else
            newcycle=[];
        end
    end
end