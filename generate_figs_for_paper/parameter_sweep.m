function output_array = parameter_sweep(parameter_list, function_to_run, trials)
display('Parameter sweep')
output_array = [];
parfor n = 1:numel(parameter_list)
	fprintf('.')
	true_parameter_value = parameter_list(n);
	output = function_to_run(true_parameter_value, trials);
	output_array = [output_array output];
end
fprintf('\n')
end
