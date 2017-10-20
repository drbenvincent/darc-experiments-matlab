function b_fixed = is_design_variable_fixed(obj)
for n = 1:numel(obj.design_variables)
	b_fixed(n) = numel(obj.(obj.design_variables{n}))==1;
end
return