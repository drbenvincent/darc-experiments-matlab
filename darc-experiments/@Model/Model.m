classdef (Abstract) Model
% This is the bottom of the class structure and lays out variables and
% functions that will be need in all scenarios, regardless of model.

    properties
        params
        priors % structure of Probability Distribution objects
		record_array % an array of ThetaRecord objects
		true_theta
        delayDiscountingFunction % function handle
        probWeightingFunction % function handle
        utilityFunction % function handle
    end

    methods

        function obj = Model(varargin)
            % parse inputs -----------------------------------------------------
            p = inputParser;
            p.KeepUnmatched = true;
			p.FunctionName = mfilename;
			p.addParameter('design_override_function',[], @ishandle); % TODO: IS THIS CODE EVER REACHED?
            p.parse(varargin{:});
            obj = obj.set_inputs(p);
        end

        function obj = set_inputs(obj,p)
            % add p.Results fields into obj
            fields_to_set = fieldnames(p.Results);
            for n=1:numel(fields_to_set)
                obj.(fields_to_set{n}) = p.Results.(fields_to_set{n});
            end
            unmatched_fields = fields(p.Unmatched);
            obj_props = properties(obj);
            for n=1:numel(unmatched_fields)
                if ~any(strcmp(unmatched_fields{n},obj_props))
                    error([unmatched_fields{n} 'is not a valid property to set']);
                end
            end
        end
        
        function obj = update_record_array(obj, theta)
            % Update our record keeping of the posterior over parameters
            % given the current set of particles provided in `theta`
            free_params = obj.params(~obj.is_theta_fixed);

            % TODO: Code below should be the responsibility of ThetaRecord class
            
            % loop over free variables, adding the samples.
            for n=1:numel(free_params)
                % We don't know that the variables in model.record_array are
                % present in the same order as model.params, so we need to
                % search for the right match in model.record_array
                for m=1:numel(obj.record_array)
                    if strcmp(free_params{n}, obj.record_array(m).name)
                        samples = theta(:,n);
                        obj.record_array(m) = obj.record_array(m).addSamples(samples);
                        clear samples
                    end
                end
            end
        end
        
        function obj = setPrior(obj, paramName, probabilityObject)
            % This function allows users to override the default priors
            % with their own. 
            % - paramName must correspond to a valid parameter name for
            % this model
            % - probabilityObject must be a matlab probability object made
            % by the `makedist` function.
            obj.priors.(paramName) = probabilityObject;
        end

        % Declarations generic
        b_fixed = is_theta_fixed(obj);
        ll = log_likelihood(obj,theta, previous_designs, previous_responses);
        thetaFull = makeThetaWithAnyFixedValues(obj, theta);
        [theta, all_thetas] = packTheta(obj, theta_struct);
        unpackTheta(obj, thetas);

        % Declarations to be written in inhereting classes that are model
        % specific
        logp = log_prior_pdf(obj,theta);
        initial_thetas = generate_initial_samples(obj,n_samples);
        p_log_pdf = p_log_pdf(obj, theta, data);
    end

end
