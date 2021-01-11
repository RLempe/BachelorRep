function run_LuckyFeat(sub,train,isolum,start_block)
%simple ERP-Experiment with four target, distractor and/or baseline stimuli; no flicker
    
    % to first show a few trials without isoluminance adjustment and maxially dark dot
    %   run_ERP(sub,cond)
    % to run the full experiment
    %   run_ERP(sub,cond,1,1)    

    % Input arguments:
    % sub           = subject number
    % cond          = 1 or 2 (target distractor mapping)
    % train         = 0 or 1 (dont or do training)
    % isolum        = 0 or 1 (dont or do isoluminance adjustment)
    % start_block   = block to start with
    
    % Task: detect dot orientation within target (left or right)
    % Design:
    %   1
    % 4   2   target+distractor positions (0 is no T or D)
    %   3
    % old conditions
    % TLDV
    % target lateral (right), distractor vertikal (random) 21 / 23
    % target lateral (left), distractor vertikal (random) 41 / 43
    % TVDL
    % target vertikal (random), distractor lateral (right) 12 / 32
    % target vertikal (random) distractor lateral (left) 14 / 34
    % TLDN
    % target lateral (right), no distractor 20
    % target lateral (left), no distractor 40
    % TNDL
    % no target, distractor lateral (right) 02
    % no target, distractor lateral (left) 04
    % BL (double!!)
    % no target, no distractor 00
    
% FIX!!! enable timestamp

%% Parameter zur Testung ohne Funktionseingabe
sub = 98;
train = 1;
isolum = 0;
start_block =1;


%% Parameters
% Screen Parameters
Screen('Preference', 'SkipSyncTests', 1);

Testing = 0;
p.scr_screen = 2;
%p.scr_refrate = 120;
p.scr_refrate = 60;
%p.scr_res = [1920 1080];
p.scr_res = [2560 1440];
p.background_col = [0.05 0.05 0.05];
p.isolum_background = [0.5 0.5 0.5];
%p.isolum_background = [0.1 0.1 0.1];

% Design Parameters   
%p.trials_per_cond   = 80; %100 must be a even number to enable even distribution of vertical positions
%p.conditions        = {'TLrDV', 'TLlDV','TVDLr','TVDLl','TLrDN','TLlDN','TNDLr','TNDLl','BL'};

%p.conditions = {'p1', 's1', 'p2', 's2', 'p3', 's3', 'p4', 's4', 'p5', 's5', 'p6', 's6'};
p.conditions = {'p1', 'p2', 'p3', 'p4', 'p5', 'p6', 's1', 's2', 's3', 's4', 's5', 's6'};

p.trials_per_probe = 72;
p.trials_per_search = 108;


p.trials_total = p.trials_per_probe*(1/2)*length(p.conditions) + p.trials_per_search*(1/2)*length(p.conditions);
p.n_blocks = 24; %willkürlich festgelegt
p.trials_per_block = p.trials_total/p.n_blocks;
p.train_trials = 48; %nach Gaspelin et al.

% Stimulus definition
p.stim_start_cols   = [0 1 0; 1 .4 0];
%p.stim_start_cols   = [0 1 0; 1 .4 0];   % initial colors of stimului (later adjusted in Isolum-Script); later asigned to target and distractor; col1 is also BL color; !!script only works for mixed colors of max 2 rgb values!!
%p.isolum_defaults   = [0 0.34118 0; 0.50588 0 0.50588]; % green and pink isolum on .2 background
%p.isolum_defaults   = [0 0.16471 0; 0.29412 0 0]; %green and red on .1 background
p.isolum_defaults   = [0.0000 0.1647 0.0000;0.1804 0.0722 0.0000]; %green and 1/.4 orange on .1 background
%p.isolum_defaults   = [0 0.16471 0; 0.2 0.06 0]; %green and 1/.3 orange on .1 background
%p.isolum_defaults   = [0 1 0; 1 .3 0];
p.stim_cols_labels  = {'gruen';'rot'};


p.stim_shapes       = {'Raute';'Quadrat';'Dreieck';'Schiefquadrat';'Kreis';'Sechseck'};% shape  of stimuli; later asigned to target and distractor (col1 goes with shape1);
% p.stim_shapes       = {'Quad_links';'Quad_rechts'};% Versuch, die beiden schiefen Quadrate zu programmieren


p.dot_lum_max       = .05;%.05;       %maximal luminance change for training; also used for default
p.dot_lum_min       = .01;     %minimum luminance change for training
p.dot_lum_steps     = 5;        %steps between min and max luminance for training
p.dot_range         = 0.005;     %during the actual trial presentation, dot luminance will go one p.dot_range up and down; set to 0 of you dont want the range 
p.thresh            = 0.85;      %performance threshold (percent correct) for training

p.fix_col           = [.8 .8 .8];      
p.fix_size          = 15;
p.fix_width         = 3;


% Degree visual angle stuff
p.distance          = 120;
p.screen_cm         = [63.5 36];
p.stim_size_dva     = 2.4; %pilot 2.2 %source 1.93
p.stim_dist_dva     = 4.2; %pilot 3.1 %source 3.27
p.dot_dist_dva      = 0.4; %pilot 0.4 %source 0.73
p.dot_size_dva      = 0.26; %pilot 0.26 %source 0.36

p.resp_key          = {'LeftArrow','RightArrow','Space'};
p.trg_start         = 201;                         
p.trg_stop          = 202;                         

% Timing (Quelle Matthias: 900-1100 prefix, jitter 20, 100 stim, resp-1100 postfix
% p.jitter            = [0 .100 .200 .300 .400 .500];
% p.pre_fix_min       = .500; % jitter added
% p.post_fix_min      = 1.2;  % equals response window
% p.stim_duration     = .100;      
% p.ITI               = .8; 
% % total trial duration is 500 + 100 + 1200 + 800 = 2.6 sec + jitter! [2.6-3.1 sec]

p.jitter            = [0 .250 .500 .750 1];
p.pre_fix_min       = .500; % jitter added
p.post_fix_min      = 1.2;  % equals response window
%p.stim_duration     = .100;


p.probe_buchstabendauer = 1;
p.probe_hashtagdauer = 1;
p.stim_duration     = 1; 
p.ITI               = .550; 
% total trial duration is 500 + 100 + 1200 + 550 = 2.35 sec + jitter! [2.35-3.35 sec]

% Logpath
% p.logpath           = '/home/pc/matlab/user/maria/ERP/Logs/';
p.logpath = 'R:\MATLAB\BachelorRep\Logs\';
format shortg; starttime = clock;
p.timestamp         = [num2str(starttime(1)),'-',num2str(starttime(2)),'-',num2str(starttime(3)),'_',num2str(starttime(4)),'-',num2str(starttime(5))];
%p.timestamp         = '';

%Auskommentiert fürs testen
% %% Define defaults
% if nargin<5
%     start_block=1;
% end
% if nargin<4
%     isolum = 0;
% end
% if nargin<3
%     train = 0;
% end
% if nargin<2
%     cond=1;
% end

%% Trialstruct
rand('state',sub);
trialstruct = ERP_trialstruct(p);
save(sprintf('%ssub%d_trialstruct_%s.mat',p.logpath,sub,p.timestamp),'trialstruct');

%% Isoluminance
if isolum
    [p.stim_cols]=ERP_IsolCol([p.isolum_background;p.stim_start_cols],...
        5,8,0);
else
    p.stim_cols = p.isolum_defaults;  
end

%restrict maximum luminace change if too large for darkest color value
[xmin,ymin]=find(p.stim_cols==min(p.stim_cols(find(p.stim_cols))));        % find the indices of the smalles value
color_ratio = p.stim_cols(xmin,ymin)/max(p.stim_cols(xmin,:));             % calculate the ratio between the min value and the max value of the same color
if (p.dot_lum_max+p.dot_range)*color_ratio > (min(p.stim_cols(find(p.stim_cols))))       % multply dot lum with this ratio for checking (because we later also use this ratio for luminance substraction)
    p.dot_lum_max = (min(p.stim_cols(find(p.stim_cols))))/color_ratio-p.dot_range;
end
%% Setups
%Psychtoolbox
sca;
fprintf(1,'PSYCHTOOLBOX: adjusting video settings...\n')
PsychDefaultSetup(2);     
PsychImaging('PrepareConfiguration');   
PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
AssertOpenGL

% %Propixx
% Datapixx('Open');
% Datapixx('SetPropixxDlpSequenceProgram', 0); %120 Hz
% Datapixx('StopAllSchedules');
% Datapixx('SetDoutValues', 0);
% Datapixx('RegWrRd');
% p.bufferAddress = 8e6;

% %Open LPT trigger port
% try ppdev_mex('Close',1);
% end
% try ppdev_mex('Open',1);    
% end
% lptwrite(1,0);

% Für Screen Fehlermeldung auskommentiert
% %Test Resolution
% temp = Screen('Resolution',p.scr_screen);
% if any([temp.width~=p.scr_res(1), temp.height~=p.scr_res(2), temp.hz~=p.scr_refrate])
%     try Screen('ConfigureDisplay', 'Scanout',p.scr_screen, 0, p.scr_res(1),p.scr_res(2),p.scr_refrate);
%         fprintf('...adjusting screen settings to %1.0f X %1.0f with %1.0f Hz... takes some seconds...',p.scr_res(1),p.scr_res(2),p.scr_refrate)
%         WaitSecs(10)
%     catch
%         fprintf(['!!!!\n...not able to adjust screen settings to requested values' ...
%             '\ncurrent settings: %1.0f X %1.0f with %1.0f Hz\n!!!!\n'],...
%             temp.width, temp.height, temp.hz)
%     end
%         
% else
%     fprintf('...screen settings are fine: %1.0f X %1.0f with %1.0f Hz',p.scr_res(1),p.scr_res(2),p.scr_refrate)
% end

%Supress bright PTB screen
Screen('Preference','VisualDebugLevel', 0);

%Open Window
if Testing == 1
[ps.window, ps.windowRect] = PsychImaging('OpenWindow', p.scr_screen, p.background_col,[0 0 960 540]);
else
[ps.window, ps.windowRect] = PsychImaging('OpenWindow', p.scr_screen, p.background_col);    % open window
end 

Screen('BlendFunction', ps.window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);  % set blending modes

[ps.screenXpixels, ps.screenYpixels] = Screen('WindowSize', ps.window);    % get window size

AssertGLSL

%FIX: ifi=Screen('GetFlipInterval',window)
%% Pre Computations

%Compute pixel values out of degree visual angle [ext_width ext_height]=visualangle([pix],[dist],[res1 res2],[width height],visangle)
[~, p.stim_size]=ERP_visualangle(p.stim_size_dva,120,p.scr_res,p.screen_cm,1); p.stim_size = round(p.stim_size);
[~, p.stim_dist]=ERP_visualangle(p.stim_dist_dva,120,p.scr_res,p.screen_cm,1); p.stim_dist = round(p.stim_dist);
[~, p.dot_dist]=ERP_visualangle(p.dot_dist_dva,120,p.scr_res,p.screen_cm,1); p.dot_dist = round(p.dot_dist); 
p.dot_dist2 = [p.dot_dist 0]; %FIX
[~, p.dot_size]=ERP_visualangle(p.dot_size_dva,120,p.scr_res,p.screen_cm,1); p.dot_size = round(p.dot_size);

% [~, fix_dva]=ERP_visualangle(p.fix_size,120,p.scr_res,p.screen_cm); 
% [~, fixw_dva]=ERP_visualangle(p.fix_width,120,p.scr_res,p.screen_cm);

%Stimulus positions
[ps.xCenter, ps.yCenter] = RectCenter(ps.windowRect);                      % get center coordinate
p.positions = [ps.xCenter, ps.yCenter-p.stim_dist; ...                        % compute the four center positions
    ps.xCenter+p.stim_dist, ps.yCenter;...
    ps.xCenter, ps.yCenter+p.stim_dist;...
    ps.xCenter-p.stim_dist, ps.yCenter];                     
p.stim_rect = [0 0 p.stim_size p.stim_size];                                % create a stimulus area that is larger than the squared stimulus size to be big enough for Raute shape
% reicht rechnerisch auch aus für Dreieck und Sechseck
p.pos_rects=zeros(4,4);                                                    % center this on the four positions
for i = 1:4
    p.pos_rects(i,:)=CenterRectOnPoint(p.stim_rect,p.positions(i,1),p.positions(i,2));
end

%Circle Positions
p.circle_rad = sqrt(p.stim_size^2/pi); p.circle_rad = round(p.circle_rad);
%[~, circle_dva]=ERP_visualangle(p.circle_rad,120,p.scr_res,p.screen_cm);
p.circle_rect = [0 0 p.circle_rad*2 p.circle_rad*2];
p.circle_rects=zeros(4,4); 
for i = 1:4
    p.circle_rects(i,:) = CenterRectOnPoint(p.circle_rect,p.positions(i,1),p.positions(i,2));
end

%Fixcross positions
p.fix_rects = [CenterRectOnPoint([0 0 p.fix_width p.fix_size],ps.xCenter, ps.yCenter);...
   CenterRectOnPoint([0 0 p.fix_size p.fix_width],ps.xCenter, ps.yCenter)]'; %create rects array for fixation cross, already in correct format for 'DrawTextures'

%Dot positions
p.dot_centers = zeros(4,2,4); % position 1-4 x xy x dot left or right
p.dot_rects = zeros(4,4,2);  % position 1-4 x rect coordinates x dot left or right
for po = 1:4
    for d = 1:2
    p.dot_centers(po,:,d) = p.positions(po,:) + (d*2-3) * p.dot_dist2; %add or substract dot_distance to stimuli positions, depending on dot left (1) or right (2)
    p.dot_rects(po,:,d) = CenterRectOnPoint([0 0 p.dot_size p.dot_size], p.dot_centers(po,1,d), p.dot_centers(po,2,d));
    end
end


p.target_shape = p.stim_shapes{1};
p.target_col = p.stim_cols(1,:);
p.target_col_label = p.stim_cols_labels{1};

p.distr_col = p.stim_cols(2,:);
p.distr_col_label = p.stim_cols_labels{2};
p.BL_col = p.target_col;
 




%Decode and define possible shapes for target and distractor (BL stimulus FIXED to CIRCLE now!!)
p.target_rot = 0;
switch p.target_shape 
    case 'Raute'
        p.target_rot = 45;
    otherwise
    fprintf('This shape is not defined!\n')
end


% p.distr_rot = 0;
% switch p.distr_shape
%     case 'Raute'
%         p.distr_rot = 45;
%     otherwise
%     fprintf('This shape is not defined!\n')
% end

%Create textures        %[discid, discrect] = CreateProceduralSmoothedDisc(windowPtr, width, height [, backgroundColorOffset =(0,0,0,0)] [, radius=inf] [, sigma=11] [,useAlpha=1] [,method=1])
%Normale Baseline (Kreis)
tex.kreis = CreateProceduralSmoothedDisc(ps.window, p.stim_size, p.stim_size, [], p.stim_size/2 ,1);

% schiefes Quadrat als Baseline
tex.quadrat = CreateProceduralSmoothedDisc(ps.window, p.stim_size, p.stim_size, [], p.stim_size ,1);

 %Dreieck oder Sechseck als Baseline (die beiden sind streng genommen egal
 %und können raus
tex.dreieck = CreateProceduralSmoothedDisc(ps.window, p.stim_size, p.stim_size, [], p.stim_size ,1);
tex.sechseck = CreateProceduralSmoothedDisc(ps.window, p.stim_size, p.stim_size, [], p.stim_size ,1);



tex.target = CreateProceduralSmoothedDisc(ps.window, p.stim_size, p.stim_size, [], p.stim_size ,1);
tex.distr = CreateProceduralSmoothedDisc(ps.window, p.stim_size, p.stim_size, [], p.stim_size,1);
tex.dot = CreateProceduralSmoothedDisc(ps.window, p.dot_size, p.dot_size, [], p.dot_size/2 ,1);
tex.fixbar = CreateProceduralSmoothedDisc(ps.window, p.fix_size, p.fix_size, [], p.fix_size ,1);

%% Prepare Keyboard
p.key_codes = [KbName(p.resp_key{1}) KbName(p.resp_key{2}) KbName(p.resp_key{3}) KbName('n') KbName('j')];
RestrictKeysForKbCheck(p.key_codes);                                                  % allows input from all keys
KbCheck;
ListenChar(-1)     % block button presses to matlab window STRG + C to exit and ListenChar(0) to end
Priority(1);       % set priority to real time

%% Training
p.dot_target_col = [0 0 0];
p.dot_distr_col = [0 0 0];
p.dot_BL_col = [0 0 0];
if train
    est = ERP_train(p,ps,trialstruct,tex);
    ListenChar(0)
    answer = input(sprintf('\n**************\nEnter a luminance Value!.\n**************\nIf you leave the input empty, it will take the estimated value of %.4f\nValue:',est));
    ListenChar(-1)
    if answer
        p.dot_lum_est = answer;
    else
        p.dot_lum_est = est;
    end
else
    p.dot_lum_est = p.dot_lum_max;
end
% Create luminance range for experimental trials
p.dot_range_levels = [p.dot_lum_est-p.dot_range p.dot_lum_est p.dot_lum_est+p.dot_range];       % create the three possible luminance changes
p.dot_range_arr = repmat(p.dot_range_levels,1,ceil(p.trials_total/length(p.dot_range_levels))); % repeat the values
p.dot_range_arr = Shuffle(p.dot_range_arr(1:p.trials_total));                                   % cut to trial amount and shuffle

%% Stimulus presentation

start_trial = p.trials_per_block*start_block-p.trials_per_block+1;
block_nr = start_block;
%Initialize structures for trial timing, trial responses, and blockwise behavioral analysis
timing(1:p.trials_total)=struct('time1',0,'time2',0,'time3',0,'time4',0);
response(1:p.trials_total)=struct('condition',nan,'hit',0,'RT',0,'error',0,'errorRT',0,'miss',0,'FA',0,'FART',0,'dFA',0,'dFART',0,'buchstaben',0); %FIX? include target true/false and distractor true/false to response struct?
behavior(1:p.n_blocks) = struct('hitrate',0,'errorrate',0,'FArate',0,'meanRT',0);

for t = start_trial:p.trials_total
    if mod(t,p.trials_per_block) == 1       %show start display before first trial of the block
        Screen('TextSize', ps.window, 40);
        DrawFormattedText(ps.window, ['Starte mit Block Nr. ' num2str(block_nr)],'center', 'center', p.fix_col);
        Screen('TextSize', ps.window, 25);
        DrawFormattedText(ps.window, ['Achte auf:\n' p.target_shape ' ' p.target_col_label],'center', 700, p.fix_col);
        Screen('Flip', ps.window, 0);
        WaitSecs(0.3);
        [~, ~, keyCode] = KbCheck; 
        while keyCode(KbName('space')) == 0
            [~, ~, keyCode] = KbCheck;
        end
        
        Screen('Flip', ps.window, 0);
%         datapixx_trig(253);
        fprintf(['\nStart Block ' num2str(block_nr) '\n']);
        WaitSecs(0.5);
    end
    
    %define new dot color for every trial
%     p.dot_target_col(p.target_col) = p.target_col(p.target_col) - ... %modify only the positions where there are positive RGB values
%         p.dot_range_arr(t)*(p.target_col(p.target_col)/max(p.target_col));  %take the current luminance change out of array and multiply it with the ratio of the RGB values (to keep the color ratio of mixed colors)
%     p.dot_distr_col(p.distr_col)   = p.distr_col(p.distr_col) - ...
%         p.dot_range_arr(t)*(p.distr_col(p.distr_col)/max(p.distr_col));
%     p.dot_BL_col(p.BL_col)         = p.BL_col(p.BL_col) - ...
%         p.dot_range_arr(t)*(p.BL_col(p.BL_col)/max(p.BL_col));
%     
    p.dot_target_col(find(p.target_col)) = p.target_col(find(p.target_col)) - p.dot_range_arr(t); %take luminance change out of p.dot_range_arr
    p.dot_distr_col(find(p.distr_col))   = p.distr_col(find(p.distr_col)) - p.dot_range_arr(t);
    p.dot_BL_col(find(p.BL_col))         = p.BL_col(find(p.BL_col)) - p.dot_range_arr(t);
    
    % TRIAL PRESENTATION
    [response(t), timing(t)] = ERP_present_trial(p,ps,trialstruct(t),tex);
    fprintf('.');
    
    if mod(t,p.trials_per_block) == 0   %after last trial of the block
        
%         datapixx_trig(254);
        
        % BEHAVIOR ANALYSIS
        behavior(block_nr) = ERP_eval_trials((1+t-p.trials_per_block):t, response);
        
        %save (overwrite) variables after every block
        save(sprintf('%ssub%d_trial_timing_%s.mat',p.logpath,sub,p.timestamp),'timing');
        save(sprintf('%ssub%d_all_responses_%s.mat',p.logpath,sub,p.timestamp),'response');
        save(sprintf('%ssub%d_behavior_%s.mat',p.logpath,sub,p.timestamp),'behavior');
        
        %display results
        Screen('TextSize', ps.window, 20); 
        DrawFormattedText(ps.window, sprintf('Richtige Reaktionen:  %1.0f %%',behavior(block_nr).hitrate*100),'center', 600, p.fix_col);
        DrawFormattedText(ps.window, sprintf('Fehlerrate:  %1.0f %%',behavior(block_nr).errorrate*100),'center', 650, p.fix_col);
        DrawFormattedText(ps.window, sprintf('Rate Falscher Alarme:  %1.0f %%',behavior(block_nr).FArate*100),'center', 700, p.fix_col);             
        DrawFormattedText(ps.window, sprintf('Reaktionszeit:  %1.0f ms',behavior(block_nr).meanRT*1000),'center', 750, p.fix_col);
        
        DrawFormattedText(ps.window, sprintf('Richtige Buchstaben:  %1.0f %%',t_behavior.richtige*100),'center', 750, p.fix_col);

        fprintf(1,'\n###\nRichtige Reaktionen:  %1.0f %%',behavior(block_nr).hitrate*100)
        fprintf(1,'\nFehlerrate:  %1.0f %%',behavior(block_nr).errorrate*100)
        fprintf(1,'\nRate Falscher Alarme:  %1.0f %%',behavior(block_nr).FArate*100)
        fprintf(1,'\nReaktionszeit:  %1.0f ms\n###\n',behavior(block_nr).meanRT*1000)
        
        fprintf(1,'\nRichtige Buchstaben:  %1.0f %%\n###\n',t_behavior.richtige*100)
        
        Screen('Flip', ps.window, 0);
        
        block_nr = block_nr+1;
        WaitSecs(0.3);
        KbWait;
    end
end

%End Experiment
save(sprintf('%ssub%d_parameters_%s.mat',p.logpath,sub,p.timestamp),'p');
Screen('TextSize', ps.window, 30);
DrawFormattedText(ps.window, 'Experiment beendet.\nVielen Dank fÃ¼r die Teilnahme!','center', 'center', p.fix_col);
Screen('Flip', ps.window, 0);
WaitSecs(0.3);
KbWait;

% %Close everything
% Datapixx('SetPropixxDlpSequenceProgram', 0);
% Datapixx('RegWrRd');
% Datapixx('close');
% ppdev_mex('Close', 1);
% ListenChar(0);
sca;

end

