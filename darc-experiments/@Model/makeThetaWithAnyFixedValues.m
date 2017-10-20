function thetaFull = makeThetaWithAnyFixedValues(obj, theta)

is_theta_fixed = obj.is_theta_fixed();

% Fill appropriate columns with theta values we are estimating
indexOfNotFixed = find(is_theta_fixed==0);
for n=1:numel(indexOfNotFixed)
	thetaFull(:,indexOfNotFixed(n)) = theta(:,n);
end

% Fill all fixed parameter values with their provided fixed values
for i = find(is_theta_fixed)
	thetaFull(:,i) = obj.(obj.params{i}) * ones(size(theta,1),1);
% 	fieldname = theta_labels{i};
% 	if ~isempty(obj.(fieldname))
% 		thetaFull(:,i) = obj.(fieldname) * ones(size(theta,1),1);
% 	end
end
return
