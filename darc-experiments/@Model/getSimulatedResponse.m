function [response_data] = getSimulatedResponse(obj, chosen_design, true_theta)

log_p_choseB = obj.log_predictive_y(true_theta, chosen_design);

response_data.didChooseB = rand < exp(log_p_choseB);
response_data.reaction_time = 0;

end
