classdef Model_expWebber_time < Model & ChoiceFuncPsychometric & experiment_type_delay
    %Model_expWebber_time

    properties
        k, tau
    end

    methods

        function obj = Model_expWebber_time(varargin)
            % Compose a model ---------------------------------------------
            % all models must inherit from Model
            obj@Model(varargin{:});
            % the choice function
            obj@ChoiceFuncPsychometric(varargin{:});
            % the experimental paradigm to use
            obj@experiment_type_delay(varargin{:});

            % Compose a value function ------------------------------------
            obj.delayDiscountingFunction    = @delayExpWebber;
            obj.probWeightingFunction       = @probNone;
            obj.utilityFunction             = @utilityLinear;
            % must have a list of parameters, appropriate for the composed value function
            obj.params = {'k','tau','alpha','epsilon'};

            % priors over parameters --------------------------------------
            obj.priors.k = makedist('Normal', 'mu',0, 'sigma',sqrt(0.15));
            obj.priors.tau = makedist('Exponential', 'mu',1);

            % parse inputs -------------------------------------------------
            p = inputParser;
            p.KeepUnmatched = true;
            p.FunctionName = mfilename;

            % parameters: if empty we infer, if scalar they are fixed
            p.addParameter('k',[], @isnumeric);
            p.addParameter('tau',[], @isnumeric);

            p.parse(varargin{:});
            obj = obj.set_inputs(p);

            % Array of ThetaRecord objects --------------------------------
            % Records summary stats of posterior over parameters. Used for
            % model evaluation purposes, and is not essential to the
            % operation of the model
            k_record = ThetaRecord('k', 'grid', linspace(-5,5,100));
            tau_record = ThetaRecord('tau', 'grid', linspace(0,10,100));
            alpha_record = ThetaRecord('alpha');
            obj.record_array = [k_record, tau_record, alpha_record];
        end

    end

end
