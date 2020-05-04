function [] = exp_close()
%EXP_CLOSE is a function to close your experiment properly
%
%   ISSUES TO SOLVE:
%   - is this helpful?

ListenChar(0) % reset to allow input in matlab

% close Propixx
Datapixx('SetPropixxDlpSequenceProgram', 0);
Datapixx('RegWrRd');
Datapixx('close');
% close triggerport
ppdev_mex('Close', 1);

sca %close psychtoolbox
end

