function [ trialstruct ] = ERP_trialstruct(p)
%ERP_trialstruct generates condition, target position, distractor position,
% dot target position and jitter for each trial

trialstruct = [];
vert_pos = repmat([1 3],1,p.trials_per_cond/2);    %define vector for even distribution of vertical position (1 or 3)
for c = 1:length(p.conditions)
    for t = 1:p.trials_per_cond
        idx = (c-1)*p.trials_per_cond+t;
        trialstruct(idx).condition=p.conditions{c}; %first write conditions
        switch trialstruct(idx).condition           %define target and distractor positions               
            case 'TLrDV'
                trialstruct(idx).target_pos = 2;
                trialstruct(idx).distr_pos = vert_pos(t);
            case 'TLlDV'
                trialstruct(idx).target_pos = 4;
                trialstruct(idx).distr_pos = vert_pos(t);
            case 'TVDLr'
                trialstruct(idx).target_pos = vert_pos(t);
                trialstruct(idx).distr_pos = 2;
            case 'TVDLl'
                trialstruct(idx).target_pos = vert_pos(t);
                trialstruct(idx).distr_pos = 4;
            case 'TLrDN'
                trialstruct(idx).target_pos = 2;
                trialstruct(idx).distr_pos = 0;
            case 'TLlDN'
                trialstruct(idx).target_pos = 4;
                trialstruct(idx).distr_pos = 0;
            case 'TNDLr'
                trialstruct(idx).target_pos = 0;
                trialstruct(idx).distr_pos = 2;
            case 'TNDLl'
                trialstruct(idx).target_pos = 0;
                trialstruct(idx).distr_pos = 4;
            case 'BL'
                trialstruct(idx).target_pos = 0;
                trialstruct(idx).distr_pos = 0;
        end
        trialstruct(idx).dot_target_pos = randi(2);
        trialstruct(idx).dot_distr_pos = randi(2);
        trialstruct(idx).jitter = p.jitter(randi(length(p.jitter)));
    end
end

trialstruct=trialstruct(randperm(numel(trialstruct)));

end

