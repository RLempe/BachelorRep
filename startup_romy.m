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

fprintf('Paths added. \n');

end