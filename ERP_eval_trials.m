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
    
end

