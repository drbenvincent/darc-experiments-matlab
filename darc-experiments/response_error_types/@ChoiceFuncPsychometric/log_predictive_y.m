function [log_p_choseLater,VA, VB] = log_predictive_y(obj,theta,designs)
% Calculate P(y==1|theta,D) = log(epsilon + (1-2.epsilon).Phi((VB-VA)/alpha))
%
% Inputs
%   theta:	See unpackTheta
%   D:      See unpackDesigns
%
% Outputs
%  log_p_choseLater: A vector of probabilities that the response equals 1.
%  VA:               Subjective value of prospect A
%  VB:               Subjective value of prospect B
%
% Ben Vincent, Tom Rainforth, www.inferenceLab.com, Jun 2017

[VA, VB] = obj.subjective_values(theta,designs);
% Adds the additional required variables to the workspace
alpha = []; % Not really sure why but this needs predeclaring as its a pre-existing function
obj.unpackTheta(theta);

[p_y_equal_1] = choiceFunction(obj, VA, VB, alpha, epsilon);

log_p_choseLater = log(p_y_equal_1);
log_p_choseLater(isnan(log_p_choseLater)) = -inf;
end
