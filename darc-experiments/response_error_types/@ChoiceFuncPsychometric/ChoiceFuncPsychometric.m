classdef (Abstract) ChoiceFuncPsychometric
    % This model details many of the features common to our delay discounting
    % approach such as information about alpha and epsilon
    %
    % TR 01/06/16

    properties
        % Parameter, either fixed or left blank for inference
        alpha, epsilon
    end

    methods
        function obj = ChoiceFuncPsychometric(varargin)
            %obj@Model(varargin{:});

            p = inputParser;
            p.KeepUnmatched = true;
			p.FunctionName = mfilename;

			% parameters: if empty we infer, if scalar they are fixed
			p.addParameter('alpha',[], @isnumeric);
			p.addParameter('epsilon',[], @isnumeric);   
            
            % stuff to do with heuristics
			p.addParameter('heuristic_strategy','subjective_value_spreading', @isstr);
            p.addParameter('n_design_opt',100); % Only matters if heuristic_strategy = subjective_value_spreading
                                                % Similarly heuristic_order
                                                % only needed later if not
            p.addParameter('heuristic_rate',0.75);  % See Model
			
            % parsing of input options
            p.parse(varargin{:});
            obj = obj.set_inputs(p);
            
            % priors over parameters
            obj.priors.alpha = makedist('HalfNormal', 'mu',0, 'sigma',sqrt(3));
            obj.priors.epsilon = makedist('Beta', 'a',1+1, 'b',1+100);
        end
    end

    methods(Static)
        
    end
end
