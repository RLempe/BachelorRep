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
    
    
    
    for i = trials(1):trials(length(trials))
        if response(i).condition(1) == 'p'
            aussortieren = false;
                if i > 2 
%                 aussortieren = false;
                    if response(i-1).condition(1) == 'p' && response(i-2).condition(1) == 'p'
                        aussortieren = true;
                    end    
                end
                if aussortieren == false
                    respbuchst = response(i).buchstaben;      
                    loesperm = response(i).perm;
                    loesbuchst = '';        
                    for j = 1:4
                        loesbuchst(j)=alphabet(loesperm(j));              
                    end
                    gesamt = gesamt + length(intersect(loesbuchst, respbuchst));
                end      
        end     
    end
  
    b.richtige = gesamt;  
    
end

