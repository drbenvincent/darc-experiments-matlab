classdef Model_hyperboloid_prob < Model & ChoiceFuncPsychometric & experiment_type_prob
    %Model_hyperbolic1_prob

    properties
        h, s
    end

    methods

        function obj = Model_hyperboloid_prob(varargin)
            % Compose a model ---------------------------------------------
            % all models must inherit from Model
            obj@Model(varargin{:});
            % the choice function
            obj@ChoiceFuncPsychometric(varargin{:});
            % the experimental paradigm to use
            obj@experiment_type_prob(varargin{:});

            % Compose a value function ------------------------------------
            obj.delayDiscountingFunction    = @delayNone;
            obj.probWeightingFunction       = @probHyperboloid;
            obj.utilityFunction             = @utilityLinear;
            % must have a list of parameters, appropriate for the composed value function
            obj.params = {'h', 's', 'alpha', 'epsilon'};

            % priors over parameters
            obj.priors.h = makedist('HalfNormal', 'mu', 1, 'sigma', sqrt(5));
            
            % mode = 1; % <--------------------- hyperparameter
            % variance = 20; % <--------------------- hyperparameter
            % % transform to shape and scale
            % scale = 0.5*(-mode+sqrt(mode.^2+4*variance));
            % shape = (mode./scale)+1;
            obj.priors.s = makedist('HalfNormal', 'mu', 1, 'sigma', sqrt(1));

            % parse inputs ------------------------------------------------
            p = inputParser;
            p.KeepUnmatched = true;
            p.FunctionName = mfilename;

            % parameters: if empty we infer, if scalar they are fixed
            p.addParameter('h',[], @isnumeric);
            p.addParameter('s',[], @isnumeric);

            p.parse(varargin{:});
            obj = obj.set_inputs(p);

            % Array of ThetaRecord objects --------------------------------
            % Records summary stats of posterior over parameters. Used for
            % model evaluation purposes, and is not essential to the
            % operation of the model
            h_record = ThetaRecord('h', 'grid', linspace(-10,10,100));
            s_record = ThetaRecord('s', 'grid', linspace(0,4,100));
            alpha_record = ThetaRecord('alpha');
            obj.record_array = [h_record, s_record, alpha_record];
        end

    end

end
