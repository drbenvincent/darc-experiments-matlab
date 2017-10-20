classdef Model_hyperbolic1ME_time < Model & ChoiceFuncPsychometric & experiment_type_delay
    %Model_hyperbolic1ME_time

    properties
        m, c % If set these mean the corresponding parameter is fixed
    end

    methods

        function obj = Model_hyperbolic1ME_time(varargin)
            % Compose a model ---------------------------------------------
            % all models must inherit from Model
            obj@Model(varargin{:});
            % the choice function
            obj@ChoiceFuncPsychometric(varargin{:});
            % the experimental paradigm to use
            obj@experiment_type_delay(varargin{:});

            % Compose a value function ------------------------------------
            obj.delayDiscountingFunction    = @delayHyperbolicMagnitudeEffect;
            obj.probWeightingFunction       = @probNone;
            obj.utilityFunction             = @utilityLinear;
            % must have a list of parameters, appropriate for the composed value function
            obj.params = {'m','c','alpha','epsilon'};

            % priors over parameters
            obj.priors.m = makedist('Normal', 'mu',-0.243, 'sigma',sqrt(1));
            obj.priors.c = makedist('Normal', 'mu',0, 'sigma',sqrt(10));

            % parse inputs ------------------------------------------------
            p = inputParser;
            p.KeepUnmatched = true;
            p.FunctionName = mfilename;
            % design space
            p.addParameter('R_B', [10 100 1000], @isnumeric); % Overwriting default

            % parameters: if empty we infer, if scalar they are fixed
            p.addParameter('m',[], @isnumeric);
            p.addParameter('c',[], @isnumeric);

            % this will override heuristic_strategy default set in ChoiceFuncPsychometric
            p.addParameter('heuristic_strategy','random_no_replacement', @isstr);

            p.parse(varargin{:});
            obj = obj.set_inputs(p);

            % Array of ThetaRecord objects --------------------------------
            % Records summary stats of posterior over parameters. Used for
            % model evaluation purposes, and is not essential to the
            % operation of the model
            m_record = ThetaRecord('m', 'grid', linspace(-5,4,100));
            c_record = ThetaRecord('c', 'grid', linspace(-20,20,100));
            alpha_record = ThetaRecord('alpha');
            obj.record_array = [m_record, c_record, alpha_record];
        end

    end

end
