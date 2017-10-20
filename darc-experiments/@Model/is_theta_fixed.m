function is_theta_fixed = is_theta_fixed(obj)
for n = 1:numel(obj.params)
	is_theta_fixed(n) = ~isempty(obj.(obj.params{n}));
end
return