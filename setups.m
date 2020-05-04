%% setups stefanie

% Psychtoolbox
fprintf(1,'PSYCHTOOLBOX: adjusting video settings...requires some seconds... \n')
sca
PsychDefaultSetup(2);
InitializePsychSound;

% Propixx
Datapixx('Open');
Datapixx('SetPropixxDlpSequenceProgram', 0); % 2 for 480, 5 for 1440 Hz, 0 for normal
Datapixx('StopAllSchedules');
Datapixx('SetDoutValues', 0);
Datapixx('RegWrRd');
p.bufferAddress = 8e6;

% set ltp trigger port
try ppdev_mex('Close',1);
end
try ppdev_mex('Open',1);
end

% Screen setup
tmp = Screen('Resolution',p.scr_screen);
if tmp.width ~=1920 || tmp.height ~= 1080 || tmp.hz ~=120
    Screen('ConfigureDisplay', 'Scanout', p.scr_screen, 0, p.scr_res(1),p.scr_res(2),p.scr_refrate);
    WaitSecs(10); % allow screen changes to take place
end
% use ResolutionTest to query all possible resolutions
[ps.window, ps.windowRect] = PsychImaging('OpenWindow', p.scr_screen, p.scr_color);         % open window
[ps.screenXpixels, ps.screenYpixels] = Screen('WindowSize', ps.window);                     % get window size
[ps.xCenter, ps.yCenter] = RectCenter(ps.windowRect);
% if resolution smaller 1920*1080, center positions are off!
if p.scr_res(1)<ps.screenXpixels || p.scr_res(2)<ps.screenYpixels
    ps.xCenter = p.scr_res(1)/2;
    ps.yCenter = p.scr_res(2)/2;
end

Screen('BlendFunction', ps.window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);    % set blending modes
% SetMouse(ps.screenXpixels+200, 100, 2)                                     % hide mouse
RestrictKeysForKbCheck([]);                                                  % allows input from all keys
KbCheck;
timing.refreshrate=1/Screen('GetFlipInterval',ps.window);
fprintf(1,'done!\n')
ListenChar(-1)                                                             % block button presses to matlab window STRG + C to exit and ListenChar(0) to end

% Initialize psychtoolbox audio port
PsychPortAudio('Close')
p.pahandle = PsychPortAudio('Open', [], [], [], p.snd.samprate, p.snd.nChannels);

%% setup RDK_demo

% initiate psychtoolbox and propixx
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

%% setup norman
% PROPixx and PsychToolbox setup
% psychtoolbox

% PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible'); % 32bit precision and alpha blending only working on newest gpu hardware, this command selects best compromise between both...but which?...first try without it
try ppdev_mex('Close', 1); % open triggerport
catch me
    disp(me)
end
try ppdev_mex('Open', 1); % open triggerport
catch me
    disp(me)
end

%% in function now
if MultImg == 4
    datapixxmode = 2; % !change this to '2' if projector is working properly again!
    vmod = '480Hz';
    ScrRes = ScrRes./2;
    FixCrDim = FixCrDim./2;
    ShapeDist = ShapeDist/2;
    ShapeSize = ShapeSize./2;
else
    datapixxmode = 0;
    vmod = [int2str(RefRate) 'Hz'];%'120Hz';
end

% screen setup
fprintf('PSYCHTOOLBOX: adjusting video settings...requires some seconds')
PsychDefaultSetup(2); % magic 
% Propixx
Datapixx('Open');
Datapixx('SetPropixxDlpSequenceProgram', datapixxmode); % 2 for 480, 5 for 1440 Hz, 0 for normal
Datapixx('RegWrRd');
PsychImaging('PrepareConfiguration');
% get number of available screens
screens=Screen('Screens');
if isempty(ScrNum) || all(screens == 0)
    ScrNum=max(screens);
end

% Query size of screen: % [screenXpixels, screenYpixels] =
% Screen('WindowSize', window); whats the difference?
screensize=Screen('Rect', ScrNum);

% adjust screen parameters if necessary, only possible on linux
if ~all(screensize(1,3:4) == PRPXres)
    Screen('ConfigureDisplay', 'Scanout', ScrNum, 0, PRPXres(1),PRPXres(2),RefRate); %'0' is the virtual screen output id?? sets up the target screen with prompted parameters
    WaitSecs(10); % allow screen changes to take place
    screensize=Screen('Rect', ScrNum);
end
% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(screensize);

% if resolution smaller 1920*1080, center positions are off!
% if ScrRes(1)<screensize(3) || ScrRes(2)<screensize(4)
%     xCenter = round(ScrRes(1)/2);
%     yCenter = round(ScrRes(2)/2);
% end
% allows input from all keys, just in case
RestrictKeysForKbCheck([]);  
fprintf('done!\n')
% block button presses to matlab window STRG + C to exit and ListenChar(0) at end
ListenChar(-1) 
% set priority to real time
Priority(1); 

%% prepare drawing of visual presentation to back buffer
% window = Screen('OpenWindow', ScrNum, BckGrCol.*255);%, [0,0,800,600]); % 1 = main screen (0|2 -> main screen with menu bar|second monitor), color = 0 (white|[1 1 1 a]), rect = default (fullscreen|[0,0,width,height])
window = PsychImaging('OpenWindow',ScrNum,BckGrCol);
Screen('ColorRange', window,1); % clamping color range to 1 also has good effects on graphic card communication...sometimes
% set blending modes, only works with new opengl stuff
% Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);                   % try without first 
framerate=Screen('NominalFramerate', window); % should be 120Hz
if framerate ~= RefRate
    warning('measured screen refresh rate of %s does not correspond to queried rate of %s...presentation assumes the latter.',num2str(framerate),num2str(RefRate))
    framerate= RefRate;
end
% calculate the number of presentation frames
framesPerTrial = MultImg*framerate*TrDur/1000;
flipsPerTrial = framesPerTrial/MultImg;
if mod(flipsPerTrial,1)~=0 % adapt trial duration if necessary
    flipsPerTrial = ceil(flipsPerTrial);
    framesPerTrial = flipsPerTrial*MultImg;
    TrDur = framesPerTrial/(framerate*MultImg)*1000;
    fprintf('\ntrial duration adapted to %g ms\n',TrDur)
end
