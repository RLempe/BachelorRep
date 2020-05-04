function [press,diff_times] = log_resp(i_frame,resp_keys,trial_time,trig)
%LOG_RESP is used to register button presses for every frame
%   Input Arguments
%   i_frame     :   frame index
%   resp_keys   :   key codes (as derived from KbName) of the response keys;
%                   if you enter one response key, an detection task will be assumed;
%                   if you enter an array of two response keys, a discrimination task will be assumed;
%   trial_time  :   start time of the trial; you can use GetSecs() or the FlipTimestamp of the first frame (from calling Screen('Flip'))
%   trig        :   response trigger value; allows you to check from outside whether 
%                   the subject is responding; if left empty, no trigger will be sent
%   Output Arguments
%   press       :   array with button presses; initialize before frame loop with nan("number_of_frames","number_of_response_keys");
%   diff_times  :   array with time difference between trial onset and keyboard-check; initialize before frame loop with nan("number_of_frames","number_of_response_keys");

% ISSUES TO SOLVE: one or two triggers?? now it just sends a trigger with
% any key press (only first frame)

[keyIsDown,secs, keyCode] = KbCheck;
kb(i_frame) = keyIsDown;
if kb(i_frame) && ~kb(i_frame-1)
    lptwrite(1,trig);
end
press(i_frame,:) = keyCode(resp_keys);
diff_times(i_frame) = secs - trial_time;

end

