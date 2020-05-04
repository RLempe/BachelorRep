function [block] = analyze_block(trials)
%ANALYZE_BLOCK is a function to analyze the subject's responses after a block
%   Input Arguments:
%   trials          :   structure array, with one structure for each trial to analyze
%                       (use analyze_trial() to write structure for one trial)
%   trials.nevents  :   number of events in one trial


block.allevents =  sum([trials(:).nevents]);
block.allhits = sum([trials(:).hits]);
block.allFA = sum([trials(:).FA]);

block.hitrate = block.allhits/block.allevents;
try 
    block.allerrors = sum([trials(:).error]); 
    block.errorrate = block.allerrors/block.allevents;
catch
    block.allerrors = NaN;
end
block.correct_responses = block.allhits/...
    (block.allFA+block.allhits+block.allerrors);
block.meanRT = nanmean([trials(:).RT_hits]);
block.FArate = block.allFA/...
    (block.allFA+block.allhits+block.allerrors);

end

