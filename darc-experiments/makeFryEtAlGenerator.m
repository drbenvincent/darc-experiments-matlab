function f = makeFryEtAlGenerator(D_B, R_B, trials_per_delay)
%makeFryEtAlGenerator Returns a design generator function.
% This function returns a function which returns designs according to the
% method described by:
% Frye, C. C. J., Galizio, A., Friedel, J. E., DeHart, W. B., & Odum, A. L.
% (2016). Measuring Delay Discounting in Humans Using an Adjusting Amount 
% Task. Journal of Visualized Experiments, (107), 1?8. 
% http://doi.org/10.3791/53584
%
% Once the number of trials are up, it will return an empty value, []
%
% Example usage:
%  D_B = [7 30 365];
%  R_B = 100;
%  trials_per_delay = 5;
%  DesignGenerator = makeFryEtAlGenerator(D_B, R_B, trials_per_delay);
%  design = DesignGenerator()
%  design = DesignGenerator()
%  ...

% Variables defined here are remembered across multiple calls to
% designGetter because they are outside it's local scope.
D_A = 0;
R_A = R_B / 2;
P_A = 1;
P_B = 1;
delay_counter = 1;
post_choice_adjustment = 0.25;
trial_counter = 1;

f = @designGetter;


	function design = designGetter(~, all_responses)
		%designGetter
		% arguments are: previous_designs, all_responses
		% but this is independent of previous designs run
		
		% all trials done?
		if delay_counter > numel(D_B)
			design = [];
			return
		end
		
		if trial_counter == 1
			% first trial of this delay
			R_A_over_R_B = 0.5;
			R_A = R_B .* R_A_over_R_B;
			post_choice_adjustment = 0.25;
		else
			% change things depending upon last response
			if previouslyChoseDelayed(all_responses)
				R_A = R_A + (R_B * post_choice_adjustment);
			else
				R_A = R_A - (R_B * post_choice_adjustment);
			end
			post_choice_adjustment = post_choice_adjustment / 2;
			R_A_over_R_B = R_A / R_B;
		end
		
		% return this
		design = [R_A_over_R_B D_A P_A R_B D_B(delay_counter) P_B];

		% increment trial counter
		trial_counter = trial_counter + 1;
		% if we have done the right number of trials: reset trial
		% counter and increment delay counter
		if trial_counter > trials_per_delay
			delay_counter = delay_counter + 1;
			trial_counter = 1;
		end
		
	end

	function isChoseDelayed = previouslyChoseDelayed(all_responses)
		isChoseDelayed = all_responses(end) == 1;
	end

end
