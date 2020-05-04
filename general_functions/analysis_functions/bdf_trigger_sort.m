function [EEG, EEGbck] = bdf_trigger_sort(EEG)
% use after reading in a BDF file with bdfread.m to seperate overlapping
% triggers

EEGbck = EEG;
events(:,1) = [EEG.event.latency];
events(:,2) = [EEG.event.type];
n_triggers = length(events);
% add seperated trigger values to the end of array and overwrite summed ones
for i = 1:n_triggers
    outval = trigger_sort_local(events(i,2));
    if length(outval)==2
        events = [events; events(i,1) outval(1); events(i,1) outval(2)];
        events(i,2)=NaN;
    end
end
% clear and sort
events(isnan(events(:,2)),:) = [];
events = sortrows(events,1);
% find same triggers on successive sampling points and only leave the earliest
for ii = 1:length(events)
    if events(find(events==events(ii,1)-1),2)==events(ii,2)
        events(ii,2)=NaN;
    end
end
%clear
events(isnan(events(:,2)),:) = [];
EEG.event = [];
EEG.urevent = [];

%write to EEG struct
for iii = 1:length(events)
    EEG.event(iii).latency = events(iii,1);
    EEG.event(iii).type = events(iii,2);
    EEG.event(iii).urevent = iii;
    EEG.urevent(iii).latency = events(iii,1);
    EEG.urevent(iii).type = events(iii,2);
end

function [outval] = trigger_sort_local(val)
    max = 0:65535; % 16-bit range

    range_dp = 0:255;                                %Datapixx: Pins 1-8 (range 0-255)
    binary_range_dp = de2bi(range_dp);                
    binary_range_ltp = [zeros(256,8),binary_range_dp]; %PC LTP:   Pins 9-16 (range 256-65280, but only 256 values)
    range_ltp = bi2de(binary_range_ltp); 
    valbi = [de2bi(val),zeros(16-length(de2bi(val)),1)'];

    if ismember(val,range_dp)
       outval = val;

    elseif ismember(val,range_ltp)
       outval = bi2de([zeros(1,8) valbi(9:16)]);

    elseif ismember(val,max) && ~ismember(val,range_dp) && ~ismember(val,range_ltp)
       outval = [bi2de(valbi(1:8)) bi2de([zeros(1,8) valbi(9:16)])];

     else
       outval='error'
    end
end
end

