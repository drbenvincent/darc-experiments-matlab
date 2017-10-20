function [thetas, all_thetas] = packTheta(obj, theta_struct)
%packTheta
%
% Converts a structure with theta fields to an array with columns
% arranged in the correct order.  This ensures consistency with the unpack
% used elsewhere.  
%
% Inputs:
%   theta_struct = Structure with fields corresponding to the variables that
%                  are being inferred, giving ground truth values. Fields 
%                  that are in the model
%                  definition should not be included in the theta_struct.
% Outputs:
%   thetas = A matrix with correctly ordered columns, not containing fixed
%            values
%   all_thetas = As thetas but also with columns for the fixed variables
%
% Tom Rainforth, 01/08/16

theta_names = obj.params;
b_fixed = obj.is_theta_fixed();

should_be_set = theta_names(~b_fixed);
fields_to_set = fields(theta_struct);

%% Check everything that is set that should be and nothing extra has been provided
% This check could of course be written much faster, but is setup like this
% to provide informative error messages.

for n=1:numel(fields_to_set)
    if ~any(strcmp(should_be_set,fields_to_set{n}))
        error(['Field "' fields_to_set{n} '" in true_theta is not an unknown model parameter and should not be provided']);
    end
end

for n=1:numel(should_be_set)
    if ~any(strcmp(fields_to_set,should_be_set{n}))
        error(['Field "' should_be_set{n} '" is missing in true_theta specification']);
    end
end

%% Setup outputs

n_samples = size(theta_struct.(fields_to_set{1}),1);
n_total = numel(theta_names);
n_set = numel(fields_to_set);

thetas = NaN(n_samples,n_set);
all_thetas = NaN(n_samples,n_total);
theta_counter = 1;

for m=1:numel(theta_names)
    if any(strcmp(fields_to_set,theta_names{m}))
        theta_this = theta_struct.(theta_names{m});
        thetas(:,theta_counter) = theta_this;
        theta_counter = theta_counter+1;
    else
        theta_this = obj.(theta_names{m});
    end
    all_thetas(:,m) = theta_this;
end

end