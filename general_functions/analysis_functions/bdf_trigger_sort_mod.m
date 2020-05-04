function [EEG] = bdf_trigger_sort_mod(allcodes,EEG)
% M. Dotzer 18-07-21
% function sorting triggers sent via parallel port and DataPixx
% called by pop_readbdf_mod.m

events = allcodes';
all_sp = length(events);
idx_ev = find(events(:,2)>0); % index all events
events_dp = zeros(all_sp,2); events_dp(:,1)=events(:,1);
events_ltp = zeros(all_sp,2); events_ltp(:,1)=events(:,1);
% loop across all events
for i_ev = 1:numel(idx_ev)
    %seperate trigger values for every sampling point
    [trigtype, outval] = trigger_sort_local(events(idx_ev(i_ev),2));
    %write seperate arrays for both trigger sources
    switch trigtype
        case 'dp'
            events_dp(idx_ev(i_ev),2) = outval;
        case 'ltp'
            events_ltp(idx_ev(i_ev),2) = outval;
        case 'summed'
            events_dp(idx_ev(i_ev),2) = outval(1);
            events_ltp(idx_ev(i_ev),2) = outval(2);
    end
end

% find same identical trigger values on successive sampling points
% zeros out events for EEG=pop_readbdf_mod('...\test08_prp4perframe_lpt500_srate512.bdf',[],48,[]);
%%%%%%%%% old_start
% z=1; zz=1;
% for ii = 2:length(events)
%     if events_dp((ii-1),2)==events_dp(ii,2)
%         z_dp(z)=ii; z=z+1;
%     end
%     if events_ltp((ii-1),2)==events_ltp(ii,2)
%         z_ltp(zz)=ii; zz=zz+1;
%     end
% end
% % only leave first trigger value and throw away zeros
% events_dp(z_dp,:)=[]; events_dp=events_dp(events_dp(:,2)>0,:);
% events_ltp(z_ltp,:)=[]; events_ltp=events_ltp(events_ltp(:,2)>0,:);
% events_all=sortrows([events_dp; events_ltp]);
%%%%%%%%% old_end
% check only for onset of trigger
idx_onset_dp = [true; diff(events_dp(:,2))>0];
idx_onset_ltp = [true; diff(events_ltp(:,2))>0];
events_dp(~idx_onset_dp,2) = 0;
events_ltp(~idx_onset_ltp,2) = 0;
% combine events
events_all=sortrows([events_dp; events_ltp]);
idx_ev_all = find(events_all(:,2)>0); % index all events


EEG.event = [];
EEG.urevent = [];

%write to EEG struct
for i_ev = 1:length(idx_ev_all)
    EEG.event(i_ev).latency = events_all(idx_ev_all(i_ev),1);
    EEG.event(i_ev).type = events_all(idx_ev_all(i_ev),2);
    EEG.event(i_ev).urevent = idx_ev_all(i_ev);
    EEG.urevent(i_ev).latency = events_all(idx_ev_all(i_ev),1);
    EEG.urevent(i_ev).type = events_all(idx_ev_all(i_ev),2);
end
end



function [trigtype, outval] = trigger_sort_local(val)
    max = 0:65535; % 16-bit range

    range_dp = 0:255;                                %Datapixx: Pins 1-8 (range 0-255)
    binary_range_dp = de2bi(range_dp);                
    binary_range_ltp = [zeros(256,8),binary_range_dp]; %PC LTP:   Pins 9-16 (range 256-65280, but only 256 values)
    range_ltp = bi2de(binary_range_ltp); 
    valbi = [de2bi(val),zeros(16-length(de2bi(val)),1)'];

    if ismember(val,range_dp)
       trigtype = 'dp';
       outval = val;

    elseif ismember(val,range_ltp)
       trigtype = 'ltp';
       outval = bi2de([zeros(1,8) valbi(9:16)]);

    elseif ismember(val,max) && ~ismember(val,range_dp) && ~ismember(val,range_ltp)
       trigtype = 'summed';
       outval = [bi2de(valbi(1:8)) bi2de([zeros(1,8) valbi(9:16)])];

     else
       outval='error';
    end
end


