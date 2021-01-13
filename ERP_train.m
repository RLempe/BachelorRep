function [est] = ERP_train( p, ps, trialstruct, tex )
%ERP_TRAIN training for ERP experiment
%   presents task dots with different luminance values; estimates the
%   luminance value where participant performs with the defined threshold;
%   repeat training until you are happy with the fit

levels = linspace(p.dot_lum_min, p.dot_lum_max, p.dot_lum_steps);  %create a vector with all possible color changes, e.g. -.1 -.15 -.2 -.25 -.3 
all_levels = [];
t_response(1)= struct('condition',nan,'hit',0,'RT',0,'error',0,'errorRT',0,'miss',0,'FA',0,'FART',0,'dFA',0,'dFART',0,'buchstaben',nan,'perm',nan,'target_pos',nan,'distr_pos',nan);

do_train = 1;
train_run = 0;

while do_train    
    train_run = train_run + 1;
    
    %define new trial & luminance randomization for every training run
    
    searchmatrix = [];
    searchmatrix(1).condition="";
    searchmatrix(1).target_pos=0;
    searchmatrix(1).distr_pos=0;
    searchmatrix(1).dot_target_pos=0;
    searchmatrix(1).dot_distr_pos=0;
    searchmatrix(1).jitter=0;
    searchmatrix(1).perm = randperm(4);
    s = 1;
    
    probematrix = [];
    probematrix(1).condition="";
    probematrix(1).target_pos=0;
    probematrix(1).distr_pos=0;
    probematrix(1).dot_target_pos=0;
    probematrix(1).dot_distr_pos=0;
    probematrix(1).jitter=0;
    probematrix(1).perm = randperm(4);
    pr = 1;
    
    for i = 1:length(trialstruct)
        if (trialstruct(i).condition(1) == 's')
            searchmatrix(s) = trialstruct(i);
            s = s+1;
        else
            probematrix(pr) = trialstruct(i);
            pr = pr+1;
        end    
    end    
    
    % Search oder Probe?
    
    key_check = 0;
    traincon = 'b';
%     fprintf('Search oder Beides? s/b');
%     while key_check == 0
%         [keyIsDown, ~, keyCode] = KbCheck;
%         if keyIsDown && keyCode(KbName('s'))
%             key_check = 1;
%             traincon = 's';
%             WaitSecs(0.3);
%         end
%         if keyIsDown && keyCode(KbName('b'))
%             key_check = 1;
%             traincon = 'b';
%             WaitSecs(0.3);
%         end
%     end
    
   
    traintrialstruct = ERP_trialstruct(p);
    
    %t_trialstruct = trialstruct(randsample(length(trialstruct),p.train_trials)); %choose a random sample of trials 
    if traincon == 's'
        t_trialstruct = searchmatrix(randsample(length(searchmatrix),p.train_trials));
    else
        t_trialstruct = traintrialstruct(randsample(length(traintrialstruct),p.train_trials));
    end
    levels_arr = repmat(levels,1,ceil(p.train_trials/length(levels)));           %repeat the values 
    levels_arr = Shuffle(levels_arr(1:p.train_trials));                          %shuffle and cut them to trial number
    all_levels = [all_levels levels_arr];                                        %attatch luminance vector for every train run
    t_behavior(1) = struct('hitrate',0,'errorrate',0,'FArate',0,'meanRT',0);
    
    %Start Screen
    Screen('TextSize', ps.window, 40);
    DrawFormattedText(ps.window, ['Starte mit Training'],'center', 'center', p.fix_col);
    Screen('TextSize', ps.window, 25);
    DrawFormattedText(ps.window, ['Achte auf:\n' p.target_shape ' ' p.target_col_label],'center', 700, p.fix_col);
    Screen('Flip', ps.window, 0);
    WaitSecs(0.3);
    [~, ~, keyCode] = KbCheck; 
        while keyCode(KbName('space')) == 0
            [~, ~, keyCode] = KbCheck;
        end                           
    fprintf(['\nStart Training\n']);
    WaitSecs(0.5);
    
    %Trial presentation for one run
    for t = 1:p.train_trials
        t_idx = t + (train_run-1)*p.train_trials;
        %define new dot color for every trial
        
        p.dot_target_col(find(p.target_col)) = p.target_col(find(p.target_col)) - ... %modify only the positions where there are positive RGB values
        levels_arr(t)*(p.target_col(find(p.target_col))/max(p.target_col));  %take the current luminance change out of array and multiply it with the ratio of the RGB values (to keep the color ratio of mixed colors)
        p.dot_distr_col(find(p.distr_col))   = p.distr_col(find(p.distr_col)) - ...
        levels_arr(t)*(p.distr_col(find(p.distr_col))/max(p.distr_col));
        p.dot_BL_col(find(p.BL_col))         = p.BL_col(find(p.BL_col)) - ...
        levels_arr(t)*(p.BL_col(find(p.BL_col))/max(p.BL_col));
        
        [t_response(t_idx), ~] = ERP_present_trial(p,ps,t_trialstruct(t),tex); %t_response: training runs are iteratively attached 
    end
    
    %Analyse behavior of one run
    t_behavior = ERP_eval_trials((1+(train_run-1)*p.train_trials):train_run*p.train_trials,t_response);
     
    %Display results of this run
    Screen('TextSize', ps.window, 20); 
    DrawFormattedText(ps.window, sprintf('Richtige Reaktionen:  %1.0f %%',t_behavior.hitrate*100),'center', 600, p.fix_col);
    DrawFormattedText(ps.window, sprintf('Fehlerrate:  %1.0f %%',t_behavior.errorrate*100),'center', 650, p.fix_col);
    DrawFormattedText(ps.window, sprintf('Rate Falscher Alarme:  %1.0f %%',t_behavior.FArate*100),'center', 700, p.fix_col);             
    DrawFormattedText(ps.window, sprintf('Reaktionszeit:  %1.0f ms',t_behavior.meanRT*1000),'center', 750, p.fix_col);
    if traincon == 'b'
       DrawFormattedText(ps.window, sprintf('Richtige Buchstaben:  %1.0f %%',t_behavior.richtige*100),'center', 800, p.fix_col); 
    end    

    fprintf(1,'\n###\nRichtige Reaktionen:  %1.0f %%',t_behavior.hitrate*100)
    fprintf(1,'\nFehlerrate:  %1.0f %%',t_behavior.errorrate*100)
    fprintf(1,'\nRate Falscher Alarme:  %1.0f %%',t_behavior.FArate*100)
    fprintf(1,'\nReaktionszeit:  %1.0f ms\n###\n',t_behavior.meanRT*1000)
    Screen('Flip', ps.window, 0);
    if traincon == 'b'
       fprintf(1,'\nRichtige Buchstaben:  %1.0f %%\n###\n',t_behavior.richtige*100)
       fprintf(1,'\nRichtige Targets:  %1.0f %%\n###\n',t_behavior.targetsrichtig*100)
       fprintf(1,'\nRichtige Singletons:  %1.0f %%\n###\n',t_behavior.singletonsrichtig*100)
       fprintf(1,'\nRichtige Filler:  %1.0f %%\n###\n',t_behavior.nonsingrichtig*100)
       
    end
    
    %Parameter estimation (cumulative over runs)
    est = ERP_eval_train(t_response,all_levels, levels,p.thresh);
    
    KbWait;
    Screen('Flip', ps.window, 0);
    
    %Aks for repetition of Training
    key_check = 0;
    fprintf('Training wiederholen? j/n');
    while key_check == 0
        [keyIsDown, ~, keyCode] = KbCheck;
        if keyIsDown && keyCode(KbName('j'))
            key_check = 1;
            WaitSecs(0.3);
        end
        if keyIsDown && keyCode(KbName('n'))
            key_check = 1; do_train = 0;
            WaitSecs(0.3);
        end
    end   
end

end

