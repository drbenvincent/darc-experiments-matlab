classdef Experiment
    %Experiment A class to run Bayesian Adaptive Design experiments
    %   The Experiment class is that ties everything together.
    %
    %   Required inputs:
    %   - model:    a probabilistic model of an observer's responses. This
    %               must be a subclass of the class Model.
    %
    %   Optional inputs as key/value pairs:
    %   - n_points: integer number of particles to represent the posterior
    %               distribution over model parameters
    %   - true_theta: a structure with field names corresponding to all
    %               free parameters of the model. Values should be NaN if
    %               we wish to estimate these parameters (ie when running
    %               real experiments), or provided true scalar values if
    %               running a simulated experiment.
    %   - agent:    'real_agent' [default] | 'simulated_agent'
    %   - plotting: 'none' | 'end' | 'full' | 'demo'
    %   - save_path:  path in which to save raw data
    %   - expt_options: XXXXXXX
    %   - trials:   only need when agent='simulated_agent'.
    %
    % Minimal example with human participant:
    % >> myModel = Model_hyperbolic1_time('epsilon', 0.01);
    % >> expt = Experiment(myModel);
    % >> expt = expt.runTrials();
    %
    % Minimal example with simulated participant:
    % >> myModel = Model_hyperbolic1_time('epsilon', 0.01);
    % >> expt = Experiment(myModel,...
    % >> 	'agent', 'simulated_agent',...
    % >> 	'true_theta', struct('logk', -3, 'alpha', 2));
    % >> expt = expt.runTrials();
    
    properties
        %model
    end
    
    % read only: we want the user to be able to see but not alter these
    properties (SetAccess = protected)
        %p
        model
        %previous_designs
        theta, true_theta
        %all_responses
        expt_options
        %all_reaction_times
        human_response_options % key/value pairs... cell array of strings
        data_table
        % string of optional text to include in the filename of saved
        % files. This will be used in addition to default information such
        % as the participant ID, date, time, and model name.
        save_text
    end
    
    % protected
    properties (Access = protected)
        userArgs
        previous_designs
        all_responses
        all_reaction_times
        all_true_thetas_inc_fixed
        response_objects
    end
    
    methods
        
        function obj = Experiment(model, varargin)
            userArgs = inputParser;
            userArgs.FunctionName = mfilename;
            userArgs.addParameter('n_points', 5e4, @isinteger);
            userArgs.addParameter('true_theta', [], @(x) (isempty(x) || isstruct(x)));
            userArgs.addParameter('agent', 'real_agent', @(x) any(strcmp(x,{'simulated_agent','real_agent'})));
            userArgs.addParameter('plotting', 'end', @(x) any(strcmp(x,{'none','end','full','demo'})));
            userArgs.addParameter('save_path', fullfile(cd,'data'), @isstr);
            userArgs.addParameter('save_text', '', @isstr);
            userArgs.addParameter('expt_options', struct(), @isstruct)
            userArgs.addParameter('trials', 30, @isnumeric)
            userArgs.addParameter('human_response_options', {}, @iscellstr)
            userArgs.addParameter('reward_type', 'real', @(x) any(strcmp(x,{'real','integer'})));
            userArgs.parse(varargin{:});
            
            obj.userArgs = userArgs.Results;
            clear userArgs
            
            % check provided model is a subclass of Model
            assert(isa(model,'Model'), 'Model must be a subclass of the Model class.')
            
            obj.model                   = model; clear model
            obj.human_response_options  = obj.userArgs.human_response_options;
            obj.all_reaction_times      = NaN(0,1);
            obj.expt_options            = setExperimentOptions(obj);
            obj.response_objects        = [];
            obj = setup_true_theta(obj);
            obj = update_model_with_true_theta_information(obj);
            obj = setup_prior_particles(obj);
            
            
            function obj = setup_prior_particles(obj)
                previous_designs = [];
                all_responses = NaN(0,1);
                % Obtain prior samples ----------------------------------------
                theta = obj.model.generate_initial_samples(obj.userArgs.n_points);
                p_log_pdf = @(theta,data) obj.model.p_log_pdf(theta,data);
                n_steps = 5;
                [obj.theta, log_Z] = random_walk_pmc(p_log_pdf,theta,n_steps,...
                    'student_t',[],[],[], [previous_designs, all_responses]);
                % Record summary stats of prior (trial = 0)
                obj = obj.updateThetaRecord();
            end
            
            function expt_options = setExperimentOptions(obj)
                isAgentHuman = @() strcmp(obj.userArgs.agent,'real_agent');
                noOptionsProvided = @() numel(fields(obj.userArgs.expt_options))==0;
                if isAgentHuman()
                    if noOptionsProvided()
                        % ask for experiment options with a gui
                        [expt_options] = getHumanExperimentOptions();
                    else
                        % use provided experiment options
                        expt_options = obj.userArgs.expt_options;
                    end
                else
                    % default options for simulated participants
                    expt_options.participantID = 'simulatedParticipant';
                    expt_options.trials = obj.userArgs.trials;
                end
            end
            
            function obj = setup_true_theta(obj)
                %% True theta #################################################
                % We are going to assume that all true_theta values are NaN by
                % default, but will overwrite these with any supplied values.
                
                % Extract true theta with care about ordering
                if isempty(obj.userArgs.true_theta)
                    % When no true_theta values are provided, we will assume
                    % that we are testing a human (all params unknown) and so
                    % will take on values of NaN.
                    param_names = obj.model.params;
                    % Now check the fixed params have correct values.
                    % Currently, these are provided in Model
                    isFixed = obj.model.is_theta_fixed;
                    for n = 1:numel(param_names)
                        if isFixed(n)
                            % remove field, if it exists
                            if isfield(obj.true_theta, param_names{n})
                                obj.true_theta = rmfield(obj.true_theta, param_names{n});
                            end
                            obj.all_true_thetas_inc_fixed.(param_names{n}) = ...
                                eval('obj.model.(param_names{n})');
                        else
                            obj.true_theta.(param_names{n}) = NaN;
                            obj.all_true_thetas_inc_fixed.(param_names{n}) = NaN;
                        end
                    end
                else
                    % We have been provided some values for true_theta. This is
                    % appropriate when running experiments with simulated
                    % agents, where we define the true parameter values.
                    
                    % Second output currently unused but left for exposition in case you
                    % need it
                    [obj.true_theta, obj.all_true_thetas_inc_fixed] = obj.model.packTheta(obj.userArgs.true_theta);
                end
            end
            
            % TODO: this should be the responsibility of the Model class
            function obj = update_model_with_true_theta_information(obj)
                
                % Append this true theta information to the ThetaRecord
                % array in obj.model.
                % Note that if we have fixed one of the parameters, then we
                % need to remove this from record_array
                
                % find any fixed parameters (eg 'm') and remove them ----------
                param_names = obj.model.params;
                is_theta_fixed = obj.model.is_theta_fixed();
                to_remove = obj.model.params(is_theta_fixed);
                remove_list = [];
                for r = 1:numel(to_remove)
                    for n=1:numel(obj.model.record_array)
                        if strcmp(obj.model.record_array(n).name, to_remove(r))
                            remove_list = [remove_list n];
                        end
                    end
                end
                obj.model.record_array(remove_list) = [];
                % -------------------------------------------------------------
                
                % set the true value of free parameters of any remaining things
                % in record_array
                if ~isempty(obj.userArgs.true_theta)
                    param_names_in_array = {obj.model.record_array.name};
                    
                    for n = 1:numel(param_names_in_array)
                        % get the index for this param name
                        i = find(strcmp(param_names_in_array{n}, obj.model.params));
                        % set the true value
                        obj.model.record_array(n).true_value = obj.all_true_thetas_inc_fixed(i);
                    end
                end
                
            end
            
        end
        
        
        function obj = runTrials(obj)
            for trial = 1:obj.expt_options.trials
                obj = obj.runOneTrial();
            end
            obj.export_current_point_estimates();
            obj.end_of_experiment_plotting();
        end
        
        
        function obj = runOneTrial(obj)
            chosen_design = obj.getNextDesign();
            response_object = obj.collect_response(chosen_design);
            obj = obj.enterAgentResponse(chosen_design, response_object);
            obj.end_of_trial_plotting();
        end
        
        
        function obj = runOneManualTrial(obj, chosen_design)
            % This function allows users to run manually specified trials.
            % You need to provide the chosen_design, taking care that you
            % understand the format of the chosen_design vector.
            [choseLater, reaction_time] = obj.collect_response(chosen_design);
            obj = obj.enterAgentResponse(chosen_design, choseLater, reaction_time);
            obj.end_of_trial_plotting();
        end
        
        
        % GETTERS =========================================================
        
        function theta_record = get_theta_record(obj)
            theta_record = obj.model.record_array;
        end
        
        function theta_record = get_specific_theta_record_parameter(obj, target_parameter_name)
            % return the ThetaRecord object for the specified parameter
            theta_record = obj.model.record_array;
            param_names = {theta_record.name};
            boolean_match_vector = strcmp(param_names,target_parameter_name);
            theta_record = theta_record(boolean_match_vector);
        end
        
        function theta = get_theta(obj)
            theta = obj.theta;
        end
        
        function theta = get_theta_as_struct(obj)
            theta = obj.model.theta_to_struct(obj.theta);
        end
        
        function data_struct = get_data_struct(obj)
            data_struct = table2struct(obj.data_table);
        end
        
        %         function data_table = get_data_table(obj)
        %             data_table = obj.data_table;
        %         end
        
        function [last_design, last_response_object] = get_last_trial_info(obj)
            % get the design and response object from the last trial. This is
            % used when we want to provide design and response information from
            % one model and provide it to another model.
            last_design = obj.previous_designs(end,:);
            last_response_object = obj.response_objects(end);
        end
        
        
        % SETTERS =========================================================
        
        function obj = set_human_response_options(obj, options)
            assert(iscellstr(options), 'provided options must be a cell array of strings')
            obj.human_response_options = options;
        end
        
        
        function obj = enterAgentResponse(obj, chosen_design, response_object)
            % Call this function once we have a response from an agent
            
            % append to data
            obj.previous_designs = [obj.previous_designs; chosen_design];
            obj.response_objects = [obj.response_objects response_object];
            obj.all_responses = [obj.all_responses; response_object.didChooseB];
            obj.all_reaction_times = [obj.all_reaction_times; response_object.reaction_time];
            % must be called AFTER we've appended to previous_designs and all_responses
            obj = obj.updateBeliefs();
            
            obj.export_current_point_estimates();
            % Store summary data
            obj = obj.updateThetaRecord();
            
            obj = obj.update_experiment_results();
            % For extra caution, save response data after every response
            obj.export_raw_trial_data();
        end
        
        function obj = set_save_text(obj, save_text)
            obj.save_text = save_text;
        end
        
    end
    
    
    
    methods (Access = protected)
        
        
        function chosen_design = getNextDesign(obj)
            % this function's job is to provide a design. If the return value
            % is empty, then this indicates the end of the experiment.
            chosen_design = [];
            if isempty(obj.model.design_override_function)
                % This is what we will do most of the time
                chosen_design = obj.get_design_using_design_optimisation();
            else
                % Alternative design generation function provided
                % We have provided some alternative function... no design optimisation
                % NOTE: model.design_override_function should have the same arguments
                % as model.generate_designs, even if it doesn't use them. Ideally
                % this would be done by subclassing, or an interface, but at the
                % moment we just have this override function dealeo.
                chosen_design = obj.model.design_override_function(obj.previous_designs, obj.all_responses);
                if isempty(chosen_design)
                    % no designs provided... assume end of experiment
                    return
                end
            end
        end
        
        
        function chosen_design = get_design_using_design_optimisation(obj)
            % Generate designs based upon a set of heuristics
            designs_allowed = obj.model.generate_designs(obj.previous_designs, obj.all_responses, obj.theta);
            
            % Do design optimisation over the set of designs being considered
            if nrows(designs_allowed) > 1
                [chosen_design, design_utilties] = obj.do_design_optimisation(designs_allowed);
            else
                warning('Skipping design optimisation: only 1 possible design provided')
                chosen_design = designs_allowed;
            end
        end
        
        
        function [response_object] = collect_response(obj, chosen_design)
            
            switch obj.userArgs.agent
                case{'simulated_agent'}
                    response_object = obj.model.getSimulatedResponse(chosen_design, obj.true_theta);
                    
                case{'real_agent'}
                    % TODO: now this is here, we can do dependency
                    % injection by providing our own user-defined function
                    % in the Experiment constructor.
                    [prospectA, prospectB] = obj.model.design2prospects(chosen_design);
                    
                    % Set rewards of prospects to be integer, if we have
                    % asked for that
                    switch obj.userArgs.reward_type
                        case{'integer'}
                            prospectA.reward = round(prospectA.reward);
                            prospectB.reward = round(prospectB.reward);
                    end
                    
                    response_object = getHumanResponse(prospectA, prospectB,...
                        obj.human_response_options{:});
            end
            
        end
        
        
        function obj = updateBeliefs(obj)
            
            % THIS IS A VERY SPECIFIC WAY OF CREATING A FUNCTION HANDLE
            % TO A CLASS METHOD, WHEN THAT CLASS IS NOT A HANDLE CLASS,
            % IE A VALUE CLASS.
            p_log_pdf = @(theta,data) obj.model.p_log_pdf(theta,data);
            
            % Update beliefs (based on all data)
            n_steps = 5;
            [obj.theta, log_Z] = random_walk_pmc(p_log_pdf,...
                obj.theta,...
                n_steps,...
                'student_t',...
                [],[],[],...
                [obj.previous_designs, obj.all_responses]);
        end
        
        
        function obj = updateThetaRecord(obj)
            % Ask the model to update it's record of the current particles
            % representing the posterior
            obj.model = obj.model.update_record_array(obj.theta);
        end
        
        
        function [chosen_design, design_utilties] = do_design_optimisation(obj, designs_allowed)
            % For a given set of designs_allowed, conduct design
            % optimisation
            assert(nrows(designs_allowed)>0,...
                'No entries in `designs_allowed`. This should have been caught before this point.')
            if nrows(designs_allowed)==1
                design_utilties = [];
                chosen_design = designs_allowed;
            else
                % Design optimisation ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                % THIS IS A VERY SPECIFIC WAY OF CREATING A FUNCTION HANDLE
                % TO A CLASS METHOD, WHEN THAT CLASS IS NOT A HANDLE CLASS,
                % IE A VALUE CLASS.
                log_predictive_y = @(theta,designs) obj.model.log_predictive_y(theta,designs);
                [chosen_design, design_utilties] = discrete_smc_search_binary_output(...
                    log_predictive_y, designs_allowed, obj.theta);
                % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                
                % used for debugging only
                % obj.plot_design_utilities(design_utilties)
            end
        end
        
        
        function obj = update_experiment_results(obj)
            % gather experiment information (designs, responses, reaction
            % times) into a Table
            
            assert(~isempty(obj.previous_designs), 'No previous designs')
            obj.data_table = obj.build_data_table();
        end
        
        function data_table = build_data_table(obj)
            % build a Table of data, each row is a trial
            
            % construct initial table with design variables
            data_table = array2table(obj.previous_designs,...
                'VariableNames', obj.model.design_variables);
            % convert R_A_over_R_B to R_A
            data_table.R_A = data_table.R_A_over_R_B .* data_table.R_B;
            data_table.R_A_over_R_B = [];
            
            % append responses column
            data_table.R = obj.all_responses;
            
            % append reaction times
            data_table.reaction_time = obj.all_reaction_times;
        end
        
        % EXPORTING FUNCTIONS ==================================================
        
        function export_raw_trial_data(obj)
            % incude model class name in the filename. Helps to keep things clear when
            % we are running multiple types of experiments on a single participant
            Model_class_name = class(obj.model);
            filename = [obj.expt_options.participantID...
                '-' obj.save_text...
                '-' Model_class_name...
                '-rawdata'];
            full_save_path_and_filename = fullfile(obj.userArgs.save_path, filename);
			
            exportData(full_save_path_and_filename,...
				R_binary_to_categorical_coding(obj.data_table));
			
			function data_table = R_binary_to_categorical_coding(data_table)
				% Use a fail-proof, explicit, coding of the response choice
				% in order to eliminate human error when
				% reading/interpreting the raw trial data.
				
				% Convert from (0=chose A, 1=chose B), to an explicit
				% (A, B) coding.
				
				choseA = data_table.R==0;
				choseB = data_table.R==1;
				
				new_R_column(choseA, 1) = 'A';
				new_R_column(choseB, 1) = 'B';
				
				data_table.R = new_R_column;
			end
        end
        
        function export_current_point_estimates(obj)
            
            % Build filename
            Model_class_name = class(obj.model);
            filename = [obj.expt_options.participantID...
                '-' obj.save_text...
                '-' Model_class_name...
                '-params'];
            full_save_path_and_filename = fullfile(obj.userArgs.save_path, 'theta', filename);
            
            % do the export
            exportData(full_save_path_and_filename, obj.build_point_estimate_table)
        end
        
        function point_estimate_table = build_point_estimate_table(obj)
            % create table of median param estimates of free params
            free_param_names = obj.model.params(~obj.model.is_theta_fixed);
            
            point_estimate_table = array2table(median(obj.theta),...
                'VariableNames', free_param_names);
            
            point_estimate_table = appendAUCdelay(point_estimate_table, 365);
            
            point_estimate_table = appendAUCprob(point_estimate_table);
            
            function point_estimate_table = appendAUCdelay(point_estimate_table, max_delay)
                warning('Takes a short moment, so maybe don''t do this every trial')
                AUC_delay = obj.model.calculateAUCdelay(max_delay, obj.theta);
                % append column to table
                if ~isempty(AUC_delay)
                    var_name = ['AUC_delay' num2str(max_delay)];
                    point_estimate_table.(var_name) = AUC_delay;
                end
            end
            
            function point_estimate_table = appendAUCprob(point_estimate_table)
                warning('Takes a short moment, so maybe don''t do this every trial')
                AUC_prob = obj.model.calculateAUCprob(obj.theta);
                % append column to table
                if ~isempty(AUC_prob)
                    point_estimate_table.AUC_prob01 = AUC_prob;
                end
            end
        end
        
        
        % PLOTTING FUNCTIONS ===================================================
        
        function end_of_trial_plotting(obj)
            switch obj.userArgs.plotting
                case{'full', 'demo'}
                    obj.common_plot_functions();
                    obj.model_specific_plots();
            end
        end
        
        function end_of_experiment_plotting(obj)
            if strcmp(obj.userArgs.plotting,'end')
                obj.model_specific_plots();
                obj.common_plot_functions();
            end
        end
        
        function common_plot_functions(obj)
            % MODEL-INDEPENDENT PLOT: summary stats of theta over trials
            
            figure(6)
            obj.model.record_array.plot_summary()
            
            % corner plot of parameters
            figure (7)
            is_theta_fixed = obj.model.is_theta_fixed();
            allvariableNames = obj.model.params;
            freeVariableNames = allvariableNames(~is_theta_fixed);
            
            samples = obj.theta;
            tri = mcmc.TriPlotSamples(samples,...
                freeVariableNames,...
                'figSize', 15,...
                'pointEstimateType', 'median');
        end
        
        function model_specific_plots(obj)
            [thetaStruct] = obj.model.theta_to_struct(obj.theta);
            obj.model.plotting(thetaStruct, obj.data_table);
        end
        
        function plot_design_utilities(obj, design_utilties)
            % used for debugging only
            if strcmp(obj.userArgs.plotting, 'full')
                %disp(['Design chosen ' num2str(chosen_design)]);
                % Plot the utilities as a sanity check
                if ~exist('hU', 'var')
                    hU = figure(873);
                else
                    figure(hU);
                end
                plot(design_utilties);
                xlabel('D');
                ylabel('U(D)');
            end
        end
        
    end
    
end
