function [] = startup_romy(exp)
%STARTUP_DEMOS adds directory of designated experiment to current
%working directory

% if nargin < 1
%     exp = '';
% end

% switch exp
%     case ''
        %addpath(genpath('R:/MATLAB/BachelorRep/genal_functions'));
        addpath(genpath('R:/MATLAB/BachelorRep'));
        addpath(genpath('C:/Users/Romy/lab_library'));
        
% end

% Screen('Preference', 'SkipSyncTests', 1); % only for testing on notebook
% % alternatively, adjust the buffer swap thresholds
% %Screen('Preference','SyncTestSettings',0.001, 50, 0.1, 5);
% Screen('Preference','VisualDebugLevel', 0);


fprintf('Paths added. \n');

end