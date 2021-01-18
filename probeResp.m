function [trial] = probeResp(trial, t, col, resplimit)

    %% Variables
    global expWin;
    global rect;
    global scrW;           
    global scrH;            
    global scrID;
    global scrHz;
    ctrX = scrW/2;
    ctrY = scrH/2;

    ProbeResp   = Screen('OpenOffscreenWindow', scrID, col.bg, rect);
                  Screen('TextFont', ProbeResp, 'Arial');
                  Screen('TextSize', ProbeResp, 84);

    pfont = 96;
    pborder = 360;
    pcols = 7;
    prows = 4;
    alphabet = 'A':'Z';
    ploc = struct;
    trial(t).probeRESP = '';

    %% ploc structure to neutral
    h = scrH - pborder;
    w = scrW - pborder;
    numlet = pcols*prows;
    i = 0;
    for y = 1:prows
        for x = 1:pcols
            i = i + 1;
            ploc(i).used = 0;
            ploc(i).x1 = (x-1) * ((w/pcols)) + (pborder/2);
            ploc(i).y1 = (y-1) * (h/(prows+1)) + (pborder/2);
            ploc(i).x2 = x * ((w/pcols)) + (pborder/2);
            ploc(i).y2 = y * (h/(prows+1)) + (pborder/2);
            ploc(i).x = ((ploc(i).x1 + ploc(i).x2)/2) - pfont/2;
            ploc(i).y = ((ploc(i).y1 + ploc(i).y2)/2) - pfont/2;
            if i < 27
                ploc(i).ID = alphabet(i);
                ploc(i).col = col.white;
            else
                ploc(i).ID = '';
            end
        end
    end

    %% Get Probe Response
    numsel = 0;
    reply = char;
    okFLAG = 0;
    for i = 1:200
        ShowCursor(scrID);
    end
    SetMouse(ctrX,ctrY+225,scrID);
    startRT = GetSecs;

    while okFLAG == 0
        % draw updated probe array
        for i = 1:numlet
            DrawFormattedText(ProbeResp, ploc(i).ID, ploc(i).x, ploc(i).y+50, ploc(i).col);  % draw letters
        end
        okbox = [ctrX-90 scrH-180 ctrX+90 scrH-72];
        Screen('FillRect', ProbeResp, [150 150 150], okbox);
        DrawFormattedText(ProbeResp, 'OK', 'center', scrH-100, [0 0 0]);
        Screen('DrawTexture', expWin, ProbeResp);   %flip to screen
        Screen('flip', expWin);

        % get click
        [~, x, y, ~] = GetClicks(scrID,0);
        if x > okbox(1) && y > okbox(2) && x < okbox(3) && y <okbox(4)
            okFLAG = 1;
        else
            for i = 1:length(alphabet)
                if x > ploc(i).x1 && y > ploc(i).y1 && x < ploc(i).x2 && y < ploc(i).y2
                    if ploc(i).used == 0 && length(trial(t).probeRESP)<resplimit
                        ploc(i).col = col.yellow;
                        ploc(i).used = 1;
                        trial(t).probeRESP  = [trial(t).probeRESP   ploc(i).ID];
                    elseif ploc(i).used == 1
                        ploc(i).col = col.white;
                        ploc(i).used = 0;
                        trial(t).probeRESP  = setdiff(trial(t).probeRESP , ploc(i).ID, 'stable');
                    end
                end
            end
        end
    end
    stopRT = GetSecs;

    %% Score Probe Response
    trial(t).ProbeRT = (stopRT-startRT)*1000;
    trial(t).ACC = 1;

    % Probe Resp
    trial(t).singProbeACC = 0;
    trial(t).targProbeACC = 0;
    if ~isempty(trial(t).probeRESP)
        for i = 1:length(trial(t).probeRESP)
            if strcmp(trial(t).probeRESP(i),trial(t).singProbe)
                trial(t).singProbeACC = 1;
            end
            if strcmp(trial(t).probeRESP(i),trial(t).targProbe)
                trial(t).targProbeACC = 1;
            end
        end
        acc = 0;
        for i = 1:length(trial(t).nonsingProbe)
            for j = 1:length(trial(t).probeRESP)
                if strcmp(trial(t).probeRESP(j), trial(t).nonsingProbe(i))
                    acc = acc + 1;
                end
            end
        end
        trial(t).nonsingProbeACC = acc/length(trial(t).nonsingProbe);
    else
        trial(t).singProbeACC = 0;
        trial(t).targProbeACC = 0;
        trial(t).nonsingProbeACC = 0;
    end


    %% Exit
    HideCursor();
    Screen('close', ProbeResp);

end
