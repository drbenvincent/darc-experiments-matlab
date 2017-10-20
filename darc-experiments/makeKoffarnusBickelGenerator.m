function f = makeKoffarnusBickelGenerator(R_B)
% This function returns a function which returns designs according to the 
% method described by:
% Koffarnus, M. N., & Bickel, W. K. (2014). A 5-trial adjusting delay 
% discounting task: Accurate discount rates in less than one minute. 
% Experimental and Clinical Psychopharmacology, 22(3), 222?228. 
% http://doi.org/10.1037/a0035973
%
% Once the number of trials are up, it will return an empty value, []
%
% Example usage:
%  DesignGenerator = makeKoffarnusBickelGenerator(100);
%  design = DesignGenerator()
%  design = DesignGenerator()
%  ...


trial = 1;
index_increments = 8;
% define the delays from their paper (converted into days
D_B = [ (1/24).*[1, 2, 3, 4, 6, 9, 12],... % hours
	1, 1.5, 2, 3, 4, ... % days
	7.*[1,1.5, 2, 3],... % weeks
	29.*[1, 2, 3, 4, 6, 8],... % months
	365.*[1, 2, 3, 4, 5, 8, 12, 18, 25]]; % years
delay_index = 16; % this is always the initial delay used (equals 3 weeks)
D_A = 0;
R_A_over_R_B = 0.5; % always 0.5
P_A = 1;
P_B = 1;
MAX_DESIGNS = 5;

% package up
%DESIGNS = [R_A_over_R_B D_A R_B D_B]; % TODO: DOES ORDER MATTER? IF SO, IS THIS CORRECT?


	function design = designGetter(~, all_responses)
		% arguments are: previous_designs, all_responses
		% but this is independent of previous designs run
			
		if trial >= 2
			
			if previouslyChoseDelayed(all_responses)
				delay_index = round(delay_index + index_increments);
			else % immediate
				delay_index = round(delay_index - index_increments);
			end
			
			% each trial, the increments half, so will be: 8, 4, 2, 1
			index_increments = round(index_increments/2);
		end
		
		if trial > MAX_DESIGNS
			% done max trials, so just return empty
			design=[];
		else
			design = [R_A_over_R_B D_A P_A R_B D_B(delay_index) P_B];
			trial = trial + 1;
		end
	end

	function isChoseDelayed = previouslyChoseDelayed(all_responses)
		isChoseDelayed = all_responses(end) == 1;
	end

f = @designGetter;

end
