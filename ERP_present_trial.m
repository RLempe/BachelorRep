function [ r, t ] = ERP_present_trial( p, ps, trialstruct, tex )
%ERP_present_trial presents one trial

% --- definition of trial variables ---
target_pos = trialstruct.target_pos;
distr_pos = trialstruct.distr_pos;
dot_target_pos = trialstruct.dot_target_pos;
dot_distr_pos = trialstruct.dot_distr_pos;
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
% timing structure (base all timing on trial start, to prevent cumulation of delay)
pre_fix_end = p.pre_fix_min+jitter;
stim_end = pre_fix_end+p.stim_duration;
post_fix_end = stim_end+p.post_fix_min;
ITI_end = post_fix_end + p.ITI;

%FIX restrict response keys extra?

% --- draw fixation ---
Screen('DrawTextures', ps.window, tex.fixbar, [], p.fix_rects, [], [], [], p.fix_col);
t.time1=Screen('Flip', ps.window, 0);

% --- draw stimuli ---
pos_pool = [1 2 3 4];               % create a pool for all four stimulus positions
if target_pos                       % draw target (with dots) if present
Screen('DrawTexture', ps.window, tex.target, [],  p.pos_rects(target_pos,:), p.target_rot, [], [], p.target_col);
%Screen('DrawTexture', ps.window, tex.dot, [], dot_target_rect, [], [], [], p.dot_target_col);
Screen('DrawTexture', ps.window, tex.dot, [], p.dot_rects(target_pos,:,dot_target_pos), [], [], [], p.dot_target_col);
pos_pool(pos_pool==target_pos)=[];  % take drawn target out of position pool
end

if distr_pos                        % draw distractor (with dots) if present
Screen('DrawTexture', ps.window, tex.distr, [],  p.pos_rects(distr_pos,:), p.distr_rot, [], [], p.distr_col);
%Screen('DrawTexture', ps.window, tex.dot, [],  dot_distr_rect, [], [], [], p.dot_distr_col);
Screen('DrawTexture', ps.window, tex.dot, [], p.dot_rects(distr_pos,:,dot_distr_pos), [], [], [], p.dot_distr_col); 
pos_pool(pos_pool==distr_pos)=[];   % take drawn distractor out of position pool
end

for bl = 1:length(pos_pool)    
    Screen('DrawTexture',ps.window, tex.BL, [], p.circle_rects(pos_pool(bl),:), 0, [], [], p.BL_col) 
    Screen('DrawTexture', ps.window, tex.dot, [], p.dot_rects(pos_pool(bl),:,randi(2)), [], [], [], p.dot_BL_col); %FIX also define dot positions in trial struct?
end

Screen('DrawTextures', ps.window, tex.fixbar, [], p.fix_rects, [], [], [], p.fix_col); %add fixation cross

t.time2=Screen('Flip', ps.window, t.time1+pre_fix_end);
lptwrite(1,trigger,500);

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

%WaitSecs('UntilTime',t.time4+p.ITI); %cumulative timing
WaitSecs('UntilTime',t.time1+ITI_end);

end