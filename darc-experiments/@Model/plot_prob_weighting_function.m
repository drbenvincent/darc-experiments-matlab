function plot_prob_weighting_function(obj, thetaStruct, data_table)

%[thetaStruct] = obj.theta_to_struct(theta);

pointEstimateType = 'median';

if ~isempty(data_table)
    obj.plotProbFunction(thetaStruct,...
		'data', data_table,...
        'pointEstimateType', pointEstimateType,...
		'discounting_function_handle', obj.probWeightingFunction);
else
    obj.plotProbFunction(thetaStruct,...
		'pointEstimateType', pointEstimateType,...
		'discounting_function_handle', obj.probWeightingFunction);
end
drawnow
end