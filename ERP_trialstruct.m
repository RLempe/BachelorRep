function [ trialstruct ] = ERP_trialstruct(p)
%ERP_trialstruct generates condition, target position, distractor position,
% dot target position and jitter for each trial

trialstruct = [];
%vert_pos = repmat([1 3],1,p.trials_per_cond/2);    %define vector for even distribution of vertical position (1 or 3)
for c = 1:length(p.conditions)
    for t = 1:p.trials_per_cond
        idx = (c-1)*p.trials_per_cond+t;
        trialstruct(idx).condition=p.conditions{c}; %first write conditions
        switch trialstruct(idx).condition           %define target and distractor positions  
             case 'p2'
                trialstruct(idx).target_pos = randi(4);
                trialstruct(idx).distr_pos = 0;
             case 's2'
                trialstruct(idx).target_pos = randi(4);
                trialstruct(idx).distr_pos = 0;
             case 'p3'
                trialstruct(idx).target_pos = randi(4);
                trialstruct(idx).distr_pos = 0;
             case 's3'
                trialstruct(idx).target_pos = randi(4);
                trialstruct(idx).distr_pos = 0;
             case 'p1'
                trialstruct(idx).target_pos = randi(4);
                r = randperm(3)+1;
                numberToRemove = trialstruct(idx).target_pos;
                r(r==numberToRemove) = [];
                r=r(1);
                trialstruct(idx).distr_pos = r;
            case 's1'
                trialstruct(idx).target_pos = randi(4);
                r = randperm(3)+1;
                numberToRemove = trialstruct(idx).target_pos;
                r(r==numberToRemove) = [];
                r=r(1);
                trialstruct(idx).distr_pos = r;
            case 'p4'
                trialstruct(idx).target_pos = randi(4);
                r = randperm(3)+1;
                numberToRemove = trialstruct(idx).target_pos;
                r(r==numberToRemove) = [];
                r=r(1);
                trialstruct(idx).distr_pos = r;
            case 's4'
                trialstruct(idx).target_pos = randi(4);
                r = randperm(3)+1;
                numberToRemove = trialstruct(idx).target_pos;
                r(r==numberToRemove) = [];
                r=r(1);
                trialstruct(idx).distr_pos = r;
            case 'p5'
                trialstruct(idx).target_pos = randi(4);
                r = randperm(3)+1;
                numberToRemove = trialstruct(idx).target_pos;
                r(r==numberToRemove) = [];
                r=r(1);
                trialstruct(idx).distr_pos = r;
            case 's5'
                trialstruct(idx).target_pos = randi(4);
                r = randperm(3)+1;
                numberToRemove = trialstruct(idx).target_pos;
                r(r==numberToRemove) = [];
                r=r(1);
                trialstruct(idx).distr_pos = r;
            case 'p6'
                trialstruct(idx).target_pos = randi(4);
                r = randperm(3)+1;
                numberToRemove = trialstruct(idx).target_pos;
                r(r==numberToRemove) = [];
                r=r(1);
                trialstruct(idx).distr_pos = r;
            case 's6'
                trialstruct(idx).target_pos = randi(4);
                r = randperm(3)+1;
                numberToRemove = trialstruct(idx).target_pos;
                r(r==numberToRemove) = [];
                r=r(1);
                trialstruct(idx).distr_pos = r;
        end
        trialstruct(idx).dot_target_pos = randi(2);
        trialstruct(idx).dot_distr_pos = randi(2);
        trialstruct(idx).jitter = p.jitter(randi(length(p.jitter)));
    end
end

trialstruct=trialstruct(randperm(numel(trialstruct)));

end

