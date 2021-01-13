function [b] = ERP_eval_trials( trials, response )
%ERP_eval_trial nansummarizes the behavior for the indicated trials
    %"trials" is an array with trials to be analyzed
    
    allhits = nansum([response(trials).hit]);
    allmisses = nansum([response(trials).miss]);
    allerrors = nansum([response(trials).error]);
    allFAs = nansum([response(trials).FA])+nansum([response(trials).dFA]);
    b.hitrate = allhits/ (allhits+allerrors+allmisses);
    b.errorrate = allerrors/ (allhits+allerrors+allmisses);
    b.FArate = allFAs/ (length(trials) - allhits - allmisses - allerrors);
    b.meanRT = nanmean([response(trials).RT]);
    
    %Buchstaben kalkulieren
    alphabet = 'A' : 'Z';
    gesamt = 0;
    targets = 0;
    targetsrichtig = 0;
    singletons = 0;
    singletonsrichtig = 0;
    nonsing = 0;
    nonsingrichtig = 0;
    
    
    
    for i = 1:length(trials)
        if response(i).condition(1) == 'p'
            aussortieren = false;
                if i > 2 
                aussortieren = false;
                    if response(i).condition(1) == 'p' && response(i-1).condition(1) == 'p' && response(i-2).condition(1) == 'p'
                        aussortieren = true;
                    end    
                end
                if aussortieren == false
                    respbuchst = response(i).buchstaben;      
                    loesperm = response(i).perm;
                    loesbuchst = '';        
                    for j = 1:4
                        loesbuchst(j)=alphabet(loesperm(j));
                        if j == response(i).target_pos 
                            antwort = length(intersect(loesbuchst(j), respbuchst));
                            targets = targets + 1;
                            targetsrichtig = targetsrichtig + antwort;
                        else
                            if j == response(i).distr_pos
                                antwort = length(intersect(loesbuchst(j), respbuchst));
                                singletons = singletons + 1;
                                singletonsrichtig = singletonsrichtig + antwort;
                            else % dann Non-Singleton
                                antwort = length(intersect(loesbuchst(j), respbuchst));
                                nonsing = nonsing + 1;
                                nonsingrichtig = nonsingrichtig + antwort;
                            end    
                        end 
%                     richtige_overall = length(intersect(loesbuchst, respbuchst));
%                     gesamt = gesamt + richtige_overall;                
                    end
                    richtige_overall = length(intersect(loesbuchst, respbuchst));
                    gesamt = gesamt + richtige_overall;
                end
            
        
        end
        
    end
    
    
    
    b.richtige = gesamt/(length(trials)*4);
    
    b.targetsrichtig = targetsrichtig/targets;
    b.singletonsrichtig = singletonsrichtig/singletons;
    b.nonsingrichtig = nonsingrichtig/nonsing;  
    
end

