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
    
    
    %checken, ob es überhaupt probe ist //
    %dritte probe trials, falls vorhanden, rausschmeißen
    
    
    for i = 1:length(trials)
        
        if trials(i).condition(1) == 'p'
            aussortieren = false;
                if i >2 
                aussortieren = false;
                    if trials(i).condition(1) == 'p' && trials(i-1).condition(1) == 'p' && trials(i-2).condition(1) == 'p'
                        aussortieren = true;
                    end    
                end
                if aussortieren == false
                    respbuchst = response(trials(i)).buchstaben;      
                    loesperm = trials(i).perm;
                    loesbuchst = '';        
                    for j = 1:4
                        loesbuchst(j)=alphabet(loesperm(j));
                        if j == trials(i).target_pos
                            antwort = length(intersect(loesperm(j), respbuchst));
                            targets = targets + 1;
                            targetsrichtig = targetsrichtig + antwort;
                        else
                            if j == trials(i).distr_pos
                                antwort = length(intersect(loesperm(j), respbuchst));
                                singletons = singletons + 1;
                                singletonsrichtig = singletonsrichtig + antwort;
                            else % dann Non-Singleton
                                antwort = length(intersect(loesperm(j), respbuchst));
                                nonsing = nonsing + 1;
                                nonsingrichtig = nonsingrichtig + antwort;
                            end    
                        end 
                    richtige_overall = intersect(loesbuchst, respbuchst);
                    gesamt = gesamt + richtige_overall;                
                    end 
                end
            
        
        end
        
    end
    
    
    
    b.richtige = gesamt/(length(trials)*4);
    
    b.targetsrichtig = targetsrichtig/targets;
    b.singletonsrichtig = singletonsrichtig/singletons;
    b.nonsingrichtig = nonsingrichtig/nonsing;  
    
end

