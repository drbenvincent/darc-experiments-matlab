function plot_delay_function(obj, thetaStruct, data_table)

%[thetaStruct] = obj.theta_to_struct(theta);

pointEstimateType = 'median';

if ~isempty(data_table)
    obj.plotDiscountFunction(thetaStruct,...
		'data', data_table,...
        'pointEstimateType', pointEstimateType,...
		'discounting_function_handle', obj.delayDiscountingFunction);
else
    obj.plotDiscountFunction(thetaStruct,...
		'pointEstimateType', pointEstimateType,...
		'discounting_function_handle', obj.delayDiscountingFunction);
end
drawnow
end