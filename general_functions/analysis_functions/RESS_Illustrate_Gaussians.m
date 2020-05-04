function [] = RESS_Illustrate_Gaussians(s_f,s_width,n_dist,n_width,srate,signallength)
%RESS_ILLUSTRATE_GAUSSIANS plots gaussians for designed filters
%   Detailed explanation goes here
%   example:
%   RESS_Illustrate_Gaussians(14.167,0.5,[-1 1],[1 1],256,256*10)

%% actual data creation
% frequencies
hz = linspace(0,srate,signallength);

% create Gaussian of signal
s  = s_width*(2*pi-1)/(4*pi);           % normalized width
x  = hz-s_f;                            % shifted frequencies
s_fx = exp(-.5*(x/s).^2);               % gaussian
s_fx = s_fx./max(s_fx);                 % gain-normalized

% create Gaussian of low noise
s  = n_width(1)*(2*pi-1)/(4*pi);        % normalized width
x  = hz-(s_f+n_dist(1));                % shifted frequencies
l_fx = exp(-.5*(x/s).^2);               % gaussian
l_fx = l_fx./max(l_fx);                 % gain-normalized

% create Gaussian of high noise
s  = n_width(2)*(2*pi-1)/(4*pi);        % normalized width
x  = hz-(s_f+n_dist(2));                % shifted frequencies
h_fx = exp(-.5*(x/s).^2);               % gaussian
h_fx = h_fx./max(h_fx);                 % gain-normalized

%% compute empirical frequency and standard deviation

idx = dsearchn(hz',s_f);
empVals(1,1) = hz(idx);
% find values closest to .5 after MINUS before the peak
empVals(1,2) = hz(idx-1+dsearchn(s_fx(idx:end)',.5)) - hz(dsearchn(s_fx(1:idx)',.5));

idx = dsearchn(hz',s_f+n_dist(1));
empVals(2,1) = hz(idx);
% find values closest to .5 after MINUS before the peak
empVals(2,2) = hz(idx-1+dsearchn(l_fx(idx:end)',.5)) - hz(dsearchn(l_fx(1:idx)',.5));

idx = dsearchn(hz',s_f+n_dist(2));
empVals(3,1) = hz(idx);
% find values closest to .5 after MINUS before the peak
empVals(3,2) = hz(idx-1+dsearchn(h_fx(idx:end)',.5)) - hz(dsearchn(h_fx(1:idx)',.5));

%% plotting
figure,clf
plot(hz,s_fx,'o-')
hold on
plot(hz,l_fx,'o-')
plot(hz,h_fx,'o-')
set(gca,'xlim',[max(s_f+min(n_dist)-10,0) s_f+max(n_dist)+10]);

title({...
    ['Requested: ' num2str(s_f) ', ' num2str(s_width) ' Hz; Empirical: ' num2str(empVals(1,1)) ', ' num2str(empVals(1,2)) ' Hz'] ...
    ['Requested: ' num2str(s_f+n_dist(1)) ', ' num2str(n_width(1)) ' Hz; Empirical: ' num2str(empVals(2,1)) ', ' num2str(empVals(2,2)) ' Hz'] ...
    ['Requested: ' num2str(s_f+n_dist(2)) ', ' num2str(n_width(2)) ' Hz; Empirical: ' num2str(empVals(3,1)) ', ' num2str(empVals(3,2)) ' Hz']})
xlabel('Frequency (Hz)'), ylabel('Amplitude gain')
end

