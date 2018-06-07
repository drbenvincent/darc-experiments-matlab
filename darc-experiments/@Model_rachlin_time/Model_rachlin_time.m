classdef Model_rachlin_time < Model & ChoiceFuncPsychometric & experiment_type_delay
    %Model_rachlin_time

    properties
        k
        s
    end

    methods

        function obj = Model_rachlin_time(varargin)
            % Compose a model ---------------------------------------------
            % all models must inherit from Model
            obj@Model(varargin{:});
            % the choice function
            obj@ChoiceFuncPsychometric(varargin{:});
            % the experimental paradigm to use
            obj@experiment_type_delay(varargin{:});

            % Compose a value function ------------------------------------
            obj.delayDiscountingFunction    = @delayRachlin;
            obj.probWeightingFunction       = @probNone;
            obj.utilityFunction             = @utilityLinear;
            % must have a list of parameters, appropriate for the composed value function
            obj.params = {'k','s','alpha','epsilon'};

            % priors over parameters --------------------------------------
            obj.priors.k = makedist('Exponential', 'mu', 0.2);
            obj.priors.s = makedist('Normal', 'mu',1, 'sigma', sqrt(0.5));
            obj.priors.s = truncate(obj.priors.s, 0, inf);
            
            % parse inputs ------------------------------------------------
            p = inputParser;
            p.KeepUnmatched = true;
            p.FunctionName = mfilename;

            % parameters: if empty we infer, if scalar they are fixed
            p.addParameter('k',[], @isnumeric);
            p.addParameter('s',[], @isnumeric);

            p.parse(varargin{:});
            obj = obj.set_inputs(p);

            % Array of ThetaRecord objects --------------------------------
            % Records summary stats of posterior over parameters. Used for 
            % model evaluation purposes, and is not essential to the 
            % operation of the model
            k_record = ThetaRecord('k', 'grid', linspace(-5,5,100));
            tau_record = ThetaRecord('s', 'grid', linspace(0,3,100));
            alpha_record = ThetaRecord('alpha');
            obj.record_array = [k_record, tau_record, alpha_record];
        end
        
    end

end
