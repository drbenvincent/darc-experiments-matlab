classdef (Abstract) experiment_type_delay_and_prob < ExperimentType
% For combined delay and probability discounting experiments

    properties
    end

    methods
        function obj = experiment_type_delay_and_prob(varargin)
            obj@ExperimentType(varargin{:});

			p = inputParser;
            p.KeepUnmatched = true;
			p.FunctionName = mfilename;
			% design space
			% one choice will have zero delay and be certain, but we do
			% design optimisation over it's value 
			p.addParameter('D_A', 0, @isnumeric);
			p.addParameter('P_A', 1, @isnumeric);
			p.addParameter('R_A_over_R_B', (1:1:20-1) ./ 20, @isnumeric);
			
			% the other choice will have a fixed reward value, but vary
			% with it's delay and probability
			p.addParameter('R_B', 100, @isnumeric);
			p.addParameter('D_B', default_D_B(), @isnumeric);
			p.addParameter('P_B',default_P_B(), @isnumeric);
			
            warning('I haven''t given any thought to where the heuristic order here is sensible');
            p.addParameter('heuristic_order', {'D_A', 'P_B', 'R_B', 'P_A', 'D_B', 'R_A_over_R_B'}, @cell);
			p.parse(varargin{:});

            obj = obj.set_inputs(p);
            
        end

    end
end
