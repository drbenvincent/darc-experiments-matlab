classdef Model_ebertprelec_time < Model & ChoiceFuncPsychometric & experiment_type_delay
    %Model_ebertprelec_time

    properties
        k
        tau
    end

    methods

        function obj = Model_ebertprelec_time(varargin)
            % Compose a model ---------------------------------------------
            % all models must inherit from Model
            obj@Model(varargin{:});
            % the choice function
            obj@ChoiceFuncPsychometric(varargin{:});
            % the experimental paradigm to use
            obj@experiment_type_delay(varargin{:});

            % Compose a value function ------------------------------------
            obj.delayDiscountingFunction    = @delayEbertPrelec;
            obj.probWeightingFunction       = @probNone;
            obj.utilityFunction             = @utilityLinear;
            % must have a list of parameters, appropriate for the composed value function
            obj.params = {'k','tau','alpha','epsilon'};

            % priors over parameters --------------------------------------
            obj.priors.k = makedist('Exponential', 'mu',0.2);
            obj.priors.tau = makedist('HalfNormal', 'mu',0, 'sigma', sqrt(0.5));
            
            % parse inputs ------------------------------------------------
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
