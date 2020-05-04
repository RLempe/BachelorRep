function [threshold]=hear_thresh_lite(snd_path,repetition,window,p)
% is a function to determine the individual hearing threshold; presents the
% selected sound descending and ascending in intensity
%
%   Input Arguments:
%   snd_path            :   path of sound that should be used for threshold determination
%   repetition          :   trial repetitions (one trial is ascending and descending tone)
%   window              :   window pointer (after opening a window with Screen('OpenWindow') or PsychImaging('OpenWindow')
%   p.snd_samprate      :   sound sampling rate, e.g. 44100
%   p.txt_color         :   text color
    

% Initialize Psychtoolbox Audio Port
InitializePsychSound;
PsychPortAudio('Close')
p.pahandle = PsychPortAudio('Open', [], [], [], p.snd_samprate); % defaults to 2 Channels

% Load and prepare sound
snd = psychwavread(snd_path);   % read in sound file
if size(snd,2)>1
    snd = snd(:,1);             % only use one channel, second channel is added again after sound adjustment
end
duration = size(snd,1)./ p.snd_samprate; % gives sound duration in seconds
responsekey = KbName('space');

%% Adjust sound slope

% slopefun range = 0 to -120dB
slopefun=permute(logspace(-6,-1,size(snd,1)),[2 1]);    % create sound intensity curve

% IF THE ABOVE IS TOO LOUD: slopefun range = -40 to -120dB: -40dB amp = 0.01
% slopefun=permute(logspace(-6,-2,size(snd,1)),[2 1]);

snd_adj=snd.*repmat(tukeywin(size(snd,1),.01),1,size(snd,2)).*repmat(slopefun,1,size(snd,2));   % adjust sound to intensity curve
% figure; plot(snd_adj); hold on; plot(slopefun)

snd_obj.desc1=flipud(snd_adj(:,[1 1]))'; % flip to get descending tone
snd_obj.asc1=snd_adj(:,[1 1])';

%% stimulation program
resptime=zeros(repetition,2);
for itrial=1:repetition
    
    if itrial==1
        Screen('TextSize', window, 30);
        info_txt='Hörschwellenbestimmung';
        DrawFormattedText(window,info_txt, 'center', 'center', p.txt_color);
        Screen('TextSize', window, 18);
        press_txt='Bitte Taste zum Starten drücken';
        DrawFormattedText(window,press_txt, 'center', 600, p.txt_color);
        Screen('Flip', window, 0);
        WaitForKey;
        WaitSecs(0.3);
    end

    fprintf('Trial %d...\n',itrial)
    
    expl1_txt='Ton beginnt laut!';
    Screen('TextSize', window, 30);                                     
    DrawFormattedText(window,expl1_txt, 'center', 'center', p.txt_color);
    Screen('TextSize', window, 18);                                      
    prs1_txt='Bitte drücken Sie sofort die Leertaste wenn Sie den Ton NICHT mehr hören';
    DrawFormattedText(window,prs1_txt, 'center', 600, p.txt_color);
    start1_txt='START MIT LEERTASTE';
    DrawFormattedText(window,start1_txt, 'center', 700, p.txt_color);
    Screen('Flip', window, 0);
    WaitForKey;
        
    Screen('TextSize', window, 30);                                     
    DrawFormattedText(window,expl1_txt, 'center', 'center', p.txt_color);
    Screen('TextSize', window, 18);
    DrawFormattedText(window,prs1_txt, 'center', 600, p.txt_color);
    Screen('Flip', window, 0);
    
    fprintf('descending\n')
    
    WaitSecs(0.3);                                                          
    
    %1) descending tone
    % playing the sound with Psychtoolbox
    PsychPortAudio('FillBuffer', p.pahandle, snd_obj.desc1);      % load sound to buffer
    tstart = PsychPortAudio('Start', p.pahandle, 1, 0, 1);        % start playback
    
    % wait for key press and get reaction time in relation to start time
    [keyIsDown, secs, keyCode] = KbCheck;
    audiostatus = PsychPortAudio('GetStatus', p.pahandle);
    while audiostatus.Active && ~keyCode(responsekey)
        [keyIsDown,secs, keyCode] = KbCheck;
        audiostatus = PsychPortAudio('GetStatus', p.pahandle);
        WaitSecs(0.005);                                                    
    end
    [~, ~, ~, tstop] = PsychPortAudio('Stop', p.pahandle);
    resptime(itrial,1)=tstop-tstart;                                       
        
    WaitSecs(0.5);                                                          
       
    expl2_txt='Ton beginnt leise!';
    Screen('TextSize', window, 30);                                      
    DrawFormattedText(window,expl2_txt, 'center', 'center', p.txt_color);
    Screen('TextSize', window, 18);                                     
    prs2_txt='Bitte drücken Sie sofort die Leertaste sobald Sie den Ton hören!';
    DrawFormattedText(window,prs2_txt, 'center', 600, p.txt_color);
    start2_txt='START MIT LEERTASTE';
    DrawFormattedText(window,start2_txt, 'center', 700, p.txt_color);
    Screen('Flip', window, 0);
    WaitForKey;
    
    Screen('TextSize', window, 30);                                     
    DrawFormattedText(window,expl2_txt, 'center', 'center', p.txt_color);
    Screen('TextSize', window, 18);
    DrawFormattedText(window,prs2_txt, 'center', 600, p.txt_color);
    Screen('Flip', window, 0);
    
    fprintf('ascending\n')
    
    WaitSecs(0.3);                                                          
    
    %2) ascending tone
    % playing the sound with Psychtoolbox
    PsychPortAudio('FillBuffer', p.pahandle, snd_obj.asc1);      % load sound to buffer
    tstart = PsychPortAudio('Start', p.pahandle, 1, 0, 1);       % start playback
    
    
    % wait for key press and get reaction time in relation to start time
    [keyIsDown, secs, keyCode] = KbCheck;
    audiostatus = PsychPortAudio('GetStatus', p.pahandle);
    while audiostatus.Active && ~keyCode(responsekey)
        [keyIsDown,secs, keyCode] = KbCheck;
        audiostatus = PsychPortAudio('GetStatus', p.pahandle);
        WaitSecs(0.005);                                                    
    end
    [~, ~, ~, tstop] = PsychPortAudio('Stop', p.pahandle);
    resptime(itrial,2)=tstop-tstart;  
    
    WaitSecs(0.5);                                                              
    
    if itrial==repetition
        end_txt='Hörschwellenbestimmung abgeschlossen';
        Screen('TextSize', window, 30);                                  
        DrawFormattedText(window,end_txt, 'center', 'center', p.txt_color);
        Screen('TextSize', window, 18);                                  
        exit_txt='Drücken Sie bitte eine beliebige Taste um den Hörschwellentest zu beenden.';
        DrawFormattedText(window,exit_txt, 'center', 600, p.txt_color);
        Screen('Flip', window, 0);
        WaitForKey;                                                        
    end
end

level=zeros(size(resptime));
level(:,1)=time2level(duration*1000,p.snd_samprate,flipud(slopefun),resptime(:,1)*1000); % descending tone
level(:,2)=time2level(duration*1000,p.snd_samprate,slopefun,resptime(:,2)*1000); % ascending tone


threshold=mean(median(level(:,:)));
deviat=mean(mad(level(:,:),1));
fprintf('Individual hearing threshold is [ %3.0f ], Deviation [ %3.1f ]\n',ceil(threshold),deviat)


%% subfunctions
function [level]=time2level(dur,srate,slopefun,resptime)
% convert response times to corresponding sound level (dB)
for itime=1:numel(resptime)
    idx = dsearchn(linspace(0,dur,srate*dur/1000)',resptime(itime));
    level(itime)=ceil(20*log10(median(slopefun(idx))));
end