function [p,ps] = exp_setup(p)
% exp_setup is a function to initialize ProPixx, Psychtoolbox visuals'and the LTP port.
% Doens't include the setup of the Psychtoolbox Audio Port! (see
% hear_tresh_lite as example for audio port setup)
%
%   Input Arguments:
%   p.scr_screen        :   screen number e.g. 1
%   p.scr_res           :   screen resolution e.g. [1920 1080]
%   p.scr_refrate       :   refresh rate e.g. 120 or 480
%   p.background_col    :   background color e.g [0.3 0.3 0.3]

% Psychtoolbox
sca
fprintf(1,'PSYCHTOOLBOX: adjusting video settings...requires some seconds... \n')
PsychDefaultSetup(2);     % (0) executes the AssertOpenGL command to make sure the Screen() mex file is properly installed& functional; (1) also executes KbName('UnifyKeyNames') to provide a consitent mapping of keyCodes to key names; (2) also implies the execution of Screen (‘ColorRange’, window, 1, [], 1); immediately after and whenever PsychImaging(‘OpenWindow’,…) is called, switching the color range to 0.0-1.0, BUT still with 256 steps, floating point precision is set later 
PsychImaging('PrepareConfiguration');    % to initiate the following configuration
PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');     % uses the highest possible color presicion

% Propixx
Datapixx('Open');
switch p.scr_refrate          %select multimode according to refresh rate
    case 120
        multimode = 0;
    case 480
        multimode = 2;
    case 1440
        multimode = 4;
end
Datapixx('SetPropixxDlpSequenceProgram', multimode);
Datapixx('StopAllSchedules');
Datapixx('SetDoutValues', 0);
Datapixx('RegWrRd');
p.bufferAddress = 8e6;

% open LPT trigger port
try ppdev_mex('Close',1);
end
try ppdev_mex('Open',1);    
end
lptwrite(1,0); % ensure it's set to zero (solves the LPT-4-issue!)
    
% Screen setup
Screen('ConfigureDisplay', 'Scanout', p.scr_screen, 0, p.scr_res(1),p.scr_res(2),p.scr_refrate);
WaitSecs(10); % allow screen changes to take place
[ps.window, ps.windowRect] = PsychImaging('OpenWindow', p.scr_screen, p.background_col);    % open window
% ----> Screen('ColorRange', ps.window,1); %necessary?
[ps.screenXpixels, ps.screenYpixels] = Screen('WindowSize', ps.window);                     % get window size
[ps.xCenter, ps.yCenter] = RectCenter(ps.windowRect);                                       % get center coordinate
% if resolution smaller 1920*1080, center positions are off!
if p.scr_res(1)<ps.screenXpixels || p.scr_res(2)<ps.screenYpixels
    ps.xCenter = p.scr_res(1)/2;
    ps.yCenter = p.scr_res(2)/2;
end

Screen('BlendFunction', ps.window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);    % set blending modes
% ----> SetMouse(ps.screenXpixels+200, 100, 2) %necessary?                   % hide mouse
RestrictKeysForKbCheck([]);                                                  % allows input from all keys
KbCheck;
fprintf(1,'done!\n')
ListenChar(-1)     % block button presses to matlab window STRG + C to exit and ListenChar(0) to end
Priority(1);       % set priority to real time
    
tmp = Screen('Resolution',p.scr_screen);
if tmp.width ~=p.scr_res(1) || tmp.height ~= p.scr_res(2) || tmp.hz ~= p.scr_refrate
    warning('measured screen refresh rate or resultion mismatch your settings.')
end
   
end

