function [ trialstruct ] = ERP_trialstruct(p)
%ERP_trialstruct generates condition, target position, distractor position,
% dot target position and jitter for each trial

% trialstruct = [];
halfcond = (length(p.conditions)/2);

trialstruct(1:p.trials_total) = struct('condition',nan,'target_pos',nan,'distr_pos',nan,'dot_target_pos',nan,'dot_distr_pos',nan,'jitter',nan,'perm',nan);
for c = 1:halfcond
    for t = 1:p.trials_per_probe
        idx = (c-1)*p.trials_per_probe+t;
        trialstruct(idx).condition=p.conditions{c}; %first write conditions
        trialstruct(idx).target_pos = randi(4);
        r = randperm(4);
        numberToRemove = trialstruct(idx).target_pos;
        r(r==numberToRemove) = [];
        r=r(1);
        trialstruct(idx).distr_pos = r;
        trialstruct(idx).dot_target_pos = randi(2);
        trialstruct(idx).dot_distr_pos = randi(2);
        trialstruct(idx).jitter = p.jitter(randi(length(p.jitter)));
        perm=randperm(26);
        perm2=perm(1:4);
        trialstruct(idx).perm=perm2;
    end
end

for c = 1:halfcond
    for t = 1:p.trials_per_search
        idx = (4*p.trials_per_probe)+(c-1)*p.trials_per_search+t;
        trialstruct(idx).condition=p.conditions{c+4}; %first write conditions
        trialstruct(idx).target_pos = randi(4);
        r = randperm(4);
        numberToRemove = trialstruct(idx).target_pos;
        r(r==numberToRemove) = [];
        r=r(1);
        trialstruct(idx).distr_pos = r;
        trialstruct(idx).dot_target_pos = randi(2);
        trialstruct(idx).dot_distr_pos = randi(2);
        trialstruct(idx).jitter = p.jitter(randi(length(p.jitter)));
        trialstruct(idx).perm = [];
    end
end

%trialstruct=trialstruct(randperm(numel(trialstruct)));

probematrix = trialstruct(1:(halfcond*p.trials_per_probe));
proberand = probematrix(randperm(numel(probematrix)));
searchmatrix = trialstruct((halfcond*p.trials_per_probe)+1:p.trials_total);
searchrand = searchmatrix(randperm(numel(searchmatrix)));
nprobe= 1;
maxprobe = halfcond*p.trials_per_probe;
maxsearch = halfcond*p.trials_per_search;
nsearch = 1; 
%trialstruct_neu = trialstruct;
trialstruct_neu(1:p.trials_total)=struct('condition',nan,'target_pos',0,'distr_pos',0,'dot_target_pos',0,'dot_distr_pos',0,'jitter',0,'perm',[]);

for i = 1:p.trials_total
    dieseauswahl = struct('condition',nan,'target_pos',nan,'distr_pos',nan,'dot_target_pos',nan,'dot_distr_pos',nan,'jitter',nan,'perm',nan);
%     dieseauswahl=[];
%     dieseauswahl(1).condition='';
%     dieseauswahl(1).target_pos=0;
%     dieseauswahl(1).distr_pos=0;
%     dieseauswahl(1).dot_target_pos=0;
%     dieseauswahl(1).dot_distr_pos=0;
%     dieseauswahl(1).jitter=0; 
%     dieseauswahl(1).perm = randperm(4);
    m = 1;
    if nprobe <= maxprobe
        dieseauswahl(m) = proberand(nprobe);
        m = m+1;
    end
    if nsearch <= maxsearch
        dieseauswahl(m) = searchrand(nsearch);
    end
    zf=rand;
    if length(dieseauswahl)>1
        if i > 2
            if (maxsearch-nsearch+1) >= int8((p.trials_total-i+1)*(1/3)) %wenn genug search trials �brig sind, checke die probe bedingung
                if trialstruct_neu(i-2).condition(1) == 'p' && trialstruct_neu(i-1).condition(1) == 'p' && nsearch <= maxsearch %schon zwei probe trials hintereinander?
                    %dann nimm einen search trial 
                    trialstruct_neu(i)=dieseauswahl(2);
                    nsearch = nsearch +1;
                else %dann nimm egal was
                    if nsearch <= maxsearch && nprobe <= maxprobe
%                         trialstruct_neu(i)=dieseauswahl(1);
                        if zf <= (maxprobe/(maxprobe+maxsearch)) ||  (i>4 && trialstruct_neu(i-4).condition(1) == 's' && trialstruct_neu(i-3).condition(1) == 's' && trialstruct_neu(i-2).condition(1) == 's' && trialstruct_neu(i-1).condition(1) == 's')
                            trialstruct_neu(i)=dieseauswahl(1);
                            nprobe = nprobe + 1;
                        else
                            trialstruct_neu(i)=dieseauswahl(2);
                            nsearch = nsearch + 1;
                        end
                    end
                end 
            else %dann nimm einen probe trial
                trialstruct_neu(i)=dieseauswahl(1);
                nprobe = nprobe + 1;
            end
        else % f�r i = 1 oder 2 nimm einen trial
%             trialstruct_neu(i)=dieseauswahl(zf);
            if zf <= (maxprobe/(maxprobe+maxsearch))
                trialstruct_neu(i)=dieseauswahl(1);
                nprobe = nprobe + 1;
            else
                trialstruct_neu(i)=dieseauswahl(2);
                nsearch = nsearch + 1;
            end
        end
    else %wird der erreicht?? spricht f�r ja
        if nprobe <= maxprobe
            trialstruct_neu(i) = dieseauswahl(1);
            nprobe = nprobe + 1;
        end
        if nsearch <= maxsearch
            trialstruct_neu(i) = dieseauswahl(1);
            nsearch = nsearch + 1;
        end
    end    
end

counti = 0;

for i = 1:12

    if trialstruct_neu(p.trials_total-i+1).condition(1) == 's'

        counti = counti + 1;

    end

end

 

if counti <= 4 || counti > 8

    p.randcount = p.randcount + 1;

    rand('state',p.sub+100*p.randcount);

    trialstruct = ERP_trialstruct(p);

else

    trialstruct = trialstruct_neu;

end

end

