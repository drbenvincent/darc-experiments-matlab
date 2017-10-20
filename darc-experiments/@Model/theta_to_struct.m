function [thetaStruct] = theta_to_struct(obj,theta)
% Sets up structures for theta and data needed by the plotting functions

alpha = []; % Not really sure why but this needs predeclaring as its a pre-existing function
obj.unpackTheta(theta);
thetaStruct = struct;

for n=1:numel(obj.params)
    eval(['thetaStruct.(obj.params{n}) = ' obj.params{n} ';']);
end
