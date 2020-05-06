function [est] = ERP_eval_train(response,all_levels, levels, thresh)
%ERP_EVAL_TRAIN estimation of luminance value for threshold performance

% Parameters
fit_func = @PAL_Weibull;   %define the function to use
free_params = [1 1 0 0];   %estimate alpha and beta, fix guess and lapse rate

%Sum hits for every stimulus level
for l = 1:length(levels)
    level_hits(l) = nansum([response(all_levels == levels(l)).hit]);
    all_targets(l) = level_hits(l) + nansum([response(all_levels == levels(l)).miss]) + nansum([response(all_levels == levels(l)).error]);
end

% FIX !! try out different minimum alpha value
searchGrid.alpha = 0:.001:max(levels);      % initial guess for threshold value, only use non-symetric function fits here
searchGrid.beta = logspace(0,5,100);        % initial guess for slope value
%searchGrid.gamma = max([FAcatch 1])/(AllPos-NumEvType);  %guess rate, scalar here (since fixed), calculated out of fA to null trials, ~7200 is a dirty estimation of possible catch positions
searchGrid.gamma = 0.001; %FIX how to calculate guess rate!!?
searchGrid.lambda = searchGrid.gamma;

fprintf(['\nNumber of targets per level: ', num2str(all_targets)]);

% Function fitting
fprintf('\n...Fitting function...');
[params, ~, ~, ~] = PAL_PFML_Fit(levels,level_hits,all_targets,searchGrid,free_params,fit_func);

% Calculations for figure
hitrate = level_hits./all_targets;                      %hitrate per stimlevel
levels_fine=min(levels):max(levels)/1000:max(levels);   %create a fine-grained search space for the stimulus levels
hit_model = fit_func(params,levels_fine);               %use previously estimated parameters to calculate a model for hitrateXstimlevels
est_idx = dsearchn(hit_model',thresh);                %look at which point the model reaches the threshold
est = levels_fine(est_idx);                             %look where this is in stimulus level space

% Figure
figure('name',['Maximum Likelihood Psychometric Function Fitting (' func2str(fit_func) ')']);
axes
hold on
plot(levels_fine,hit_model,'-','color',[0 .7 0],'linewidth',4); drawnow
plot(levels,hitrate,'k.','markersize',40); drawnow
set(gca, 'fontsize',16);
set(gca, 'Xtick',levels);
axis([min(levels) max(levels) 0 1]);
xlabel('Stimulus Intensity');
ylabel('proportion correct');
line([est; est], [0 1],'color','r','linestyle',':');
line([min(levels); max(levels)],[hit_model(est_idx); hit_model(est_idx)], 'color','r','linestyle',':'); drawnow
fprintf('...ESTIMATION:...\nclosest matching threshold intensity of %g%% correct at stimulus level %.4f (%g%% correct)\n',...
    100*thresh,est,100*hit_model(est_idx));
hold off

end

