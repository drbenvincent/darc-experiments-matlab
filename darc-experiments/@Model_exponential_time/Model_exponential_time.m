classdef Model_exponential_time < Model & ChoiceFuncPsychometric & experiment_type_delay
    %Model_exponential_time
    
    properties
        k
    end

    methods

        function obj = Model_exponential_time(varargin)
            % Compose a model ---------------------------------------------
            % all models must inherit from Model
            obj@Model(varargin{:});
            % the choice function
            obj@ChoiceFuncPsychometric(varargin{:});
            % the experimental paradigm to use
            obj@experiment_type_delay(varargin{:});

            % Compose a value function ------------------------------------
            obj.delayDiscountingFunction    = @delayExponential;
            obj.probWeightingFunction       = @probNone;
            obj.utilityFunction             = @utilityLinear;
            % must have a list of parameters, appropriate for the composed 
            % value function
            obj.params = {'k','alpha','epsilon'};

            % priors over parameters --------------------------------------
            obj.priors.k = makedist('HalfNormal', 'mu', 0.01/365, 'sigma', sqrt(0.1));
            
            % parse inputs ------------------------------------------------
            p = inputParser;
            p.KeepUnmatched = true;
            p.FunctionName = mfilename;

            % parameters: if empty we infer, if scalar they are fixed
            p.addParameter('k',[], @isnumeric);

            % parse inputs
            p.parse(varargin{:});
            obj = obj.set_inputs(p);

            % Array of ThetaRecord objects --------------------------------
            % Records summary stats of posterior over parameters. Used for 
            % model evaluation purposes, and is not essential to the 
            % operation of the model
            logk_record = ThetaRecord('k', 'grid', linspace(0,5,100));
            alpha_record = ThetaRecord('alpha');
            obj.record_array = [logk_record, alpha_record];
        end

    end

end
