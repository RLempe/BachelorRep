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
% timing structure (base all timing on trial start, to prevent cumulation of delay)

%hier arbeiten: timings festlegen (am besten in run_luckyfeat)
pre_fix_end = p.pre_fix_min+jitter;
stim_end = pre_fix_end+p.stim_duration;
buchstabenend = stim_end + p.probe_buchstabendauer;
hashtagend = buchstabenend + p.probe_hashtagdauer;
textgroesse = 60;
hashtagskalar = 1.5;


if trialstruct.condition(1) == 's'
    post_fix_end = stim_end+p.post_fix_min;
    ITI_end = post_fix_end + p.ITI;
else
    post_fix_end = hashtagend+p.post_fix_min;
    ITI_end = post_fix_end + p.ITI;
end
%FIX restrict response keys extra?

% --- draw fixation ---
Screen('DrawTextures', ps.window, tex.fixbar, [], p.fix_rects, [], [], [], p.fix_col);
t.time1=Screen('Flip', ps.window, 0);

% --- draw stimuli ---
pos_pool = [1 2 3 4];               % create a pool for all four stimulus positions
if target_pos                       % draw target (with dots) if present
Screen('DrawTexture', ps.window, tex.target, [],  p.pos_rects(target_pos,:), p.target_rot, [], [], p.target_col);
Screen('DrawTexture', ps.window, tex.dot, [], p.dot_rects(target_pos,:,dot_target_pos), [], [], [], p.dot_target_col);
pos_pool(pos_pool==target_pos)=[];  % take drawn target out of position pool
end

if distr_pos                        % draw distractor (with dots) if present
    if strcmp(trialstruct.condition,'p4') || strcmp(trialstruct.condition,'s4') % dann brauchen wir Raute als Distraktor
       Screen('DrawTexture', ps.window, tex.distr, [],  p.pos_rects(distr_pos,:), 45, [], [], p.distr_col);
       Screen('DrawTexture', ps.window, tex.dot, [], p.dot_rects(distr_pos,:,dot_distr_pos), [], [], [], p.dot_distr_col); 
       pos_pool(pos_pool==distr_pos)=[];   % take drawn distractor out of position pool
    else % dann brauchen wir Dreieck als Distraktor
      s = 2*p.stim_size/(sqrt(sqrt(3)));
      h = 0.5*sqrt(3)*s;
      s=round(s);
      h=round(h);
      Screen('FillPoly',ps.window,p.distr_col,[(p.positions(distr_pos,1)-0.5*s) (p.positions(distr_pos,1)+0.5*s) p.positions(distr_pos,1);(p.positions(distr_pos,2)+(1/3)*h) (p.positions(distr_pos,2)+(1/3)*h) (p.positions(distr_pos,2)-(2/3)*h)]');
      Screen('DrawTexture', ps.window, tex.dot, [], p.dot_rects(distr_pos,:,dot_distr_pos), [], [], [], p.dot_distr_col) 
      pos_pool(pos_pool==distr_pos)=[];
    end
end

%Conditions S1 und S4 stimmt so
if strcmp(trialstruct.condition,'s1') || strcmp(trialstruct.condition,'s4') % dann brauchen wir Sechseck und Kreis als BL
    s = sqrt(2)*p.stim_size/(sqrt(3)*sqrt(sqrt(3)));
    h = sqrt(3)*s;
    s=round(s);
    h=round(h);
    r4 = randperm(2);
    blpos1 = pos_pool(r4(1));
    blpos2 = pos_pool(r4(2));
    %jetzt kommt der Kreis
    Screen('DrawTexture',ps.window, tex.kreis, [], p.circle_rects(blpos1,:), 0, [], [], p.BL_col) 
    Screen('DrawTexture', ps.window, tex.dot, [], p.dot_rects(blpos1,:,randi(2)), [], [], [], p.dot_BL_col);
    % und jetzt kommt das Sechseck
    Screen('FillPoly',ps.window,p.BL_col,[(p.positions(blpos2,1)-0.5*s) (p.positions(blpos2,1)+0.5*s) (p.positions(blpos2,1)+s) (p.positions(blpos2,1)+0.5*s) (p.positions(blpos2,1)-0.5*s) (p.positions(blpos2,1)-s);(p.positions(blpos2,2)+0.5*h) (p.positions(blpos2,2)+0.5*h) p.positions(blpos2,2) (p.positions(blpos2,2)-0.5*h) (p.positions(blpos2,2)-0.5*h) p.positions(blpos2,2)]',1);
    Screen('DrawTexture', ps.window, tex.dot, [], p.dot_rects(blpos2,:,randi(2)), [], [], [], p.dot_BL_col);
end

if strcmp(trialstruct.condition,'p1') % dann brauchen wir Sechseck und Kreis als BL
    Screen('DrawTextures', ps.window, tex.fixbar, [], p.fix_rects, [], [], [], p.fix_col);
    s = sqrt(2)*p.stim_size/(sqrt(3)*sqrt(sqrt(3)));
    h = sqrt(3)*s;
    s=round(s);
    h=round(h);
    r4 = randperm(2);
    blpos1 = pos_pool(r4(1));
    blpos2 = pos_pool(r4(2));
    %Kreis
    Screen('DrawTexture',ps.window, tex.kreis, [], p.circle_rects(blpos1,:), 0, [], [], p.BL_col) 
    Screen('DrawTexture', ps.window, tex.dot, [], p.dot_rects(blpos1,:,randi(2)), [], [], [], p.dot_BL_col);
    %Sechseck
    Screen('FillPoly',ps.window,p.BL_col,[(p.positions(blpos2,1)-0.5*s) (p.positions(blpos2,1)+0.5*s) (p.positions(blpos2,1)+s) (p.positions(blpos2,1)+0.5*s) (p.positions(blpos2,1)-0.5*s) (p.positions(blpos2,1)-s);(p.positions(blpos2,2)+0.5*h) (p.positions(blpos2,2)+0.5*h) p.positions(blpos2,2) (p.positions(blpos2,2)-0.5*h) (p.positions(blpos2,2)-0.5*h) p.positions(blpos2,2)]',1);
    Screen('DrawTexture', ps.window, tex.dot, [], p.dot_rects(blpos2,:,randi(2)), [], [], [], p.dot_BL_col);
    t.time2=Screen('Flip', ps.window, t.time1+stim_end);
    %Ende des ersten Praesentationsteils
    %Fixationskreuz
    Screen('DrawTextures', ps.window, tex.fixbar, [], p.fix_rects, [], [], [], p.fix_col);
    %Figuren
    s3 = 2*p.stim_size/(sqrt(sqrt(3)));
    h3 = 0.5*sqrt(3)*s3;
    s3=round(s3);
    h3=round(h3);
    Screen('FillPoly',ps.window,p.distr_col,[(p.positions(distr_pos,1)-0.5*s3) (p.positions(distr_pos,1)+0.5*s3) p.positions(distr_pos,1);(p.positions(distr_pos,2)+(1/3)*h3) (p.positions(distr_pos,2)+(1/3)*h3) (p.positions(distr_pos,2)-(2/3)*h3)]'); %Distraktor
    Screen('DrawTexture', ps.window, tex.target, [],  p.pos_rects(target_pos,:), p.target_rot, [], [], p.target_col); %Target
    Screen('DrawTexture',ps.window, tex.kreis, [], p.circle_rects(blpos1,:), 0, [], [], p.BL_col) %Kreis
    Screen('FillPoly',ps.window,p.BL_col,[(p.positions(blpos2,1)-0.5*s) (p.positions(blpos2,1)+0.5*s) (p.positions(blpos2,1)+s) (p.positions(blpos2,1)+0.5*s) (p.positions(blpos2,1)-0.5*s) (p.positions(blpos2,1)-s);(p.positions(blpos2,2)+0.5*h) (p.positions(blpos2,2)+0.5*h) p.positions(blpos2,2) (p.positions(blpos2,2)-0.5*h) (p.positions(blpos2,2)-0.5*h) p.positions(blpos2,2)]',1); %Sechseck
    %und jetzt kommen die Buchstaben
%     alphabet = 'A' : 'Z';
%     perm = randperm(26);
    Screen('TextSize',ps.window, textgroesse);
    DrawFormattedText(ps.window, alphabet(perm(1)), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter-textgroesse/2, ps.yCenter-p.stim_dist-textgroesse/2, ps.xCenter+textgroesse/2, ps.yCenter-p.stim_dist+textgroesse/2]);
    DrawFormattedText(ps.window, alphabet(perm(2)), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter+p.stim_dist-textgroesse/2, ps.yCenter-textgroesse/2, ps.xCenter+p.stim_dist+textgroesse/2, ps.yCenter+textgroesse/2]);
    DrawFormattedText(ps.window, alphabet(perm(3)), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter-textgroesse/2, ps.yCenter+p.stim_dist-textgroesse/2, ps.xCenter+textgroesse/2, ps.yCenter+p.stim_dist+textgroesse/2]);
    DrawFormattedText(ps.window, alphabet(perm(4)), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter-p.stim_dist-textgroesse/2, ps.yCenter-textgroesse/2, ps.xCenter-p.stim_dist+textgroesse/2, ps.yCenter+textgroesse/2]);
    t.time3=Screen('Flip', ps.window, t.time1+buchstabenend);
    %Ende des zweiten Pr�sentationsteils
    %Fixationskreuz
    Screen('DrawTextures', ps.window, tex.fixbar, [], p.fix_rects, [], [], [], p.fix_col);
    %Figuren
    Screen('TextSize',ps.window, textgroesse*hashtagskalar);
    Screen('FillPoly',ps.window,p.distr_col,[(p.positions(distr_pos,1)-0.5*s3) (p.positions(distr_pos,1)+0.5*s3) p.positions(distr_pos,1);(p.positions(distr_pos,2)+(1/3)*h3) (p.positions(distr_pos,2)+(1/3)*h3) (p.positions(distr_pos,2)-(2/3)*h3)]'); %Distraktor
    Screen('DrawTexture', ps.window, tex.target, [],  p.pos_rects(target_pos,:), p.target_rot, [], [], p.target_col); %Target
    Screen('DrawTexture',ps.window, tex.kreis, [], p.circle_rects(blpos1,:), 0, [], [], p.BL_col) %Kreis
    Screen('FillPoly',ps.window,p.BL_col,[(p.positions(blpos2,1)-0.5*s) (p.positions(blpos2,1)+0.5*s) (p.positions(blpos2,1)+s) (p.positions(blpos2,1)+0.5*s) (p.positions(blpos2,1)-0.5*s) (p.positions(blpos2,1)-s);(p.positions(blpos2,2)+0.5*h) (p.positions(blpos2,2)+0.5*h) p.positions(blpos2,2) (p.positions(blpos2,2)-0.5*h) (p.positions(blpos2,2)-0.5*h) p.positions(blpos2,2)]',1); %Sechseck
    %Rauten
    DrawFormattedText(ps.window, sprintf('#'), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter-textgroesse/2, ps.yCenter-p.stim_dist-textgroesse/2, ps.xCenter+textgroesse/2, ps.yCenter-p.stim_dist+textgroesse/2]);
    DrawFormattedText(ps.window, sprintf('#'), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter+p.stim_dist-textgroesse/2, ps.yCenter-textgroesse/2, ps.xCenter+p.stim_dist+textgroesse/2, ps.yCenter+textgroesse/2]);
    DrawFormattedText(ps.window, sprintf('#'), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter-textgroesse/2, ps.yCenter+p.stim_dist-textgroesse/2, ps.xCenter+textgroesse/2, ps.yCenter+p.stim_dist+textgroesse/2]);
    DrawFormattedText(ps.window, sprintf('#'), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter-p.stim_dist-textgroesse/2, ps.yCenter-textgroesse/2, ps.xCenter-p.stim_dist+textgroesse/2, ps.yCenter+textgroesse/2]);
    t.time4=Screen('Flip', ps.window, t.time1+hashtagend);
end

if strcmp(trialstruct.condition,'p4') % dann brauchen wir Sechseck und Kreis als BL
    Screen('DrawTextures', ps.window, tex.fixbar, [], p.fix_rects, [], [], [], p.fix_col);
    s = sqrt(2)*p.stim_size/(sqrt(3)*sqrt(sqrt(3)));
    h = sqrt(3)*s;
    s=round(s);
    h=round(h);
    r4 = randperm(2);
    blpos1 = pos_pool(r4(1));
    blpos2 = pos_pool(r4(2));
    %Kreis
    Screen('DrawTexture',ps.window, tex.kreis, [], p.circle_rects(blpos1,:), 0, [], [], p.BL_col) 
    Screen('DrawTexture', ps.window, tex.dot, [], p.dot_rects(blpos1,:,randi(2)), [], [], [], p.dot_BL_col);
    %Sechseck
    Screen('FillPoly',ps.window,p.BL_col,[(p.positions(blpos2,1)-0.5*s) (p.positions(blpos2,1)+0.5*s) (p.positions(blpos2,1)+s) (p.positions(blpos2,1)+0.5*s) (p.positions(blpos2,1)-0.5*s) (p.positions(blpos2,1)-s);(p.positions(blpos2,2)+0.5*h) (p.positions(blpos2,2)+0.5*h) p.positions(blpos2,2) (p.positions(blpos2,2)-0.5*h) (p.positions(blpos2,2)-0.5*h) p.positions(blpos2,2)]',1);
    Screen('DrawTexture', ps.window, tex.dot, [], p.dot_rects(blpos2,:,randi(2)), [], [], [], p.dot_BL_col);
    t.time2=Screen('Flip', ps.window, t.time1+stim_end);
    %Ende des ersten Praesentationsteils
    %Fixationskreuz
    Screen('DrawTextures', ps.window, tex.fixbar, [], p.fix_rects, [], [], [], p.fix_col);
    %Figuren
    Screen('DrawTexture', ps.window, tex.distr, [],  p.pos_rects(distr_pos,:), 45, [], [], p.distr_col); %Distraktor
    Screen('DrawTexture', ps.window, tex.target, [],  p.pos_rects(target_pos,:), p.target_rot, [], [], p.target_col); %Target
    Screen('DrawTexture',ps.window, tex.kreis, [], p.circle_rects(blpos1,:), 0, [], [], p.BL_col) %Kreis
    Screen('FillPoly',ps.window,p.BL_col,[(p.positions(blpos2,1)-0.5*s) (p.positions(blpos2,1)+0.5*s) (p.positions(blpos2,1)+s) (p.positions(blpos2,1)+0.5*s) (p.positions(blpos2,1)-0.5*s) (p.positions(blpos2,1)-s);(p.positions(blpos2,2)+0.5*h) (p.positions(blpos2,2)+0.5*h) p.positions(blpos2,2) (p.positions(blpos2,2)-0.5*h) (p.positions(blpos2,2)-0.5*h) p.positions(blpos2,2)]',1); %Sechseck
    %und jetzt kommen die Buchstaben
%     alphabet = 'A' : 'Z';
%     perm = randperm(26);
    Screen('TextSize',ps.window, textgroesse);
    DrawFormattedText(ps.window, alphabet(perm(1)), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter-textgroesse/2, ps.yCenter-p.stim_dist-textgroesse/2, ps.xCenter+textgroesse/2, ps.yCenter-p.stim_dist+textgroesse/2]);
    DrawFormattedText(ps.window, alphabet(perm(2)), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter+p.stim_dist-textgroesse/2, ps.yCenter-textgroesse/2, ps.xCenter+p.stim_dist+textgroesse/2, ps.yCenter+textgroesse/2]);
    DrawFormattedText(ps.window, alphabet(perm(3)), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter-textgroesse/2, ps.yCenter+p.stim_dist-textgroesse/2, ps.xCenter+textgroesse/2, ps.yCenter+p.stim_dist+textgroesse/2]);
    DrawFormattedText(ps.window, alphabet(perm(4)), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter-p.stim_dist-textgroesse/2, ps.yCenter-textgroesse/2, ps.xCenter-p.stim_dist+textgroesse/2, ps.yCenter+textgroesse/2]);
    t.time3=Screen('Flip', ps.window, t.time1+buchstabenend);
    %Ende des zweiten Pr�sentationsteils
    %Fixationskreuz
    Screen('DrawTextures', ps.window, tex.fixbar, [], p.fix_rects, [], [], [], p.fix_col);
    %Figuren
    Screen('TextSize',ps.window, textgroesse*hashtagskalar);
    Screen('DrawTexture', ps.window, tex.distr, [],  p.pos_rects(distr_pos,:), 45, [], [], p.distr_col); %Distraktor
    Screen('DrawTexture', ps.window, tex.target, [],  p.pos_rects(target_pos,:), p.target_rot, [], [], p.target_col); %Target
    Screen('DrawTexture',ps.window, tex.kreis, [], p.circle_rects(blpos1,:), 0, [], [], p.BL_col) %Kreis
    Screen('FillPoly',ps.window,p.BL_col,[(p.positions(blpos2,1)-0.5*s) (p.positions(blpos2,1)+0.5*s) (p.positions(blpos2,1)+s) (p.positions(blpos2,1)+0.5*s) (p.positions(blpos2,1)-0.5*s) (p.positions(blpos2,1)-s);(p.positions(blpos2,2)+0.5*h) (p.positions(blpos2,2)+0.5*h) p.positions(blpos2,2) (p.positions(blpos2,2)-0.5*h) (p.positions(blpos2,2)-0.5*h) p.positions(blpos2,2)]',1); %Sechseck
    %Rauten
    DrawFormattedText(ps.window, sprintf('#'), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter-textgroesse/2, ps.yCenter-p.stim_dist-textgroesse/2, ps.xCenter+textgroesse/2, ps.yCenter-p.stim_dist+textgroesse/2]);
    DrawFormattedText(ps.window, sprintf('#'), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter+p.stim_dist-textgroesse/2, ps.yCenter-textgroesse/2, ps.xCenter+p.stim_dist+textgroesse/2, ps.yCenter+textgroesse/2]);
    DrawFormattedText(ps.window, sprintf('#'), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter-textgroesse/2, ps.yCenter+p.stim_dist-textgroesse/2, ps.xCenter+textgroesse/2, ps.yCenter+p.stim_dist+textgroesse/2]);
    DrawFormattedText(ps.window, sprintf('#'), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter-p.stim_dist-textgroesse/2, ps.yCenter-textgroesse/2, ps.xCenter-p.stim_dist+textgroesse/2, ps.yCenter+textgroesse/2]);
    t.time4=Screen('Flip', ps.window, t.time1+hashtagend);
end

if  strcmp(trialstruct.condition,'p2') %dann brauchen wir Sechseck, Kreis und Quadrat als BL
    Screen('DrawTextures', ps.window, tex.fixbar, [], p.fix_rects, [], [], [], p.fix_col);
    s = sqrt(2)*p.stim_size/(sqrt(3)*sqrt(sqrt(3)));
    h = sqrt(3)*s;
    s=round(s);
    h=round(h);
    r3 = randperm(3);
    blpos1 = pos_pool(r3(1));
    blpos2 = pos_pool(r3(2));
    blpos3 = pos_pool(r3(3));
    %jetzt kommt der Kreis
    Screen('DrawTexture',ps.window, tex.kreis, [], p.circle_rects(blpos1,:), 0, [], [], p.BL_col) 
    Screen('DrawTexture', ps.window, tex.dot, [], p.dot_rects(blpos1,:,randi(2)), [], [], [], p.dot_BL_col);
    % und jetzt kommt das Sechseck
    Screen('FillPoly',ps.window,p.BL_col,[(p.positions(blpos2,1)-0.5*s) (p.positions(blpos2,1)+0.5*s) (p.positions(blpos2,1)+s) (p.positions(blpos2,1)+0.5*s) (p.positions(blpos2,1)-0.5*s) (p.positions(blpos2,1)-s);(p.positions(blpos2,2)+0.5*h) (p.positions(blpos2,2)+0.5*h) p.positions(blpos2,2) (p.positions(blpos2,2)-0.5*h) (p.positions(blpos2,2)-0.5*h) p.positions(blpos2,2)]',1);
    Screen('DrawTexture', ps.window, tex.dot, [], p.dot_rects(blpos2,:,randi(2)), [], [], [], p.dot_BL_col);
    %jetzt kommt das Quadrat
    Screen('DrawTexture', ps.window, tex.quadrat, [],  p.pos_rects(blpos3,:), 0, [], [], p.BL_col);
    Screen('DrawTexture', ps.window, tex.dot, [], p.dot_rects(blpos3,:,randi(2)), [], [], [], p.dot_BL_col);
    t.time2=Screen('Flip', ps.window, t.time1+stim_end);
    %Ende des ersten Praesentationsteils
    %Fixationskreuz
    Screen('DrawTextures', ps.window, tex.fixbar, [], p.fix_rects, [], [], [], p.fix_col);
    %Figuren
    Screen('DrawTexture', ps.window, tex.target, [],  p.pos_rects(target_pos,:), p.target_rot, [], [], p.target_col); %Target
    Screen('DrawTexture',ps.window, tex.kreis, [], p.circle_rects(blpos1,:), 0, [], [], p.BL_col) %Kreis
    Screen('FillPoly',ps.window,p.BL_col,[(p.positions(blpos2,1)-0.5*s) (p.positions(blpos2,1)+0.5*s) (p.positions(blpos2,1)+s) (p.positions(blpos2,1)+0.5*s) (p.positions(blpos2,1)-0.5*s) (p.positions(blpos2,1)-s);(p.positions(blpos2,2)+0.5*h) (p.positions(blpos2,2)+0.5*h) p.positions(blpos2,2) (p.positions(blpos2,2)-0.5*h) (p.positions(blpos2,2)-0.5*h) p.positions(blpos2,2)]',1); %Sechseck
    Screen('DrawTexture', ps.window, tex.quadrat, [],  p.pos_rects(blpos3,:), 0, [], [], p.BL_col); %Quadrat
    %und jetzt kommen die Buchstaben
%     alphabet = 'A' : 'Z';
%     perm = randperm(26);
    Screen('TextSize',ps.window, textgroesse);
    DrawFormattedText(ps.window, alphabet(perm(1)), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter-textgroesse/2, ps.yCenter-p.stim_dist-textgroesse/2, ps.xCenter+textgroesse/2, ps.yCenter-p.stim_dist+textgroesse/2]);
    DrawFormattedText(ps.window, alphabet(perm(2)), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter+p.stim_dist-textgroesse/2, ps.yCenter-textgroesse/2, ps.xCenter+p.stim_dist+textgroesse/2, ps.yCenter+textgroesse/2]);
    DrawFormattedText(ps.window, alphabet(perm(3)), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter-textgroesse/2, ps.yCenter+p.stim_dist-textgroesse/2, ps.xCenter+textgroesse/2, ps.yCenter+p.stim_dist+textgroesse/2]);
    DrawFormattedText(ps.window, alphabet(perm(4)), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter-p.stim_dist-textgroesse/2, ps.yCenter-textgroesse/2, ps.xCenter-p.stim_dist+textgroesse/2, ps.yCenter+textgroesse/2]);
    t.time3=Screen('Flip', ps.window, t.time1+buchstabenend);
    %Ende des zweiten Praesentationsteils
    %Fixationskreuz
    Screen('DrawTextures', ps.window, tex.fixbar, [], p.fix_rects, [], [], [], p.fix_col);
    %Figuren
    Screen('TextSize',ps.window, textgroesse*hashtagskalar);
    Screen('DrawTexture', ps.window, tex.target, [],  p.pos_rects(target_pos,:), p.target_rot, [], [], p.target_col); %Target
    Screen('DrawTexture',ps.window, tex.kreis, [], p.circle_rects(blpos1,:), 0, [], [], p.BL_col) %Kreis
    Screen('FillPoly',ps.window,p.BL_col,[(p.positions(blpos2,1)-0.5*s) (p.positions(blpos2,1)+0.5*s) (p.positions(blpos2,1)+s) (p.positions(blpos2,1)+0.5*s) (p.positions(blpos2,1)-0.5*s) (p.positions(blpos2,1)-s);(p.positions(blpos2,2)+0.5*h) (p.positions(blpos2,2)+0.5*h) p.positions(blpos2,2) (p.positions(blpos2,2)-0.5*h) (p.positions(blpos2,2)-0.5*h) p.positions(blpos2,2)]',1); %Sechseck
    Screen('DrawTexture', ps.window, tex.quadrat, [],  p.pos_rects(blpos3,:), 0, [], [], p.BL_col); %Quadrat
    %Rauten
    DrawFormattedText(ps.window, sprintf('#'), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter-textgroesse/2, ps.yCenter-p.stim_dist-textgroesse/2, ps.xCenter+textgroesse/2, ps.yCenter-p.stim_dist+textgroesse/2]);
    DrawFormattedText(ps.window, sprintf('#'), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter+p.stim_dist-textgroesse/2, ps.yCenter-textgroesse/2, ps.xCenter+p.stim_dist+textgroesse/2, ps.yCenter+textgroesse/2]);
    DrawFormattedText(ps.window, sprintf('#'), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter-textgroesse/2, ps.yCenter+p.stim_dist-textgroesse/2, ps.xCenter+textgroesse/2, ps.yCenter+p.stim_dist+textgroesse/2]);
    DrawFormattedText(ps.window, sprintf('#'), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter-p.stim_dist-textgroesse/2, ps.yCenter-textgroesse/2, ps.xCenter-p.stim_dist+textgroesse/2, ps.yCenter+textgroesse/2]);
    t.time4=Screen('Flip', ps.window, t.time1+hashtagend);
end

if  strcmp(trialstruct.condition,'s2') %dann brauchen wir Sechseck, Kreis und Quadrat als BL
    s = sqrt(2)*p.stim_size/(sqrt(3)*sqrt(sqrt(3)));
    h = sqrt(3)*s;
    s=round(s);
    h=round(h);
    r3 = randperm(3);
    blpos1 = pos_pool(r3(1));
    blpos2 = pos_pool(r3(2));
    blpos3 = pos_pool(r3(3));
    %jetzt kommt der Kreis
    Screen('DrawTexture',ps.window, tex.kreis, [], p.circle_rects(blpos1,:), 0, [], [], p.BL_col) 
    Screen('DrawTexture', ps.window, tex.dot, [], p.dot_rects(blpos1,:,randi(2)), [], [], [], p.dot_BL_col);
    % und jetzt kommt das Sechseck
    Screen('FillPoly',ps.window,p.BL_col,[(p.positions(blpos2,1)-0.5*s) (p.positions(blpos2,1)+0.5*s) (p.positions(blpos2,1)+s) (p.positions(blpos2,1)+0.5*s) (p.positions(blpos2,1)-0.5*s) (p.positions(blpos2,1)-s);(p.positions(blpos2,2)+0.5*h) (p.positions(blpos2,2)+0.5*h) p.positions(blpos2,2) (p.positions(blpos2,2)-0.5*h) (p.positions(blpos2,2)-0.5*h) p.positions(blpos2,2)]',1);
    Screen('DrawTexture', ps.window, tex.dot, [], p.dot_rects(blpos2,:,randi(2)), [], [], [], p.dot_BL_col);
    %jetzt kommt das Quadrat
    Screen('DrawTexture', ps.window, tex.quadrat, [],  p.pos_rects(blpos3,:), 0, [], [], p.BL_col);
    Screen('DrawTexture', ps.window, tex.dot, [], p.dot_rects(blpos3,:,randi(2)), [], [], [], p.dot_BL_col);
end

if  strcmp(trialstruct.condition,'p3') %dann brauchen wir Sechseck, Kreis und Dreieck als BL
    Screen('DrawTextures', ps.window, tex.fixbar, [], p.fix_rects, [], [], [], p.fix_col);
    s = sqrt(2)*p.stim_size/(sqrt(3)*sqrt(sqrt(3)));
    h = sqrt(3)*s;
    s=round(s);
    h=round(h);
    s2 = 2*p.stim_size/(sqrt(sqrt(3)));
    h2 = 0.5*sqrt(3)*s2;
    s2=round(s2);
    h2=round(h2);
    r2 = randperm(3);
    blpos1 = pos_pool(r2(1));
    blpos2 = pos_pool(r2(2));
    blpos3 = pos_pool(r2(3));
    %jetzt kommt der Kreis
    Screen('DrawTexture',ps.window, tex.kreis, [], p.circle_rects(blpos1,:), 0, [], [], p.BL_col); 
    Screen('DrawTexture', ps.window, tex.dot, [], p.dot_rects(blpos1,:,randi(2)), [], [], [], p.dot_BL_col);
    % und jetzt kommt das Sechseck
    Screen('FillPoly',ps.window,p.BL_col,[(p.positions(blpos2,1)-0.5*s) (p.positions(blpos2,1)+0.5*s) (p.positions(blpos2,1)+s) (p.positions(blpos2,1)+0.5*s) (p.positions(blpos2,1)-0.5*s) (p.positions(blpos2,1)-s);(p.positions(blpos2,2)+0.5*h) (p.positions(blpos2,2)+0.5*h) p.positions(blpos2,2) (p.positions(blpos2,2)-0.5*h) (p.positions(blpos2,2)-0.5*h) p.positions(blpos2,2)]',1);
    Screen('DrawTexture', ps.window, tex.dot, [], p.dot_rects(blpos2,:,randi(2)), [], [], [], p.dot_BL_col);
    %jetzt kommt das Dreieck
    Screen('FillPoly',ps.window,p.BL_col,[(p.positions(blpos3,1)-0.5*s2) (p.positions(blpos3,1)+0.5*s2) p.positions(blpos3,1);(p.positions(blpos3,2)+(1/3)*h2) (p.positions(blpos3,2)+(1/3)*h2) (p.positions(blpos3,2)-(2/3)*h2)]');
    Screen('DrawTexture', ps.window, tex.dot, [], p.dot_rects(blpos3,:,randi(2)), [], [], [], p.dot_BL_col);
    t.time2=Screen('Flip', ps.window, t.time1+stim_end);
    %Ende des ersten Praesentationsteils
    %Fixationskreuz
    Screen('DrawTextures', ps.window, tex.fixbar, [], p.fix_rects, [], [], [], p.fix_col);
    %Figuren
    Screen('DrawTexture', ps.window, tex.target, [],  p.pos_rects(target_pos,:), p.target_rot, [], [], p.target_col); %Target
    Screen('DrawTexture',ps.window, tex.kreis, [], p.circle_rects(blpos1,:), 0, [], [], p.BL_col); %Kreis
    Screen('FillPoly',ps.window,p.BL_col,[(p.positions(blpos2,1)-0.5*s) (p.positions(blpos2,1)+0.5*s) (p.positions(blpos2,1)+s) (p.positions(blpos2,1)+0.5*s) (p.positions(blpos2,1)-0.5*s) (p.positions(blpos2,1)-s);(p.positions(blpos2,2)+0.5*h) (p.positions(blpos2,2)+0.5*h) p.positions(blpos2,2) (p.positions(blpos2,2)-0.5*h) (p.positions(blpos2,2)-0.5*h) p.positions(blpos2,2)]',1); %Sechseck
    Screen('FillPoly',ps.window,p.BL_col,[(p.positions(blpos3,1)-0.5*s2) (p.positions(blpos3,1)+0.5*s2) p.positions(blpos3,1);(p.positions(blpos3,2)+(1/3)*h2) (p.positions(blpos3,2)+(1/3)*h2) (p.positions(blpos3,2)-(2/3)*h2)]'); %Dreieck
    %und jetzt kommen die Buchstaben
%     alphabet = 'A' : 'Z';
%     perm = randperm(26);
    Screen('TextSize',ps.window, textgroesse);
    DrawFormattedText(ps.window, alphabet(perm(1)), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter-textgroesse/2, ps.yCenter-p.stim_dist-textgroesse/2, ps.xCenter+textgroesse/2, ps.yCenter-p.stim_dist+textgroesse/2]);
    DrawFormattedText(ps.window, alphabet(perm(2)), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter+p.stim_dist-textgroesse/2, ps.yCenter-textgroesse/2, ps.xCenter+p.stim_dist+textgroesse/2, ps.yCenter+textgroesse/2]);
    DrawFormattedText(ps.window, alphabet(perm(3)), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter-textgroesse/2, ps.yCenter+p.stim_dist-textgroesse/2, ps.xCenter+textgroesse/2, ps.yCenter+p.stim_dist+textgroesse/2]);
    DrawFormattedText(ps.window, alphabet(perm(4)), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter-p.stim_dist-textgroesse/2, ps.yCenter-textgroesse/2, ps.xCenter-p.stim_dist+textgroesse/2, ps.yCenter+textgroesse/2]);
    t.time3=Screen('Flip', ps.window, t.time1+buchstabenend);
    %Ende des zweiten Praesentationsteils
    %Fixationskreuz
    Screen('DrawTextures', ps.window, tex.fixbar, [], p.fix_rects, [], [], [], p.fix_col);
    %Figuren
    Screen('TextSize',ps.window, textgroesse*hashtagskalar);
    Screen('DrawTexture', ps.window, tex.target, [],  p.pos_rects(target_pos,:), p.target_rot, [], [], p.target_col); %Target
    Screen('DrawTexture',ps.window, tex.kreis, [], p.circle_rects(blpos1,:), 0, [], [], p.BL_col); %Kreis
    Screen('FillPoly',ps.window,p.BL_col,[(p.positions(blpos2,1)-0.5*s) (p.positions(blpos2,1)+0.5*s) (p.positions(blpos2,1)+s) (p.positions(blpos2,1)+0.5*s) (p.positions(blpos2,1)-0.5*s) (p.positions(blpos2,1)-s);(p.positions(blpos2,2)+0.5*h) (p.positions(blpos2,2)+0.5*h) p.positions(blpos2,2) (p.positions(blpos2,2)-0.5*h) (p.positions(blpos2,2)-0.5*h) p.positions(blpos2,2)]',1); %Sechseck
    Screen('FillPoly',ps.window,p.BL_col,[(p.positions(blpos3,1)-0.5*s2) (p.positions(blpos3,1)+0.5*s2) p.positions(blpos3,1);(p.positions(blpos3,2)+(1/3)*h2) (p.positions(blpos3,2)+(1/3)*h2) (p.positions(blpos3,2)-(2/3)*h2)]'); %Dreieck
    %Rauten
    DrawFormattedText(ps.window, sprintf('#'), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter-textgroesse/2, ps.yCenter-p.stim_dist-textgroesse/2, ps.xCenter+textgroesse/2, ps.yCenter-p.stim_dist+textgroesse/2]);
    DrawFormattedText(ps.window, sprintf('#'), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter+p.stim_dist-textgroesse/2, ps.yCenter-textgroesse/2, ps.xCenter+p.stim_dist+textgroesse/2, ps.yCenter+textgroesse/2]);
    DrawFormattedText(ps.window, sprintf('#'), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter-textgroesse/2, ps.yCenter+p.stim_dist-textgroesse/2, ps.xCenter+textgroesse/2, ps.yCenter+p.stim_dist+textgroesse/2]);
    DrawFormattedText(ps.window, sprintf('#'), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter-p.stim_dist-textgroesse/2, ps.yCenter-textgroesse/2, ps.xCenter-p.stim_dist+textgroesse/2, ps.yCenter+textgroesse/2]);
    t.time4=Screen('Flip', ps.window, t.time1+hashtagend);
end

if  strcmp(trialstruct.condition,'s3') %dann brauchen wir Sechseck, Kreis und Dreieck als BL
    s = sqrt(2)*p.stim_size/(sqrt(3)*sqrt(sqrt(3)));
    h = sqrt(3)*s;
    s=round(s);
    h=round(h);
    s2 = 2*p.stim_size/(sqrt(sqrt(3)));
    h2 = 0.5*sqrt(3)*s2;
    s2=round(s2);
    h2=round(h2);
    r2 = randperm(3);
    blpos1 = pos_pool(r2(1));
    blpos2 = pos_pool(r2(2));
    blpos3 = pos_pool(r2(3));
    %jetzt kommt der Kreis
    Screen('DrawTexture',ps.window, tex.kreis, [], p.circle_rects(blpos1,:), 0, [], [], p.BL_col) 
    Screen('DrawTexture', ps.window, tex.dot, [], p.dot_rects(blpos1,:,randi(2)), [], [], [], p.dot_BL_col);
    % und jetzt kommt das Sechseck
    Screen('FillPoly',ps.window,p.BL_col,[(p.positions(blpos2,1)-0.5*s) (p.positions(blpos2,1)+0.5*s) (p.positions(blpos2,1)+s) (p.positions(blpos2,1)+0.5*s) (p.positions(blpos2,1)-0.5*s) (p.positions(blpos2,1)-s);(p.positions(blpos2,2)+0.5*h) (p.positions(blpos2,2)+0.5*h) p.positions(blpos2,2) (p.positions(blpos2,2)-0.5*h) (p.positions(blpos2,2)-0.5*h) p.positions(blpos2,2)]',1);
    Screen('DrawTexture', ps.window, tex.dot, [], p.dot_rects(blpos2,:,randi(2)), [], [], [], p.dot_BL_col);
    %jetzt kommt das Dreieck
    Screen('FillPoly',ps.window,p.BL_col,[(p.positions(blpos3,1)-0.5*s2) (p.positions(blpos3,1)+0.5*s2) p.positions(blpos3,1);(p.positions(blpos3,2)+(1/3)*h2) (p.positions(blpos3,2)+(1/3)*h2) (p.positions(blpos3,2)-(2/3)*h2)]');
    Screen('DrawTexture', ps.window, tex.dot, [], p.dot_rects(blpos3,:,randi(2)), [], [], [], p.dot_BL_col);
end
    
if strcmp(trialstruct.condition,'p5') %dann brauchen wir zwei Quadrate als BL
    Screen('DrawTextures', ps.window, tex.fixbar, [], p.fix_rects, [], [], [], p.fix_col);
    for bl = 1:length(pos_pool)    
      Screen('DrawTexture',ps.window, tex.quadrat, [], p.pos_rects(pos_pool(bl),:), 0, [], [], p.BL_col) 
      Screen('DrawTexture', ps.window, tex.dot, [], p.dot_rects(pos_pool(bl),:,randi(2)), [], [], [], p.dot_BL_col);
    end
    t.time2=Screen('Flip', ps.window, t.time1+stim_end);
    %Ende des ersten Praesentationsteils
    %Fixationskreuz
    Screen('DrawTextures', ps.window, tex.fixbar, [], p.fix_rects, [], [], [], p.fix_col);
    %Figuren
    s3 = 2*p.stim_size/(sqrt(sqrt(3)));
    h3 = 0.5*sqrt(3)*s3;
    s3=round(s3);
    h3=round(h3);
    Screen('FillPoly',ps.window,p.distr_col,[(p.positions(distr_pos,1)-0.5*s3) (p.positions(distr_pos,1)+0.5*s3) p.positions(distr_pos,1);(p.positions(distr_pos,2)+(1/3)*h3) (p.positions(distr_pos,2)+(1/3)*h3) (p.positions(distr_pos,2)-(2/3)*h3)]'); %Distraktor
    Screen('DrawTexture', ps.window, tex.target, [],  p.pos_rects(target_pos,:), p.target_rot, [], [], p.target_col); %Target
    for bl = 1:length(pos_pool)    
     Screen('DrawTexture',ps.window, tex.quadrat, [], p.pos_rects(pos_pool(bl),:), 0, [], [], p.BL_col) 
     Screen('DrawTexture', ps.window, tex.dot, [], p.dot_rects(pos_pool(bl),:,randi(2)), [], [], [], p.dot_BL_col);
    end
    %und jetzt kommen die Buchstaben
%     alphabet = 'A' : 'Z';
%     perm = randperm(26);
    Screen('TextSize',ps.window, textgroesse);
    DrawFormattedText(ps.window, alphabet(perm(1)), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter-textgroesse/2, ps.yCenter-p.stim_dist-textgroesse/2, ps.xCenter+textgroesse/2, ps.yCenter-p.stim_dist+textgroesse/2]);
    DrawFormattedText(ps.window, alphabet(perm(2)), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter+p.stim_dist-textgroesse/2, ps.yCenter-textgroesse/2, ps.xCenter+p.stim_dist+textgroesse/2, ps.yCenter+textgroesse/2]);
    DrawFormattedText(ps.window, alphabet(perm(3)), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter-textgroesse/2, ps.yCenter+p.stim_dist-textgroesse/2, ps.xCenter+textgroesse/2, ps.yCenter+p.stim_dist+textgroesse/2]);
    DrawFormattedText(ps.window, alphabet(perm(4)), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter-p.stim_dist-textgroesse/2, ps.yCenter-textgroesse/2, ps.xCenter-p.stim_dist+textgroesse/2, ps.yCenter+textgroesse/2]);
    t.time3=Screen('Flip', ps.window, t.time1+buchstabenend);
    %Ende des zweiten Praesentationsteils
    %Fixationskreuz
    Screen('DrawTextures', ps.window, tex.fixbar, [], p.fix_rects, [], [], [], p.fix_col);
    %Figuren
    Screen('TextSize',ps.window, textgroesse*hashtagskalar);
    Screen('FillPoly',ps.window,p.distr_col,[(p.positions(distr_pos,1)-0.5*s3) (p.positions(distr_pos,1)+0.5*s3) p.positions(distr_pos,1);(p.positions(distr_pos,2)+(1/3)*h3) (p.positions(distr_pos,2)+(1/3)*h3) (p.positions(distr_pos,2)-(2/3)*h3)]'); %Distraktor
    Screen('DrawTexture', ps.window, tex.target, [],  p.pos_rects(target_pos,:), p.target_rot, [], [], p.target_col); %Target
    for bl = 1:length(pos_pool)    
     Screen('DrawTexture',ps.window, tex.quadrat, [], p.pos_rects(pos_pool(bl),:), 0, [], [], p.BL_col) 
     Screen('DrawTexture', ps.window, tex.dot, [], p.dot_rects(pos_pool(bl),:,randi(2)), [], [], [], p.dot_BL_col);
    end
    %Rauten
    DrawFormattedText(ps.window, sprintf('#'), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter-textgroesse/2, ps.yCenter-p.stim_dist-textgroesse/2, ps.xCenter+textgroesse/2, ps.yCenter-p.stim_dist+textgroesse/2]);
    DrawFormattedText(ps.window, sprintf('#'), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter+p.stim_dist-textgroesse/2, ps.yCenter-textgroesse/2, ps.xCenter+p.stim_dist+textgroesse/2, ps.yCenter+textgroesse/2]);
    DrawFormattedText(ps.window, sprintf('#'), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter-textgroesse/2, ps.yCenter+p.stim_dist-textgroesse/2, ps.xCenter+textgroesse/2, ps.yCenter+p.stim_dist+textgroesse/2]);
    DrawFormattedText(ps.window, sprintf('#'), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter-p.stim_dist-textgroesse/2, ps.yCenter-textgroesse/2, ps.xCenter-p.stim_dist+textgroesse/2, ps.yCenter+textgroesse/2]);
    t.time4=Screen('Flip', ps.window, t.time1+hashtagend);
end 

if strcmp(trialstruct.condition,'s5') %dann brauchen wir zwei Quadrate als BL
   for bl = 1:length(pos_pool)    
     Screen('DrawTexture',ps.window, tex.quadrat, [], p.pos_rects(pos_pool(bl),:), 0, [], [], p.BL_col) 
     Screen('DrawTexture', ps.window, tex.dot, [], p.dot_rects(pos_pool(bl),:,randi(2)), [], [], [], p.dot_BL_col);
  end 
end 

if strcmp(trialstruct.condition,'s6') %dann brauchen wir zwei schiefe Quadrate als BL
   for bl = 1:length(pos_pool)
     r1 = randi(2);
     if r1 == 1
         neigung = 22.5;
     else
         neigung = 337.5;
     end
     Screen('DrawTexture',ps.window, tex.quadrat, [], p.pos_rects(pos_pool(bl),:), neigung, [], [], p.BL_col) 
     Screen('DrawTexture', ps.window, tex.dot, [], p.dot_rects(pos_pool(bl),:,randi(2)), [], [], [], p.dot_BL_col);
  end 
end 

if  strcmp(trialstruct.condition,'p6') %dann brauchen wir zwei schiefe Quadrate als BL
    Screen('DrawTextures', ps.window, tex.fixbar, [], p.fix_rects, [], [], [], p.fix_col);
    blpos1 = pos_pool(1);
    blpos2 = pos_pool(2);
    r1 = randi(2);
    if r1 == 1
        neigung1 = 22.5;
    else
        neigung1 = 337.5;
    end
    Screen('DrawTexture',ps.window, tex.quadrat, [], p.pos_rects(blpos1,:), neigung1, [], [], p.BL_col); 
    Screen('DrawTexture', ps.window, tex.dot, [], p.dot_rects(blpos1,:,randi(2)), [], [], [], p.dot_BL_col);
    r3=randi(2);
    if r3 ==1
        neigung2 = 22.5;
    else
        neigung2 = 337.5;
    end
    Screen('DrawTexture',ps.window, tex.quadrat, [], p.pos_rects(blpos2,:), neigung2, [], [], p.BL_col); 
    Screen('DrawTexture', ps.window, tex.dot, [], p.dot_rects(blpos2,:,randi(2)), [], [], [], p.dot_BL_col);
    t.time2=Screen('Flip', ps.window, t.time1+stim_end);
    %Ende des ersten Praesentationsteils
    %Fixationskreuz
    Screen('DrawTextures', ps.window, tex.fixbar, [], p.fix_rects, [], [], [], p.fix_col);
    %Figuren
    s3 = 2*p.stim_size/(sqrt(sqrt(3)));
    h3 = 0.5*sqrt(3)*s3;
    s3=round(s3);
    h3=round(h3);
    Screen('FillPoly',ps.window,p.distr_col,[(p.positions(distr_pos,1)-0.5*s3) (p.positions(distr_pos,1)+0.5*s3) p.positions(distr_pos,1);(p.positions(distr_pos,2)+(1/3)*h3) (p.positions(distr_pos,2)+(1/3)*h3) (p.positions(distr_pos,2)-(2/3)*h3)]'); %Distraktor
    Screen('DrawTexture', ps.window, tex.target, [],  p.pos_rects(target_pos,:), p.target_rot, [], [], p.target_col); %Target
    Screen('DrawTexture',ps.window, tex.quadrat, [], p.pos_rects(blpos1,:), neigung1, [], [], p.BL_col); %ein schiefes Quadrat
    Screen('DrawTexture',ps.window, tex.quadrat, [], p.pos_rects(blpos2,:), neigung2, [], [], p.BL_col); %anderes schiefes Quadrat
    %und jetzt kommen die Buchstaben
%     alphabet = 'A' : 'Z';
%     perm = randperm(26);
    Screen('TextSize',ps.window, textgroesse);
    DrawFormattedText(ps.window, alphabet(perm(1)), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter-textgroesse/2, ps.yCenter-p.stim_dist-textgroesse/2, ps.xCenter+textgroesse/2, ps.yCenter-p.stim_dist+textgroesse/2]);
    DrawFormattedText(ps.window, alphabet(perm(2)), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter+p.stim_dist-textgroesse/2, ps.yCenter-textgroesse/2, ps.xCenter+p.stim_dist+textgroesse/2, ps.yCenter+textgroesse/2]);
    DrawFormattedText(ps.window, alphabet(perm(3)), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter-textgroesse/2, ps.yCenter+p.stim_dist-textgroesse/2, ps.xCenter+textgroesse/2, ps.yCenter+p.stim_dist+textgroesse/2]);
    DrawFormattedText(ps.window, alphabet(perm(4)), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter-p.stim_dist-textgroesse/2, ps.yCenter-textgroesse/2, ps.xCenter-p.stim_dist+textgroesse/2, ps.yCenter+textgroesse/2]);
    t.time3=Screen('Flip', ps.window, t.time1+buchstabenend);
    %Ende des zweiten Praesentationsteils
    %Fixationskreuz
    Screen('DrawTextures', ps.window, tex.fixbar, [], p.fix_rects, [], [], [], p.fix_col);
    %Figuren
    Screen('TextSize',ps.window, textgroesse*hashtagskalar);
    Screen('FillPoly',ps.window,p.distr_col,[(p.positions(distr_pos,1)-0.5*s3) (p.positions(distr_pos,1)+0.5*s3) p.positions(distr_pos,1);(p.positions(distr_pos,2)+(1/3)*h3) (p.positions(distr_pos,2)+(1/3)*h3) (p.positions(distr_pos,2)-(2/3)*h3)]'); %Distraktor
    Screen('DrawTexture', ps.window, tex.target, [],  p.pos_rects(target_pos,:), p.target_rot, [], [], p.target_col); %Target
    Screen('DrawTexture',ps.window, tex.quadrat, [], p.pos_rects(blpos1,:), neigung1, [], [], p.BL_col); %ein schiefes Quadrat
    Screen('DrawTexture',ps.window, tex.quadrat, [], p.pos_rects(blpos2,:), neigung2, [], [], p.BL_col); %anderes schiefes Quadrat
    %Rauten
    DrawFormattedText(ps.window, sprintf('#'), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter-textgroesse/2, ps.yCenter-p.stim_dist-textgroesse/2, ps.xCenter+textgroesse/2, ps.yCenter-p.stim_dist+textgroesse/2]);
    DrawFormattedText(ps.window, sprintf('#'), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter+p.stim_dist-textgroesse/2, ps.yCenter-textgroesse/2, ps.xCenter+p.stim_dist+textgroesse/2, ps.yCenter+textgroesse/2]);
    DrawFormattedText(ps.window, sprintf('#'), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter-textgroesse/2, ps.yCenter+p.stim_dist-textgroesse/2, ps.xCenter+textgroesse/2, ps.yCenter+p.stim_dist+textgroesse/2]);
    DrawFormattedText(ps.window, sprintf('#'), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter-p.stim_dist-textgroesse/2, ps.yCenter-textgroesse/2, ps.xCenter-p.stim_dist+textgroesse/2, ps.yCenter+textgroesse/2]);
    t.time4=Screen('Flip', ps.window, t.time1+hashtagend);
end

Screen('DrawTextures', ps.window, tex.fixbar, [], p.fix_rects, [], [], [], p.fix_col); %add fixation cross

if trialstruct.condition(1) == 's'
    t.time2=Screen('Flip', ps.window, t.time1+pre_fix_end);
%     lptwrite(1,trigger,500);

% draw image of trial
% img = Screen('GetImage', ps.window);
% imwrite(img,['/home/pc/matlab/user/maria/test.png']);

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
            lptwrite(1,key,500);
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
%<<<<<<< HEAD
    abstand = 400;
    akt=1;
    n=0;
    RestrictKeysForKbCheck(KbName({'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','backspace','Return'}));
%     DrawFormattedText(ps.window, sprintf('An welche Buchstaben erinnern Sie sich?'), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter, ps.yCenter-20-300, ps.xCenter, ps.yCenter-20+300]);
    while unfertig == true
        n=n+1;
        DrawFormattedText(ps.window, sprintf('An welche Buchstaben erinnern Sie sich?'), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter, ps.yCenter-200-300, ps.xCenter, ps.yCenter-200+300]);
        Screen('Flip',ps.window,[],1);
        gedrueckt = false;
        while ~gedrueckt
%             try
                [keyIsDown, secs, keyCode] = KbCheck;
                if keyIsDown 
                    gedrueckt = true;
                end
%             catch ME 
%                 fprintf('test1');
%             end    
        end
        try
            if keyCode(KbName('Return'))
                Screen('Flip', ps.window);
                unfertig = false;
            else
                for i = 1:(akt-1)
                    DrawFormattedText(ps.window, sprintf(ansbuchst{i}), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter+(abstand*i-2.5*abstand), ps.yCenter-textgroesse/2, ps.xCenter+(abstand*i-2.5*abstand), ps.yCenter+textgroesse/2]);
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
                    end
                    Screen('Flip',ps.window,[],1);
                    WaitSecs(0.5);
%                    if (keyCode(KbName('DELETE')) && (akt > 1))
                ansbuchst{akt}='';
                akt = akt-1;
                Screen('Flip',ps.window,secs);
                else
                if akt <5
                    dieser = KbName(keyCode);
                    if ~isempty(dieser)
                        ansbuchst{akt} = dieser;
                    end
                    DrawFormattedText(ps.window, sprintf(ansbuchst{akt}), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter+(abstand*akt-2.5*abstand), ps.yCenter-textgroesse/2, ps.xCenter+(abstand*akt-2.5*abstand), ps.yCenter+textgroesse/2]);
                    Screen('Flip', ps.window, secs+0.5);
                    akt = akt +1;
%>>>>>>> 07cc45f098b8dd42a5b553095f93fadb76bd66f1
                else
                    
                if akt <5 %keine doppelten Buchstaben!
                    dieser = KbName(keyCode);
    %                 DrawFormattedText(ps.window, sprintf(ansbuchst{akt}), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter+(abstand*akt-2.5*abstand), ps.yCenter-textgroesse/2, ps.xCenter+(abstand*akt-2.5*abstand), ps.yCenter+textgroesse/2]);
                    doppelt = false;
                    for i = 1:akt
                        if ansbuchst{i} == upper(dieser)
                            doppelt = true;
                        end    
                    end 
                    
                    if (~isempty(dieser) && ~doppelt)
                        ansbuchst{akt} = upper(dieser);
                        DrawFormattedText(ps.window, sprintf(ansbuchst{akt}), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter+(abstand*akt-2.5*abstand), ps.yCenter-textgroesse/2, ps.xCenter+(abstand*akt-2.5*abstand), ps.yCenter+textgroesse/2]);
                        akt = akt +1;
                        Screen('Flip',ps.window,[],1);
                        WaitSecs(0.5);
                    end
                    
    %                 DrawFormattedText(ps.window, sprintf(ansbuchst{akt}), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter+(abstand*akt-2.5*abstand), ps.yCenter-textgroesse/2, ps.xCenter+(abstand*akt-2.5*abstand), ps.yCenter+textgroesse/2]);
    %                 akt = akt +1;
                end
                
                Screen('Flip',ps.window,[],1);
                % WaitSecs(0.5);
                end
            end
        end
        catch ME2
            fprintf('test2');
        end
    end
    r.buchstaben=ansbuchst;
%=======
%     ansbuchst(2)='';
%     ansbuchst(3)='';
%     ansbuchst(4)='';
%     abstand = 100;
%     akt=1;
%     n=0;
%     while unfertig == true
%         n=n+1;
%         DrawFormattedText(ps.window, sprintf('An welche Buchstaben erinnern Sie sich?'), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter, ps.yCenter-20-300, ps.xCenter, ps.yCenter-20+300]);
%         [keyIsDown, secs, keyCode] = KbCheck;
%         %taste = find(keyCode);
%         if keyCode(KbName('Return'))
%             Screen('Flip', ps.window, secs);
%             unfertig = false;
%         else
%             for i = 1:akt-1
%                 DrawFormattedText(ps.window, sprintf(ansbuchst{i}), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter+(abstand*i-2.5*abstand), ps.yCenter-textgroesse/2, ps.xCenter+(abstand*i-2.5*abstand), ps.yCenter+textgroesse/2]);
%             end
            
            
%             if (keyCode(KbName('DELETE')) && (akt > 1))
%                 ansbuchst{akt}='';
%                 akt = akt-1;
%                 Screen('Flip',ps.window,secs);
%             else
%                 if akt <5
%                     dieser = KbName(keyCode);
%                     if ~isempty(dieser)
%                         ansbuchst{akt} = dieser;
%                     end
%                     DrawFormattedText(ps.window, sprintf(ansbuchst{akt}), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter+(abstand*akt-2.5*abstand), ps.yCenter-textgroesse/2, ps.xCenter+(abstand*akt-2.5*abstand), ps.yCenter+textgroesse/2]);
%                     Screen('Flip', ps.window, secs+0.5);
%                     akt = akt +1;
% %>>>>>>> 07cc45f098b8dd42a5b553095f93fadb76bd66f1
%                 else
%                 if akt <5 %keine doppelten Buchstaben!
%                     dieser = KbName(keyCode);
%     %                 DrawFormattedText(ps.window, sprintf(ansbuchst{akt}), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter+(abstand*akt-2.5*abstand), ps.yCenter-textgroesse/2, ps.xCenter+(abstand*akt-2.5*abstand), ps.yCenter+textgroesse/2]);
%                     doppelt = false;
%                     for i = 1:akt
%                         if ansbuchst{i} == upper(dieser)
%                             doppelt = true;
%                         end    
%                     end    
%                     if (~isempty(dieser) && ~doppelt)
%                         ansbuchst{akt} = upper(dieser);
%                         DrawFormattedText(ps.window, sprintf(ansbuchst{akt}), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter+(abstand*akt-2.5*abstand), ps.yCenter-textgroesse/2, ps.xCenter+(abstand*akt-2.5*abstand), ps.yCenter+textgroesse/2]);
%                         akt = akt +1;
%                         Screen('Flip',ps.window,[],1);
%                         WaitSecs(0.5);
%                     end
%     %                 DrawFormattedText(ps.window, sprintf(ansbuchst{akt}), 'center', 'center', p.fix_col, [], [], [], [], [], [ps.xCenter+(abstand*akt-2.5*abstand), ps.yCenter-textgroesse/2, ps.xCenter+(abstand*akt-2.5*abstand), ps.yCenter+textgroesse/2]);
%     %                 akt = akt +1;
%                 end
%                 Screen('Flip',ps.window,[],1);
%                 % WaitSecs(0.5);
%                 end
%             end
%         catch ME2
%             fprintf('test2');
%         end
%     end
%     r.buchstaben=ansbuchst;
    
    
end    
    



%WaitSecs('UntilTime',t.time4+p.ITI); %cumulative timing
WaitSecs('UntilTime',t.time1+ITI_end);

end