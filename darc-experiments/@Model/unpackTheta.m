function unpackTheta(obj, theta, exten)
%unpackTheta
%
% obj.unpackTheta(theta);
%
% Takes a row vector or matrix of theta and returns as seperate outputs for
% each variable, whether fixed or provided in theta, in the appropriate
% order. These returns are assigned
% directly to the namespace of the caller rather than being returned as an
% output using the names in obj.design_variables.  These are created as new
% variables if they do not already exist
%
% Number of columns of theta must correspond to the number of
% non-fixed variables.
%  
% Inputs:
%   theta =   A matrix of particles in paramter space. Each column is one
%			parameter dimension. Each row corresponds to a particle. Order
%			of columns correponds to order of params property, with all
%			non-fixed variables provided.
%   exten = An extension applied to the names of variables for if the
%           default names are already taken (e.g. we are considering both
%           truth and inferred thetas).  Empty by default
%
% Outputs:
%       direct variable assignment in the calling function. 
%
% Tom Rainforth, 21/07/17

if ~exist('exten','var')
    exten = '';
end

param_names = obj.params;
b_fixed = obj.is_theta_fixed();
count=1;

for i=1:numel(param_names)
    if b_fixed(i)
        assignin('caller',[param_names{i}, exten],obj.(param_names{i})*ones(size(theta,1),1));
    else
        assignin('caller',[param_names{i}, exten],theta(:,count));
        count = count + 1;
    end
end

%% Checks
% A common reason this might be invoked is if true_theta is the wrong size.
% It must be the same dimensionality as theta - if variables are fixed they need
% setting in the model definition and the relevant true_theta are no longer
% needed.  Its an important assert as without it things can be incorrectly
% matched up such as was the previously the case in demo script
assert(count>size(theta,2),'Too many thetas have been provided given the fixed parameters.  Usual cause is incorrect size of provided true_theta');

end