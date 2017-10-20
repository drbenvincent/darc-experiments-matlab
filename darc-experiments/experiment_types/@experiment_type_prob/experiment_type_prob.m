classdef (Abstract) experiment_type_prob < ExperimentType
% For probability discounting experiments

    properties
    end

    methods
        function obj = experiment_type_prob(varargin)
            obj@ExperimentType(varargin{:});

			p = inputParser;
            p.KeepUnmatched = true;
			p.FunctionName = mfilename;
			
            % design space
            p.addParameter('R_A_over_R_B',(1:1:20-1) ./ 20, @isnumeric);
			p.addParameter('R_B',[100], @isnumeric);
            p.addParameter('P_A',1,@isnumeric);
			p.addParameter('P_B',[0.01 0.02 [0.05:0.05:0.95]], @isnumeric);
            p.addParameter('heuristic_order',{'P_B','R_B','P_A','R_A_over_R_B'}, @cell);
			p.parse(varargin{:});

            obj = obj.set_inputs(p);
            
            % Rewards are immediate, no delay
            obj.D_B = 0;
            obj.D_A = 0;
        end

    end
end
