function [VA, VB] = subjective_values(obj,theta,designs)
% Returns subjective values of given theta design combinations
%
% Inputs
%   theta:	See unpackTheta
%   D:      See unpackDesigns
%
% Outputs
%  VA:               Subjective value of prospect A
%  VB:               Subjective value of prospect B
%
% Ben Vincent, Tom Rainforth, www.inferenceLab.com, May 2016

params = obj.theta_to_struct(theta);

[prospectA, prospectB] = obj.design2prospects(designs);

VA = obj.calcPresentSubjectiveValue(prospectA, params);
VB = obj.calcPresentSubjectiveValue(prospectB, params);

end
