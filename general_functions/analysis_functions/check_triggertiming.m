function [] = check_triggertiming( File2Load, Trigger, varargin )
%CHECK_TRIGGERITMING Extracts Timing between trigger and Stimulus Onset
%   Checks, Anlyses Timing between Trigger and onset of light as measured
%   with BioSemi Diode
%   requires:
%       - File2Load; bdf format
%       - expected trigger [3; 512] % works for 1 or two trigger so far
%       - config: cfg
%           + cfg.diodechan; channel number of diode data
%           + cfg.eventchan; channel number of event channel
%           + cfg.eventduration; maximum duration of event in ms
%
% example:
%           check_triggertiming('F:\work\data\diode_test\DD_20HzRect_480_fliptestBW.bdf', [3; 512], struct('diodechan',48,'eventchan',56,'eventduration',20))

%% standard parameters
if nargin <3
    cfg = struct;
end
cfg = varargin{1};
% check input and fill missing witht default values

if isempty(strcmp(fieldnames(cfg), 'diodechan'))|~strcmp(fieldnames(cfg), 'diodechan')
    cfg.diodechan = 48;
    fprintf('!!! using default: no diode channel specified; set to 48\n')
end
if isempty(strcmp(fieldnames(cfg), 'eventchan'))|~strcmp(fieldnames(cfg), 'eventchan')
    cfg.eventchan = 56;
    fprintf('!!! using default: no event channel specified; set to 56\n')
end
if isempty(strcmp(fieldnames(cfg), 'eventduration'))|~strcmp(fieldnames(cfg), 'eventduration')
    cfg.eventduration = 10;
    fprintf('!!! using default: no maximum duration of event in ms specified; set to 20 ms\n')
end


%% import data
try EEG = pop_readbdf(File2Load, [] ,cfg.eventchan,[]);
catch
    fprintf('!!! file not found!!!\n')
end
% pop_eegplot(EEG,1,1,1)

%% sort trigger
% any summation of trigger? [Datapixx, lptwrite issue]
if numel(Trigger)>1
    idx_trig_sum = find([EEG.event.type]== sum(Trigger));
    eventnum = numel(EEG.event);
    for i_trig = 1:numel(idx_trig_sum)
        % change trigger
        % EEG = pop_editeventvals(EEG,'changefield',{idx_trig_sum(i_trig) 'type' Trigger(2)});
        EEG.urevent(EEG.event(idx_trig_sum(i_trig)).urevent).type = Trigger(2);
        EEG.event(idx_trig_sum(i_trig)).type = Trigger(2);
        % add new trigger
        EEG.event(eventnum+i_trig).type = Trigger(1);
        EEG.event(eventnum+i_trig).latency = EEG.event(idx_trig_sum(i_trig)).latency;
        
        %         EEG = pop_editeventvals(EEG,'insert',{numel(EEG.event) [] [] []},...
        %             'changefield',{numel(EEG.event) 'type' 333},...
        %             'changefield',{numel(EEG.event) 'latency' EEG.event(idx_trig_sum(i_trig)).latency/EEG.srate});
    end
    EEG = eeg_checkset(EEG,'eventconsistency');
    
    % check for same events within event range
    idx_trig1 = find([EEG.event.type]== Trigger(1));
    idx_trig2 = find([EEG.event.type]== Trigger(2));
    
    idx_trig1_del = [nan diff([EEG.event(idx_trig1).latency])/EEG.srate*1000] <= cfg.eventduration;
    idx_trig2_del = [nan diff([EEG.event(idx_trig2).latency])/EEG.srate*1000] <= cfg.eventduration;
    
    % delete double events within event range
    EEG.event(idx_trig1(idx_trig1_del))=[];
    EEG.event(idx_trig2(idx_trig2_del))=[];
    
    EEG = eeg_checkset(EEG,'eventconsistency');
    %pop_eegplot(EEG,1,1,1)
end

%% calculate latency onsets for each trigger
%figure; plot(EEG.times, EEG.data(cfg.diodechan,:))

idx_trig = find(ismember([EEG.event.type],Trigger));
% loop across events

results = [];

for i_trig = 1:numel(idx_trig)
    % trigger  type
    results.trigger_type(i_trig) = EEG.event(idx_trig(i_trig)).type;
    % event latency
    results.trigger_lat(i_trig) = EEG.event(idx_trig(i_trig)).latency;
    
    %% calculate onset of diode signal
    t.data = EEG.data(cfg.diodechan,(0:EEG.srate-1)+results.trigger_lat(i_trig));
    %figure; plot(t.data)
    t.data_range = [min(t.data) max(t.data)];
    % first value larger than min + 0.5*(range) is defined as onset
    results.diode_onset(i_trig) = results.trigger_lat(i_trig) + ...
        find(t.data > (t.data_range(1)+0.5*diff(t.data_range)),1,'first');
    results.trigger2diode_diff(i_trig) = find(t.data > (t.data_range(1)+0.5*diff(t.data_range)),1,'first');    
    
end

%% output of results
figure;
for i_trig = 1:numel(Trigger)
    subplot(3,numel(Trigger),i_trig)
    t.idx = find(results.trigger_type == Trigger(i_trig));
    for i_ev = 1:numel(t.idx)
        plot(EEG.data(cfg.diodechan,(0:EEG.srate-1)+results.trigger_lat(t.idx(i_ev))));
        hold on;
    end
    xlim([0 mean(results.trigger2diode_diff(t.idx))*2])
    title(sprintf('results for trigger ''%1.0f'' | single trial diode onsets',Trigger(i_trig)))
    xlabel('time in samples')
end

for i_trig = 1:numel(Trigger)
    subplot(3,numel(Trigger),i_trig+numel(Trigger)*2)
    t.idx = results.trigger_type == Trigger(i_trig);
    pl.data = results.trigger2diode_diff(t.idx);
    histogram(pl.data,20);
    title(sprintf('results for trigger ''%1.0f'' | trigger to diode jitter in sampling points',Trigger(i_trig)))
    set(gca,'ylim',get(gca,'ylim')*1.3);
    pl.xlim = get(gca,'xlim'); pl.ylim = get(gca,'ylim');
    text(max(pl.xlim)-(0.7)*diff(pl.xlim), 0.85*max(pl.ylim),...
        sprintf('N_t_o_t_a_l = %1.0f\nM+-SD = %1.4f +- %1.3f samples\nMedian = %1.4f samples',...
        numel(pl.data),mean(pl.data), std(pl.data),median(pl.data)),...
        'HorizontalAlignment','left')
    xlabel('jitter in samples')
end    

for i_trig = 1:numel(Trigger)
    subplot(3,numel(Trigger),i_trig+numel(Trigger))
    t.idx = results.trigger_type == Trigger(i_trig);
    pl.data = results.trigger2diode_diff(t.idx)/EEG.srate*1000;
    histogram(pl.data,20);
    title(sprintf('results for trigger ''%1.0f'' | trigger to diode jitter in ms',Trigger(i_trig)))
    set(gca,'ylim',get(gca,'ylim')*1.3);
    pl.xlim = get(gca,'xlim'); pl.ylim = get(gca,'ylim');
    text(max(pl.xlim)-(0.7)*diff(pl.xlim), 0.85*max(pl.ylim),...
        sprintf('N_t_o_t_a_l = %1.0f\nM+-SD = %1.4f +- %1.3f ms\nMedian = %1.4f ms',...
        numel(pl.data),mean(pl.data), std(pl.data),median(pl.data)),...
        'HorizontalAlignment','left')
    xlabel('jitter in ms')
    
end



end

