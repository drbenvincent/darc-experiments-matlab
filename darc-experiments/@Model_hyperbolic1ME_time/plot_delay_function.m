function plot_delay_function(obj, thetaStruct, data_table)

%[thetaStruct] = obj.theta_to_struct(theta);

pointEstimateType = 'median';

rows=1; cols=2;

%% Plot magnitude effect: log(k) = f(reward magnitude, m, c)
subplot(rows, cols, 1)
plotMagnitudeEffect(thetaStruct, pointEstimateType); % <------ TODO

%% Visualization of discount surface and response data (if available)
subplot(rows, cols, 2)
if ~isempty(data_table)
	obj.plotDiscountSurface(thetaStruct, ...
		'data', data_table, ...
		'pointEstimateType', pointEstimateType);
else
	obj.plotDiscountSurface(thetaStruct, ...
		'pointEstimateType', pointEstimateType);
end

drawnow
end