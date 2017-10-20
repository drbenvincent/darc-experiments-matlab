classdef (Abstract) experiment_type_delay < ExperimentType
	% For delay discounting experiments
	
	properties
	end
	
	methods
		function obj = experiment_type_delay(varargin)
			obj@ExperimentType(varargin{:});
			
			p = inputParser;
			p.KeepUnmatched = true;
			p.FunctionName = mfilename;
			% design space
			DEFAULT_R_A_over_R_B = (1:1:20-1) ./ 20; % default for discounting
			%DEFAULT_R_A_over_R_B = exp(-4:0.05:1.5); % default for discounting AND anti-discounting
			p.addParameter('R_A_over_R_B', DEFAULT_R_A_over_R_B, @isnumeric);
			%p.addParameter('R_A_over_R_B',(1:1:20-1) ./ 20, @isnumeric);
			p.addParameter('R_B',[100], @isnumeric);
			p.addParameter('D_A',0,@isnumeric);
			
			p.addParameter('D_B', default_D_B(), @isnumeric);
			p.addParameter('heuristic_order',{'D_A','R_B','D_B', 'R_A_over_R_B'}, @cell);
			p.parse(varargin{:});
			
			obj = obj.set_inputs(p);
			
            % Rewards are certain
            obj.P_B = 1;
            obj.P_A = 1;
		end

	end
end
