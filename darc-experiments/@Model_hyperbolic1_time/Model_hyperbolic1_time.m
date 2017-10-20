classdef Model_hyperbolic1_time < Model & ChoiceFuncPsychometric & experiment_type_delay
    %Model_hyperbolic1_time
    
    properties
        logk
    end

    methods

        function obj = Model_hyperbolic1_time(varargin)
            % Compose a model ---------------------------------------------
            % all models must inherit from Model
            obj@Model(varargin{:});
            % the choice function
            obj@ChoiceFuncPsychometric(varargin{:});
            % the experimental paradigm to use
            obj@experiment_type_delay(varargin{:});

            % Compose a value function ------------------------------------
            obj.delayDiscountingFunction    = @delayHyperbolic;
            obj.probWeightingFunction       = @probNone;
            obj.utilityFunction             = @utilityLinear;
            % must have a list of parameters, appropriate for the composed 
            % value function
            obj.params = {'logk','alpha','epsilon'};

            % priors over parameters --------------------------------------
            obj.priors.logk = makedist('Normal', 'mu',-4.5, 'sigma',sqrt(1));
            
            % parse inputs ------------------------------------------------
            p = inputParser;
            p.KeepUnmatched = true;
            p.FunctionName = mfilename;

            % parameters: if empty we infer, if scalar they are fixed
            p.addParameter('logk',[], @isnumeric);

            % parse inputs
            p.parse(varargin{:});
            obj = obj.set_inputs(p);

            % Array of ThetaRecord objects --------------------------------
            % Records summary stats of posterior over parameters. Used for 
            % model evaluation purposes, and is not essential to the 
            % operation of the model
            logk_record = ThetaRecord('logk', 'grid', create_log_k_grid_points);
            alpha_record = ThetaRecord('alpha');
            obj.record_array = [logk_record, alpha_record];
        end

    end

end
