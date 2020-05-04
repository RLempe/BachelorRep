% function [outval] = trigger_sort( val, verbose )
% Insert trigger value; if its a summed trigger, function will divide it to
% Datapixx & LTP triggers
% returns corresponding values for datapixx and ltp trigger channel, if
% prompted
%
% revision history:
% nf adds function output and class conversion if input is string
% md writes smart function to disentangle triggers specific to Mueller
% Lab's PROPixx setup
function [outval] = trigger_sort( val, verbose )
if nargin < 1, help(mfilename), return, end
if nargin < 2, verbose = 0; end
if ischar(val)
    oldval = val;
    val = str2double(val);
end
max = 0:65535; % 16-bit range

range_dp = 0:255;                                %Datapixx: Pins 1-8 (range 0-255)
binary_range_dp = de2bi(range_dp);                
binary_range_ltp = [zeros(256,8),binary_range_dp]; %PC LTP:   Pins 9-16 (range 256-65280, but only 256 values)
range_ltp = bi2de(binary_range_ltp);
try 
    valbi = [de2bi(val),zeros(1,16-length(de2bi(val)))];
catch me
    disp(me)
    valbi = nan;
end

if ismember(val,range_dp)
    outval = val;
    if verbose
        fprintf([num2str(val), ' is a Datapixx trigger. \n']);
    end
    
elseif ismember(val,range_ltp)
    outval = bi2de(valbi(9:16));
    if verbose
        fprintf([num2str(val), ' is the LTP trigger ', num2str(outval), '. \n']);
    end
    
elseif ismember(val,max) && ~ismember(val,range_dp) && ~ismember(val,range_ltp)
    outval = [bi2de(valbi(1:8)) bi2de([zeros(1,8) valbi(9:16)])];
    if verbose
        fprintf([num2str(val), ' is a summed trigger. Datapix value is ',num2str(outval(1)),' and LTP value is ',num2str(outval(2)),'. \n']);
    end
    
else
    outval = oldval;
    fprintf([num2str(val),' is not a valid trigger value. \n']);
    
end

end

