function [flip] = pres_DotFlick_local(p, ps, blocknum)
%present each flicker
%v2 - draws all dots in each frame (and not before presentation)
%   p       = parameters
%   ps      = screen parameters

%% some presets
% RDK
RDK.dot.movdir      = [-2 0; 2 0; 0 -2; 0 2]; % movement direction of dots
RDK.dot.vel         = p.dot_size/5; % movement speed of dots
RDK.dot.size        = p.dot_size;
RDK.dot.num         = p.dot_num;
RDK.dot.col         = p.dot_color;

% position of fixation cross
crs.xCoords         = [-p.crs_dims(1) p.crs_dims(1) 0 0];
crs.yCoords         = [0 0 -p.crs_dims(2) p.crs_dims(2)];
crs.allCoords       = [crs.xCoords; crs.yCoords];


%% preparing presentation
% creat matrix with on off frames
framemat = repmat([ones(1,p.dot_frames(1)) zeros(1,p.dot_frames(2))],1,ceil(p.exp_blframes/sum(p.dot_frames)));
framemat = framemat(1:p.exp_blframes); 

% index frames at which the position is changed
% posshiftmat = diff([framemat framemat(end)]);   % only for each onset
posshiftmat = framemat;                             % for each on-frame
posshiftmat = double([false diff(framemat)==1]);    % only for first on frame
framemat_nan= framemat; framemat_nan(framemat==0)=nan;

% determine drawing area
RDK.shape = round(...
    [ps.xCenter+...
    [-p.dot_area(1)*ps.windowRect(3)/2/(p.scr_imgmultipl/2) +p.dot_area(1)*ps.windowRect(3)/2/(p.scr_imgmultipl/2)];...
    ps.yCenter+...
    [-p.dot_area(2)*ps.windowRect(4)/2/(p.scr_imgmultipl/2) +p.dot_area(2)*ps.windowRect(4)/2/(p.scr_imgmultipl/2)]]...
    );

% minimum difference
RDK.dot.mindist = RDK.dot.size/2;

% preallocate all dot positions
RDK.dot.pos = nan(p.dot_num,2);

% initial position of all dots
for i_d = 1:RDK.dot.num
    while MinDistOK(RDK,i_d)
        RDK.dot.pos(i_d,:,1)=InitDotPosFunction(RDK);
    end
end

% shift positions from center into 4 quadrants
% [top left, top right, bottom left, bottom right, top left, ...]
% define ofsett for quadrants
ps.quadshift = [-ps.xCenter/2, -ps.yCenter/2;...
    +ps.xCenter/2, -ps.yCenter/2;...
    -ps.xCenter/2, +ps.yCenter/2;...
    +ps.xCenter/2, +ps.yCenter/2];

%% start trigger schedule
Datapixx('Open')
Datapixx('StopAllSchedules');
Datapixx('SetDoutValues', 0);
Datapixx('RegWrRd');    % Synchronize DATAPixx registers to local register cache


%%%%%% this works
% outsignal
% doutWave = [PRPX_TrigOutConv(3) 0];
% bufferAddress = 8e6;
% Datapixx('WriteDoutBuffer', doutWave, bufferAddress);
% 
% %start schedule
% samplesPerTrigger = size(doutWave,2);
% triggersPerFrame = 1;
% samplesPerFrame = samplesPerTrigger * triggersPerFrame;
% framesPerTrial = numel(framemat)/p.scr_imgmultipl;       
% samplesPerTrial = samplesPerFrame * framesPerTrial;
% Datapixx('SetDoutSchedule', 0, [samplesPerFrame, 2], samplesPerTrial, bufferAddress, samplesPerTrigger);
% Datapixx('StartDoutSchedule');
% Datapixx('RegWrVideoSync');
% disp(Datapixx('GetDoutStatus'));
%%%%%%% works end

%%%&&&& own attempt
% doutWave = [255 zeros(1,numel(framemat)/2-1) 2^0 zeros(1,119)...
%     2^1 zeros(1,119)...
%     2^2 zeros(1,119)...
%     (2^3) zeros(1,119)...
%     (2^4) zeros(1,119)...
%     (2^5) zeros(1,119)...
%     (2^6) zeros(1,119)...
%     (2^7) zeros(1,119)...
%     zeros(1,numel(framemat)/2-120*8)];% ones(1,numel(framemat)).*PRPX_TrigOutConv(4)];

% set up trigger vector (1 trigger per frame --> on for a whole frame)
doutWave = repmat([1 0 0 0],1,numel(framemat)/4);% ones(1,numel(framemat)).*PRPX_TrigOutConv(4)];
doutWave2 = doutWave(1:4:end);

% set up trigger vector (2 trigger per frame --> on for half a frame then set to 0)
doutWave = repmat([1 0 0 0 0 0 0 0],1,numel(framemat)/4);% ones(1,numel(framemat)).*PRPX_TrigOutConv(4)];
doutWave2 = doutWave(1:8:end);

% set up trigger vector (4 trigger per frame --> on for a forth of a frame then set to 0)
doutWave = repmat([1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0],1,numel(framemat)/4);% ones(1,numel(framemat)).*PRPX_TrigOutConv(4)];
doutWave2 = doutWave(1:16:end);


bufferAddress = 8e6;
Datapixx('WriteDoutBuffer', doutWave(:), bufferAddress);
samplesPerFrame = 4;
samplesPerTrial = numel(framemat);
% samplesPerTrigger = 2;

% start schedule with one trigger per frame
% Datapixx('SetDoutSchedule', 0, [samplesPerFrame, 2], samplesPerTrial,bufferAddress);%, samplesPerTrigger);

% start schedule with two trigger per frame
% Datapixx('SetDoutSchedule', 0, [samplesPerFrame*2, 2], samplesPerTrial*2,bufferAddress);%, samplesPerTrigger);
% Datapixx('StartDoutSchedule');

% start schedule with 4 trigger per frame
Datapixx('SetDoutSchedule', 0, [samplesPerFrame*4, 2], samplesPerTrial*4,bufferAddress);%, samplesPerTrigger);
% Datapixx('StartDoutSchedule');

% Datapixx('RegWrVideoSync');
% disp(Datapixx('GetDoutStatrun_DotFlick_480(1,1)us'));


%% actual presentation
flipnum = numel(framemat)/p.scr_imgmultipl;
prog_label = linspace(0,100,11);
prog_index = round(linspace(0,flipnum,11));
i_frame = 1;

fprintf(1,'\npresentation... ')
starttime=GetSecs;
for i_flip = 1:flipnum
    % move dots for move frames
    if any(prog_index==i_flip)
        fprintf(1,' %1.0f',prog_label(prog_index==i_flip))
    end
    
    % draw first quadrant (upper left)
    % check whether movement is necessary
    if posshiftmat(i_frame)==1
        RDK.dot.pos= DotMoveFunction(RDK);
    end
    % draw dots
    Screen('DrawDots', ps.window, round(RDK.dot.pos+ps.quadshift(1,:))'.*framemat_nan(i_frame), ...
        RDK.dot.size, RDK.dot.col, [], 0);
    % draw fixation cross
    Screen('DrawLines', ps.window, crs.allCoords+ps.quadshift(1,:)', ...
        p.crs_width, p.crs_col, [ps.xCenter ps.yCenter], 2);
    i_frame = i_frame+1;

    % draw second quadrant (upper right)
    % check whetherDatapixx('RegWrVideoSync' movement is necessary
    if posshiftmat(i_frame)==1
        RDK.dot.pos= DotMoveFunction(RDK);
    end

    % draw dots
    Screen('DrawDots', ps.window, round(RDK.dot.pos+ps.quadshift(2,:))'.*framemat_nan(i_frame), ...
        RDK.dot.size, RDK.dot.col, [], 0);
    % draw fixation cross
    Screen('DrawLines', ps.window, crs.allCoords+ps.quadshift(2,:)', ...
        p.crs_width, p.crs_col, [ps.xCenter ps.yCenter], 2);
    i_frame = i_frame+1;
    
    % draw third quadrant (lower left)
    % check whether movement is necessary
    if posshiftmat(i_frame)==1
        RDK.dot.pos= DotMoveFunction(RDK);
    end
    % draw dots
    Screen('DrawDots', ps.window, round(RDK.dot.pos+ps.quadshift(3,:))'.*framemat_nan(i_frame), ...
        RDK.dot.size, RDK.dot.col, [], 0);
    % draw fixation cross
    Screen('DrawLines', ps.window, crs.allCoords+ps.quadshift(3,:)', ...
        p.crs_width, p.crs_col, [ps.xCenter ps.yCenter], 2);
    i_frame = i_frame+1;
    
    % draw fourth quadrant (lower right)
    % check whether movement is necessary
    if posshiftmat(i_frame)==1
        RDK.dot.pos= DotMoveFunction(RDK);
    end
    % draw dots
    Screen('DrawDots', ps.window, round(RDK.dot.pos+ps.quadshift(4,:))'.*framemat_nan(i_frame), ...
        RDK.dot.size, RDK.dot.col, [], 0);
    % draw fixation cross
    Screen('DrawLines', ps.window, crs.allCoords+ps.quadshift(4,:)', ...
        p.crs_width, p.crs_col, [ps.xCenter ps.yCenter], 2);
    i_frame = i_frame+1;

%     % draw dots
%     Screen('DrawDots', ps.window, round(RDK.dot.pos+ps.quadshift(2,:))'.*framemat_nan(i_frame), ...
%         RDK.dot.size, RDK.dot.col, [], 0);
%     % draw fixation cross
%     Datapixx('RegWrRd');    Screen('DrawLines', ps.window, crs.allCoords+ps.quadshift(2,:)', ...
%         p.crs_width, p.crs_col, [ps.xCenter ps.yCenter], 2);
%     i_frame = i_frame+1;
%     
%     % draw third quadrant (lower left)
%     % check whether movement is necessary
%     if posshiftmat(i_frame)==1
%         RDK.dot.pos= DotMoveFunction(RDK);
%     end
%     % draw dots
%     Screen('DrawDots', ps.window, round(RDK.dot.pos+ps.quadshift(3,:))'.*framemat_nan(i_frame), ...
%         RDK.dot.size, RDK.dot.col, [], 0);
%     % draw fixation cross
%     Screen('DrawLines', ps.window, crs.allCoords+ps.quadshift(3,:)', ...
%         p.crs_width, p.crs_col, [ps.xCenter ps.yCenter], 2);
%     i_frame = i_frame+1;
%     
%     % draw fourth quadrant (lower right)
%     % check whether movement is necessary
%     if posshiftmat(i_frame)==1
%         RDK.dot.pos= DotMoveFunction(RDK);
%     end
%     % draw dots
%     Screen('DrawDots', ps.window, round(RDK.dot.pos+ps.quadshift(4,:))'.*framemat_nan(i_frame), ...
%         RDK.dot.size, RDK.dot.col, [], 0);
%     % draw fixation cross
%     Screen('DrawLines', ps.window, crs.allCoords+ps.quadshift(4,:)', ...
%         p.crs_width, p.crs_col, [ps.xCenter ps.yCenter], 2);
%     i_frame = i_frame+1;

    
    % check for button press
    if i_flip == 3000
        doutWave(i_flip+2*4)=PRPX_TrigOutConv(9);
        Datapixx('WriteDoutBuffer', doutWave(:), bufferAddress);        
    end
    
    % start trigger schedule
    if i_flip == 1
%         Datapixx('RegWrVideoSync');
    end
    % flip
    [flip.VBLTimestamp(i_flip) flip.StimulusOnsetTime(i_flip) flip.FlipTimestamp(i_flip) flip.Missed(i_flip) flip.Beampos(i_flip)]=...
        Screen('Flip', ps.window, 0);
    if doutWave2(i_flip)
        lptwrite(1,doutWave2(i_flip),500)
    end
    
       
    if i_flip == 1
        starttime=GetSecs;
    end
end
Screen('Flip', ps.window, 0);

end

%% additional functions
function [IsOK]=MinDistOK(RDK,DotNr)
IsOK = any(sqrt(sum((RDK.dot.pos(1:end ~= DotNr,:)-repmat(RDK.dot.pos(DotNr,:),RDK.dot.num-1,1)).^2,2))<RDK.dot.mindist) ||...
    any(isnan(RDK.dot.pos(DotNr,:)));
end

function [DotPos]=InitDotPosFunction(RDK)
DotPos = [randsample(RDK.shape(1,1):RDK.shape(1,2),1), randsample(RDK.shape(2,1):RDK.shape(2,2),1)];
end

function [DotPos]=DotMoveFunction(RDK)
mov_index = randsample(1:size(RDK.dot.movdir,1),RDK.dot.num,'true'); % random direction
mov_vector = cell2mat(arrayfun(@(x) RDK.dot.movdir(x,:), mov_index,'UniformOutput',false)').*RDK.dot.vel; % displacement in direction
DotPos = RDK.dot.pos+mov_vector;

% outside of range?
index = DotPos(:,1)<RDK.shape(1,1);
DotPos(index,1)=-(abs(DotPos(index,1)-RDK.shape(1,1)))+RDK.shape(1,2);
index = DotPos(:,1)>RDK.shape(1,2);
DotPos(index,1)=(abs(DotPos(index,1)-RDK.shape(1,2)))+RDK.shape(1,1);
index = DotPos(:,2)<RDK.shape(2,1);
DotPos(index,2)=-(abs(DotPos(index,2)-RDK.shape(2,1)))+RDK.shape(2,2);
index = DotPos(:,2)>RDK.shape(2,2);
DotPos(index,2)=(abs(DotPos(index,2)-RDK.shape(2,2)))+RDK.shape(2,1);
end





