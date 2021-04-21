function [ r, t ] = ERP_present_trial( p, ps, trialstruct, tex )
%ERP_present_trial presents one trial

% --- definition of trial variables ---
target_pos = trialstruct.target_pos;
distr_pos = trialstruct.distr_pos;
dot_target_pos = trialstruct.dot_target_pos;
dot_distr_pos = trialstruct.dot_distr_pos;
alphabet = 'A' : 'Z';
perm=trialstruct.perm;
trigger = str2num([num2str(target_pos) num2str(distr_pos)]);
if ~trigger
    trigger = 100;
end
jitter = trialstruct.jitter;
time = 0;
key = 0;
% initiate response structure   %FIX include target true/false, distractor true/false?
r.condition = trialstruct.condition;
r.hit = nan;
r.RT = nan;
r.error = nan;
r.errorRT = nan;
r.miss = nan;
r.FA = nan;
r.FART = nan;
r.dFA = nan;
r.dFART = nan;
r.buchstaben = nan;
r.perm = trialstruct.perm;
r.target_pos = trialstruct.target_pos;
r.distr_pos = trialstruct.distr_pos;


pre_fix_end = p.pre_fix_min+jitter;
stim_end = pre_fix_end+p.stim_duration;
buchstabenend = stim_end + p.probe_buchstabendauer;
hashtagend = buchstabenend + p.probe_hashtagdauer;
% textgroesse = 60;
textgroesse = p.textsize;
buchstabenfarbe = [1 1 1];
hashtagskalar = 1.5;


if trialstruct.condition(1) == 's'
    post_fix_end = stim_end+p.post_fix_min;
    ITI_end = post_fix_end + p.ITI;
else
    post_fix_end = hashtagend+p.post_fix_min;
    ITI_end = post_fix_end + p.ITI;
end


%Fixationskreuz
Screen('DrawTextures', ps.window, tex.fixbar, [], p.fix_rects, [], [], [], p.fix_col);
t.time1=Screen('Flip', ps.window, 0);

Screen('DrawTextures', ps.window, tex.fixbar, [], p.fix_rects, [], [], [], p.fix_col);
pos_pool = [1 2 3 4];
s = sqrt(2)*p.stim_size/(sqrt(3)*sqrt(sqrt(3)));
h = sqrt(3)*s;
s=round(s);
h=round(h);
rotation = 0; %Quadrat
% if trialstruct.condition(2) == '2'
%     rotation = 45; %Raute
% end

blau = p.BL_col;
blaudot = p.dot_BL_col;
yellow = p.yellow;
yellowdot = p.dot_yellow;
rby = randi(2);

if trialstruct.condition(2) == '2'
    baselinefarbe1 = blau;
    baselinedot1 = blaudot;
    baselinefarbe2 = blau;
    baselinedot2 = blaudot;
else
    if trialstruct.condition(2) == '3'
        if rby == 1
            baselinefarbe1 = yellow;
            baselinedot1 = yellowdot;
            baselinefarbe2 = blau;
            baselinedot2 = blaudot;
        else
            baselinefarbe1 = blau;
            baselinedot1 = blaudot;
            baselinefarbe2 = yellow;
            baselinedot2 = yellowdot;
        end
    else
        baselinefarbe1 = p.target_col;
        baselinedot1 = p.dot_target_col;
        baselinefarbe2 = p.target_col;
        baselinedot2 = p.dot_target_col;
    end    
end

if trialstruct.condition(2) == '4'
    distraktorfarbe = p.target_col;
    distraktordot = p.dot_target_col;
else
    distraktorfarbe = p.distr_col;
    distraktordot = p.dot_distr_col;
end

%Target
Screen('DrawTexture', ps.window, tex.target, [],  p.pos_rects(target_pos,:), p.target_rot, [], [], p.target_col);
Screen('DrawTexture', ps.window, tex.dot, [], p.dot_rects(target_pos,:,dot_target_pos), [], [], [], p.dot_target_col);
pos_pool(pos_pool==target_pos)=[];
%Distraktor
Screen('DrawTexture', ps.window, tex.distr, [],  p.pos_rects(distr_pos,:), rotation, [], [], distraktorfarbe);
Screen('DrawTexture', ps.window, tex.dot, [], p.dot_rects(distr_pos,:,dot_distr_pos), [], [], [], distraktordot);
pos_pool(pos_pool==distr_pos)=[];
r4 = randperm(2);
blpos1 = pos_pool(r4(1));
blpos2 = pos_pool(r4(2));
%Baseline
%jetzt kommt der Kreis - blfarbe 1
Screen('DrawTexture',ps.window, tex.kreis, [], p.circle_rects(blpos1,:), 0, [], [], baselinefarbe1);
Screen('DrawTexture', ps.window, tex.dot, [], p.dot_rects(blpos1,:,randi(2)), [], [], [], baselinedot1);
% und jetzt kommt das Sechseck - blfarbe 2
Screen('FillPoly',ps.window,baselinefarbe2,[(p.positions(blpos2,1)-0.5*s) (p.positions(blpos2,1)+0.5*s) (p.positions(blpos2,1)+s) (p.positions(blpos2,1)+0.5*s) (p.positions(blpos2,1)-0.5*s) (p.positions(blpos2,1)-s);(p.positions(blpos2,2)+0.5*h) (p.positions(blpos2,2)+0.5*h) p.positions(blpos2,2) (p.positions(blpos2,2)-0.5*h) (p.positions(blpos2,2)-0.5*h) p.positions(blpos2,2)]',1);
Screen('DrawTexture', ps.window, tex.dot, [], p.dot_rects(blpos2,:,randi(2)), [], [], [], baselinedot2);

if trialstruct.condition(1) == 'p'
    Screen('DrawTextures', ps.window, tex.fixbar, [], p.fix_rects, [], [], [], p.fix_col);
    t.time2=Screen('Flip', ps.window, t.time1+pre_fix_end);
    %Fixationskreuz
    Screen('DrawTextures', ps.window, tex.fixbar, [], p.fix_rects, [], [], [], p.fix_col);
    %Figuren
    Screen('DrawTexture', ps.window, tex.target, [],  p.pos_rects(target_pos,:), p.target_rot, [], [], p.target_col);
    Screen('DrawTexture', ps.window, tex.distr, [],  p.pos_rects(distr_pos,:), rotation, [], [], distraktorfarbe);
    Screen('DrawTexture',ps.window, tex.kreis, [], p.circle_rects(blpos1,:), 0, [], [], baselinefarbe1);
    Screen('FillPoly',ps.window,baselinefarbe2,[(p.positions(blpos2,1)-0.5*s) (p.positions(blpos2,1)+0.5*s) (p.positions(blpos2,1)+s) (p.positions(blpos2,1)+0.5*s) (p.positions(blpos2,1)-0.5*s) (p.positions(blpos2,1)-s);(p.positions(blpos2,2)+0.5*h) (p.positions(blpos2,2)+0.5*h) p.positions(blpos2,2) (p.positions(blpos2,2)-0.5*h) (p.positions(blpos2,2)-0.5*h) p.positions(blpos2,2)]',1);
    %und jetzt kommen die Buchstaben
    Screen('TextSize',ps.window, textgroesse);
    DrawFormattedText(ps.window, alphabet(perm(1)), 'center', 'center', buchstabenfarbe, [], [], [], [], [], [ps.xCenter-textgroesse/2, ps.yCenter-p.stim_dist-textgroesse/2, ps.xCenter+textgroesse/2, ps.yCenter-p.stim_dist+textgroesse/2]);
    DrawFormattedText(ps.window, alphabet(perm(2)), 'center', 'center', buchstabenfarbe, [], [], [], [], [], [ps.xCenter+p.stim_dist-textgroesse/2, ps.yCenter-textgroesse/2, ps.xCenter+p.stim_dist+textgroesse/2, ps.yCenter+textgroesse/2]);
    DrawFormattedText(ps.window, alphabet(perm(3)), 'center', 'center', buchstabenfarbe, [], [], [], [], [], [ps.xCenter-textgroesse/2, ps.yCenter+p.stim_dist-textgroesse/2, ps.xCenter+textgroesse/2, ps.yCenter+p.stim_dist+textgroesse/2]);
    DrawFormattedText(ps.window, alphabet(perm(4)), 'center', 'center', buchstabenfarbe, [], [], [], [], [], [ps.xCenter-p.stim_dist-textgroesse/2, ps.yCenter-textgroesse/2, ps.xCenter-p.stim_dist+textgroesse/2, ps.yCenter+textgroesse/2]);
    t.time3=Screen('Flip', ps.window, t.time1+stim_end);
    
    %für Hashtags diesen Teil Einkommentieren
%     %Fixationskreuz
%     Screen('DrawTextures', ps.window, tex.fixbar, [], p.fix_rects, [], [], [], p.fix_col);
%     %Figuren
%     Screen('DrawTexture', ps.window, tex.target, [],  p.pos_rects(target_pos,:), p.target_rot, [], [], p.target_col);
%     Screen('DrawTexture', ps.window, tex.distr, [],  p.pos_rects(distr_pos,:), rotation, [], [], p.distr_col);
%     Screen('DrawTexture',ps.window, tex.kreis, [], p.circle_rects(blpos1,:), 0, [], [], baselinefarbe);
%     Screen('FillPoly',ps.window,baselinefarbe,[(p.positions(blpos2,1)-0.5*s) (p.positions(blpos2,1)+0.5*s) (p.positions(blpos2,1)+s) (p.positions(blpos2,1)+0.5*s) (p.positions(blpos2,1)-0.5*s) (p.positions(blpos2,1)-s);(p.positions(blpos2,2)+0.5*h) (p.positions(blpos2,2)+0.5*h) p.positions(blpos2,2) (p.positions(blpos2,2)-0.5*h) (p.positions(blpos2,2)-0.5*h) p.positions(blpos2,2)]',1);
%     %Rauten
%     DrawFormattedText(ps.window, sprintf('#'), 'center', 'center', buchstabenfarbe, [], [], [], [], [], [ps.xCenter-textgroesse/2, ps.yCenter-p.stim_dist-textgroesse/2, ps.xCenter+textgroesse/2, ps.yCenter-p.stim_dist+textgroesse/2]);
%     DrawFormattedText(ps.window, sprintf('#'), 'center', 'center', buchstabenfarbe, [], [], [], [], [], [ps.xCenter+p.stim_dist-textgroesse/2, ps.yCenter-textgroesse/2, ps.xCenter+p.stim_dist+textgroesse/2, ps.yCenter+textgroesse/2]);
%     DrawFormattedText(ps.window, sprintf('#'), 'center', 'center', buchstabenfarbe, [], [], [], [], [], [ps.xCenter-textgroesse/2, ps.yCenter+p.stim_dist-textgroesse/2, ps.xCenter+textgroesse/2, ps.yCenter+p.stim_dist+textgroesse/2]);
%     DrawFormattedText(ps.window, sprintf('#'), 'center', 'center', buchstabenfarbe, [], [], [], [], [], [ps.xCenter-p.stim_dist-textgroesse/2, ps.yCenter-textgroesse/2, ps.xCenter-p.stim_dist+textgroesse/2, ps.yCenter+textgroesse/2]);
%     t.time4=Screen('Flip', ps.window, t.time1+buchstabenend);

    %Für Hashtags diese Zeile auskommentieren
    t.time4='';
        
end


Screen('DrawTextures', ps.window, tex.fixbar, [], p.fix_rects, [], [], [], p.fix_col); %add fixation cross

if trialstruct.condition(1) == 's'
    RestrictKeysForKbCheck([]);
    t.time2=Screen('Flip', ps.window, t.time1+pre_fix_end);
%     lptwrite(1,trigger,500);


% --- draw fix ---
    Screen('DrawTextures', ps.window, tex.fixbar, [], p.fix_rects, [], [], [], p.fix_col);
%t.time3=Screen('Flip', ps.window, 0);
    t.time3=Screen('Flip', ps.window, t.time1+stim_end);

%response tracking during post-stimulus fixation
    now = GetSecs();
%while now < t.time3+p.post_fix_min+max(p.jitter)-jitter    %cumulative timing
    while now < t.time1+post_fix_end                            %check until post-fix presentation time is reached
        [keyIsDown, secs, keyCode] = KbCheck;
        if keyIsDown && ~key 
            time=secs-t.time2;
            key=find(keyCode,1);
%             lptwrite(1,key,500);
        end
        now = GetSecs();
    end

% --- blank screen (ITI) ---
% new: now fixation cross in ITI as well
    Screen('DrawTextures', ps.window, tex.fixbar, [], p.fix_rects, [], [], [], p.fix_col);
    t.time4=Screen('Flip',ps.window,0);
    %t.time4=Screen('Flip',ps.window,t.time1+post_fix_end+0.5*ifi); % 2


    % response decoding
    if target_pos
        if key == p.key_codes(dot_target_pos)
            r.hit = 1; 
            r.RT = time;
        elseif key == p.key_codes(dot_target_pos*(-1)+3) %if dot_target_pos = 1 --> 2 ; if dot_target_pos = 2 --> 1
            r.error = 1;
            r.errorRT = time;
        elseif key == 0
            r.miss = 1;
        end
    else
        if distr_pos && key
            r.dFA = 1;
            r.dFART = time;
        elseif key
            r.FA = 1;
            r.FART = time;
        end
    end
    r.buchstaben='';
    
    %WaitSecs('UntilTime',t.time4+p.ITI); %cumulative timing
    WaitSecs('UntilTime',t.time1+ITI_end);
else %probe trial condition, hier die buchstabenabfrage machen
    Screen('Flip', ps.window, t.time1 + hashtagend);
    r.hit = nan;
    r.RT = nan;
    r.error = nan;
    r.errorRT = nan;
    r.miss = nan;
    r.FA = nan;
    r.FART = nan;
    r.dFA = nan;
    r.dFART = nan;
    
    unfertig = true;     
    ansbuchst={'','','',''};
    abstand = 400;
    akt=1;
    n=0;

    
    %Für Romy zuhause:
%     RestrictKeysForKbCheck(KbName({'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','backspace','Return'}));
    
    %Fuer 119: bitte unkommentieren
    restrictKeys = KbName({'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','backspace','Return'});
    RestrictKeysForKbCheck(restrictKeys(restrictKeys~=105));
    return_button = 37;
    
    while unfertig == true
        n=n+1;
        DrawFormattedText(ps.window, sprintf('An welche Buchstaben erinnern Sie sich?'), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter, ps.yCenter-200-300, ps.xCenter, ps.yCenter-200+300]);
        Screen('DrawTextures', ps.window, tex.fixbar, [], p.fix_rects, [], [], [], p.fix_col);
        Screen('Flip',ps.window,[],1);
        gedrueckt = false;
        while ~gedrueckt
                [keyIsDown, secs, keyCode] = KbCheck;
                if keyIsDown 
                    gedrueckt = true;
                end
        end
        try
%           Fuer 119 bitte diese Zeile
            if keyCode(return_button)

%             fuer Romy zuhause bitte diese Zeile:
%             if keyCode(KbName('Return'))


                Screen('Flip', ps.window);
                unfertig = false;
                % 1,5 Sekunden warten? Mit Norman besprechen!!
                WaitSecs(1);
                RestrictKeysForKbCheck([]);
            else
                for i = 1:(akt-1)
                    DrawFormattedText(ps.window, sprintf(ansbuchst{i}), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter+(abstand*i-2.5*abstand), ps.yCenter-textgroesse/2, ps.xCenter+(abstand*i-2.5*abstand), ps.yCenter+textgroesse/2]);
                    Screen('DrawTextures', ps.window, tex.fixbar, [], p.fix_rects, [], [], [], p.fix_col);
                end
                
                if (keyCode(KbName('backspace')) && (akt > 1))
                    ansbuchst{akt-1}='';
                    akt = akt-1;
                    % WaitSecs(0.5);
                    Screen('Flip',ps.window);
                    DrawFormattedText(ps.window, sprintf('An welche Buchstaben erinnern Sie sich?'), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter, ps.yCenter-200-300, ps.xCenter, ps.yCenter-200+300]);
                    Screen('DrawTextures', ps.window, tex.fixbar, [], p.fix_rects, [], [], [], p.fix_col);
                    for i = 1:(akt-1)
                        DrawFormattedText(ps.window, sprintf(ansbuchst{i}), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter+(abstand*i-2.5*abstand), ps.yCenter-textgroesse/2, ps.xCenter+(abstand*i-2.5*abstand), ps.yCenter+textgroesse/2]);
                        Screen('DrawTextures', ps.window, tex.fixbar, [], p.fix_rects, [], [], [], p.fix_col);
                    end
                    Screen('Flip',ps.window,[],1);
                    WaitSecs(0.3);                
                else                              
                        if akt <5 %keine doppelten Buchstaben!
                            dieser = KbName(keyCode);
    %                       DrawFormattedText(ps.window, sprintf(ansbuchst{akt}), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter+(abstand*akt-2.5*abstand), ps.yCenter-textgroesse/2, ps.xCenter+(abstand*akt-2.5*abstand), ps.yCenter+textgroesse/2]);
                            doppelt = false;
                            for i = 1:akt
                                if ansbuchst{i} == upper(dieser)
                                    doppelt = true;
                                end    
                            end 
                    
                            if (~isempty(dieser) && ~doppelt)
                                ansbuchst{akt} = upper(dieser);
                                DrawFormattedText(ps.window, sprintf(ansbuchst{akt}), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter+(abstand*akt-2.5*abstand), ps.yCenter-textgroesse/2, ps.xCenter+(abstand*akt-2.5*abstand), ps.yCenter+textgroesse/2]);
                                Screen('DrawTextures', ps.window, tex.fixbar, [], p.fix_rects, [], [], [], p.fix_col);
                                akt = akt +1;
                                Screen('Flip',ps.window,[],1);
                                WaitSecs(0.3);
                            end                                  
                        end                                   
                end
            end
        catch ME2
%             fprintf('test2');
        end
    end
    antwort = '';
    for i = 1 : akt-1
        antwort(i) = ansbuchst{i};
    end
    r.buchstaben=antwort;

%WaitSecs('UntilTime',t.time1+ITI_end);    
    
end
 
%WaitSecs('UntilTime',t.time4+p.ITI); %cumulative timing
% WaitSecs('UntilTime',t.time1+ITI_end);

end