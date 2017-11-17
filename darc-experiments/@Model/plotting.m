function plotting(obj, thetaStruct, data_table)
%plotting
%
% Model-specific plotting is done in this function
%
% Inputs
%   theta:	   A matrix of particles in paramter space. Each column is one
%					     parameter dimension. Each row corresponds to a particle.
%  true_theta: Either empty, or row vector of true parameters.
%   data:      A matrix of data. Each row corresponds to a particular trial.
%						   The first R-1 rows correspond to the design, the final (Rth)
%						   row is the binary response (y)
%
% Ben Vincent, www.inferenceLab.com, May 2016


%% Plot utility function
f = figure(1);
f.Name = 'Model predictions and data';
clf

subplot(1,3,1)
obj.plot_utility_function(thetaStruct, data_table)
title('utility function')

subplot(1,3,2)
obj.plot_prob_weighting_function(thetaStruct, data_table)
title('probability weighting function')

subplot(1,3,3)
obj.plot_delay_function(thetaStruct, data_table)
title('delay discounting function')

%% Formatting

setAllSubplotOptions(gcf, {'FontSize', 20})

end
