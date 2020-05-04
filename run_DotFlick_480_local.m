function [] = run_DotFlick_480_local(sub,flag_block)
% []=run_DotFlick(sub,flag_block)
% script to present flickering dots with 480 Hz
% v2 - drawing within each frame (used for estimation of timing)
% v2 - also includes attempt to send trigger
%   inputs:
%       sub                 = subject number
%       flag_block          = set block with which to start (default: 1)


if nargin < 1
    help run_DotFlick
    return
elseif nargin == 1
    p.flag_block = 1;
end

%% parameters
% troubleshooting: sub = 1; flag_block = 1;
% designvolmov
p.sub               = sub;              % subject number
p.flag_block        = flag_block;       % block number to start
p.blocknum          = 2;                % number of blocks
p.exp_blframes      = 4800;             % frames per block (480 Hz * 30s = 14400 frames)

% screen
p.scr_screen        = 1;                % screen number (should be 1)
p.scr_res           = [1920 1080];      % resolution [1920 1080]
p.scr_refrate       = 120;              % refresh rate in Hz (e.g. 85)
p.scr_imgmultipl    = 4;                % Propixx image multiplier
p.scr_color         = [0.05 0.05 0.05]; % color of screen

% stimuli
p.dot_num           = 100;              % number of dots
p.dot_size          = 10;               % size of dots in pixel
p.dot_color         = [1 1 1];          % on color
p.dot_area          = [2/3 2/3];        % area in which dots can be presented [533 400];
p.dot_frames        = [16 16];          % on off frames [16 16] --> 15 Hz

% fixation cross
p.crs_color         = [0.6 0.6 0.6];    % color of fixation cross
p.crs_dims          = [10 10];          % dimension of fixation cross
p.crs_width         = 4;                % width of fixation cross
p.crs_col           = [0.85 0.85 0.85]; % color of fixation cross


% logfiles
p.log.path          = '/home/pc/matlab/user/christopher/test_VPixx/logfiles';



%% initiate psychtoolbox and propixx
% psychtoolbox
fprintf(1,'PSYCHTOOLBOX: adjusting video settings...requires some seconds')

% Propixx
Datapixx('Open');
Datapixx('SetPropixxDlpSequenceProgram', 2); % 2 for 480, 5 for 1440 Hz, 0 for normal
Datapixx('RegWrRd');
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
try ppdev_mex('Close', 1); % open triggerport
end
try ppdev_mex('Open', 1); % open triggerport
end
    

% psychtoolbox
Screen('ConfigureDisplay', 'Scanout', p.scr_screen, 0, p.scr_res(1),p.scr_res(2),p.scr_refrate);
% use ResolutionTest to query all possible resolutions
WaitSecs(10); % allow screen changes to take place
[ps.window, ps.windowRect] = PsychImaging('OpenWindow', p.scr_screen, p.scr_color);         % open window
Screen('ColorRange', ps.window,1);                                                          % restrict color values to maximum value of 1                       
[ps.screenXpixels, ps.screenYpixels] = Screen('WindowSize', ps.window);                     % get window size
[ps.xCenter, ps.yCenter] = RectCenter(ps.windowRect);
% if resolution smaller 1920*1080, center positions are off!
if p.scr_res(1)<ps.screenXpixels || p.scr_res(2)<ps.screenYpixels
    ps.xCenter = p.scr_res(1)/2;
    ps.yCenter = p.scr_res(2)/2;
end

Screen('BlendFunction', ps.window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);                   % set blending modes
% SetMouse(ps.screenXpixels+200, 100, 2)                                                      % hide mouse
RestrictKeysForKbCheck([]);                                                                 % allows input from all keys
timing.refreshrate=1/Screen('GetFlipInterval',ps.window);
fprintf(1,'done!\n')
ListenChar(-1)                                                                              % block button presses to matlab window STRG + C to exit and ListenChar(0) at end
Priority(1); % set priority to real time

%% presentation
for i_bl = p.flag_block:p.blocknum
    
    [timing.experiment{i_bl}]=pres_DotFlick_480_local(p, ps, i_bl);    % present flicker dots
%     [timing.experiment{i_bl}]=pres_DotFlick_480_v3(p, ps, i_bl);    % present flicker dots
        % diganostics on psychoolbox output
    % see https://github.com/Psychtoolbox-3/Psychtoolbox-3/wiki/FAQ:-Explanation-of-Flip-Timestamps
    figure;
    % VBLTimestamp: plot time when buffer swap/vertical blanking starts -->
    % image is "sent" to graphics buffer
    subplot(3,2,1); plot(diff(timing.experiment{i_bl}.VBLTimestamp));title('diff VBLTimestamp','FontSize',8)
    % StimulusOnsetTime: actual time when actual first scanline is started,
    % image is startde to be drawn on screen/beamer; VBLTimestamp + constant
    % VBL time
    subplot(3,2,2); plot(diff(timing.experiment{i_bl}.StimulusOnsetTime));title('diff StimulusOnsetTime','FontSize',8)
    % FlipTimestamp:  timestamp taken at the end of Flip's execution;
    % estimate of how long flip took
    subplot(3,2,3); plot(diff(timing.experiment{i_bl}.FlipTimestamp));title('diff FlipTimestamp','FontSize',8)
    % difference is an estimate of systems jitter: high values are bad...
    subplot(3,2,4); plot(timing.experiment{i_bl}.FlipTimestamp-...
        timing.experiment{i_bl}.VBLTimestamp); title('diff FlipTimestamp-VBLTimestamp | 1/refresh rate','FontSize',8)
    % Missed: compares VBLTimeStamp against the requested timestamp of when
    % bufferswap should happen (depending on refrate etc.) 1.05*estimate =
    % missed
    subplot(3,2,5); plot((timing.experiment{i_bl}.Missed));title('Missed | negative = cool; positive = miss','FontSize',8);
        
    if i_bl ~= p.blocknum
        pres_break(p, ps, 1);                % break
    else
        Screen('TextSize', ps.window, 15);
        
        if p.scr_res(1)<ps.screenXpixels || p.scr_res(2)<ps.screenYpixels % if resolution smaller 1920*1080, center positions are off! --> workaround
            DrawFormattedText(ps.window, 'E N D E\n\nVielen Dank!','center', 'center', p.dot_color,[], [], [], [], [],[0 0 p.scr_res]);
        elseif p.scr_imgmultipl == 4 % if beamer is run with 480 Hz
            DrawFormattedText(ps.window, 'E N D E\n\nVielen Dank!','center', 'center', p.dot_color,[], [], [], [], [],[p.scr_res./2 p.scr_res]);
        else
            DrawFormattedText(ps.window, 'E N D E\n\nVielen Dank!','center', 'center', p.dot_color);
        end
        Screen('Flip', ps.window, 0);
        WaitSecs(2);
    end
    
    % save logfiles
    save(sprintf('%sVP%02.0f_timing',p.log.path,p.sub),'timing','p')
end

fprintf(1,'\n\nENDE\n')
sca

ListenChar(0) % reset to allow input in matlab

% close Propixx
Datapixx('SetPropixxDlpSequenceProgram', 0);
Datapixx('RegWrRd');
Datapixx('close');
ppdev_mex('Close', 1); % open triggerport
end