function [trial] = analyze_trial(press,diff_times,trial,resp_int_fr)
%ANALYZE_TRIAL Summary of this function goes here
%   Detailed explanation goes here

%   Input Arguments
%   press           :   button presses for every frame (output from log_resp())
%   diff_times      :   times of keyboard-check relative to trial onset (output from log_resp())
%   trial.ev_fr     :   frame number of event start; e.g. for two events: [132 281]
%   trial.ev_typ    :   event type; always =1 for detection task, =1 or =2 for discrimination tasks (assumes that key 1 is the correct answer for event type 1 and key 2 ist the correct answer for event type 2)
%   resp_int_fr     :   response intervall in frames; e.g. [0.2 0.9]*refreshrate

% ISSUES TO SOLVE:
% - how to deal with detection vs discrimination task? include a overall indicator variable?

% finding first frame of button press, for button 1 and button 2 (a button press usually takes several frames)
press_diff = [0 0; diff(press)];
press_onset = press_diff == -1;
press_FA = press_onset; % step by step exclude hits and errors from this matrix

% initialize variables
trial.hits = [];
trial.hits_time = [];
trial.RT_hits = [];
trial.error = [];
trial.error_time = [];
trial.RT_error = [];

if size(press,2)==2
    discriminationtask = 1;
    erroridx = [1 2 1];  %help variable to compute error responses (only for discrimination tasks)
elseif size(press,2)==1
    discriminationtask = 0;
else warning('array press has the wrong size; the function can only deal with 1 or 2 response buttons')
end

for i_ev = 1:numel(trial.ev_fr)
    
    hit_presses = find(press_onset(:,trial.ev_typ(i_ev)));                             %find presses where the button press matches the current event type
    hit_index = ismember(hit_presses,...                    
        [(trial.ev_fr(i_ev)+resp_int_fr(1)):(trial.ev_fr(i_ev)+resp_int_fr(2))]);      %within the valid response window
    
    if discriminationtask
    error_presses = find(press_onset(:,erroridx(trial.ev_typ(i_ev)+1)));               %find presses where the button press matches THE OTHER event type
    error_index = ismember(error_presses,...    
        [(trial.ev_fr(i_ev)+resp_int_fr(1)):(trial.ev_fr(i_ev)+resp_int_fr(2))]);      %within the response window
    end
    
    if any(hit_index)
        hit_index_first = find(hit_index,1,'first');                            % index first hit only (subsequent presses are treated as false alarms)
        press_FA(hit_presses(hit_index_first),trial.ev_typ(i_ev))= false;       % exclude hits from matrix with all presses
        % write to trial structure
        trial.hits(i_ev) = 1;                                                %hit count                                                
        trial.hits_time(i_ev) = diff_times(hit_presses(hit_index_first));    %time point of the hit within trial
        trial.RT_hits(i_ev) = diff_times(hit_presses(hit_index_first))...    %reaction time
            -diff_times(trial.ev_fr(i_ev)) ;
    else
        trial.hits(i_ev) = 0;
        trial.RT_hits(i_ev) = nan;
        trial.hits_time (i_ev) = nan;
    end
    
    if discriminationtask
    if any(error_index)
        error_index_first = find(error_index,1,'first');                        % index first hit only (subsequent presses are treated as false alarms)
        press_FA(error_presses(error_index_first),erroridx(trial.ev_typ(i_ev)+1))= false; % exclude errors from matrix with all presses
        % write to trial strucuture
        trial.error(i_ev) = 1;
        trial.error_time(i_ev) = diff_times(error_presses(error_index_first));
        trial.RT_error(i_ev) = diff_times(error_presses(error_index_first))-diff_times(trial.ev_fr(i_ev)) ;
    else
        trial.error(i_ev) = 0;
        trial.RT_error(i_ev) = nan;
        trial.error_time(i_ev) = nan;
    end
    end
    
end
% treat the rest of presses as false alarms
trial.FA = numel(find(press_FA));
trial.FA_time = sort([diff_times(press_FA(:,1))' diff_times(press_FA(:,2))']);
trial.event_times = trial.events;
end

