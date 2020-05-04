function [] = datapixx_trig(value)
%DATAPIXX_TRIG is a function to send a single trigger via Datapixx
%   - mainly useful for controling the EEG recording with ActiView:
%     'start saving' = 253; 'stop saving' = 254
%   - ! Datapixx should aready be set up (see e.g. exp_setup.m)
%   - ! cannot be used while a Datapixx trigger schedule is running

Datapixx('SetDoutValues', value);
Datapixx('RegWrRd');
WaitSecs(0.01);
Datapixx('SetDoutValues', 0);
Datapixx('RegWrRd');

end

