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
    end
    
    % protected
    properties (Access = protected)
        p
        previous_designs
        all_responses
        all_reaction_times
        all_true_thetas_inc_fixed
    end
    
    methods
        
        function obj = Experiment(model, varargin)
            p = inputParser;
            p.FunctionName = mfilename;
            p.addParameter('n_points', 5e4, @isinteger);
            p.addParameter('true_theta', [], @(x) (isempty(x) || isstruct(x)));
            p.addParameter('agent', 'real_agent', @(x) any(strcmp(x,{'simulated_agent','real_agent'})));
            p.addParameter('plotting', 'end', @(x) any(strcmp(x,{'none','end','full','demo'})));
            p.addParameter('save_path', fullfile(cd,'data'), @isstr);
            p.addParameter('expt_options', struct(), @isstruct)
            p.addParameter('trials', 30, @isnumeric)
            p.addParameter('human_response_options', {}, @iscellstr)
            p.parse(varargin{:});
            
            obj.p.Results = p.Results;
            
            % check provided model is a subclass of Model
            assert(isa(model,'Model'), 'Model must be a subclass of the Model class.')
            obj.model = model;
            
            obj.human_response_options = p.Results.human_response_options;
                        
            % Deal with expt_options for human experiments
            obj.expt_options = obj.setExperimentOptions(p);
            
            %% True theta #################################################
            % We are going to assume that all true_theta values are NaN by
            % default, but will overwrite these with any supplied values.
            
            % Extract true theta with care about ordering
            if isempty(p.Results.true_theta)
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
                [obj.true_theta, obj.all_true_thetas_inc_fixed] = model.packTheta(p.Results.true_theta);
            end
            
            
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
            if ~isempty(p.Results.true_theta)
                param_names_in_array = {obj.model.record_array.name};
                
                for n = 1:numel(param_names_in_array)
                    % get the index for this param name
                    i = find(strcmp(param_names_in_array{n}, obj.model.params));
                    % set the true value
                    obj.model.record_array(n).true_value = obj.all_true_thetas_inc_fixed(i);
                end
            end
            
            % #############################################################
            
            
            
            % Set up
            previous_designs = [];
            all_responses = NaN(0,1);
            obj.all_reaction_times = NaN(0,1);
            
            % Obtain prior samples ----------------------------------------
            theta = model.generate_initial_samples(p.Results.n_points);
            p_log_pdf = @(theta,data) obj.model.p_log_pdf(theta,data);
            n_steps = 5;
            [obj.theta, log_Z] = random_walk_pmc(p_log_pdf,theta,n_steps,...
                'student_t',[],[],[], [previous_designs, all_responses]);
            % Record summary stats of prior (trial = 0)
            obj = obj.updateThetaRecord();
            % -------------------------------------------------------------
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
            [choseLater, reaction_time] = obj.collect_response(chosen_design);
            obj = obj.enterAgentResponse(chosen_design, choseLater, reaction_time);
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
        
        
%         % Public plot methods =============================================
%         function plotDiscountFunction(obj)
%             warning('sort these plot methods for prob weighting and utility etc')
%             [thetaStruct] = obj.model.theta_to_struct(obj.theta);
%             obj.model.plotting(thetaStruct, obj.data_table);
%         end
        
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
        
        % SETTERS =========================================================
        
        function obj = set_human_response_options(obj, options)
            assert(iscellstr(options), 'provided options must be a cell array of strings')
            obj.human_response_options = options;
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
        
        
        
        function [responseDidChooseB, reaction_time] = collect_response(obj, chosen_design)
            
            switch obj.p.Results.agent
                case{'simulated_agent'}
                    response_data = obj.model.getSimulatedResponse(chosen_design, obj.true_theta);
                    
                case{'real_agent'}
                    % TODO: now this is here, we can do dependency
                    % injection by providing our own user-defined function
                    % in the Experiment constructor.
                    [prospectA, prospectB] = obj.model.design2prospects(chosen_design);
                    
                    response_data = getHumanResponse(prospectA, prospectB,...
                        obj.human_response_options{:});
            end
            
            responseDidChooseB = response_data.didChooseB;
            reaction_time = response_data.reaction_time;
        end
        
        
        function obj = enterAgentResponse(obj, chosen_design, choseLater, reaction_time)
            % Call this function once we have a response from an agent
            
            % append to data
            obj.previous_designs = [obj.previous_designs; chosen_design];
            obj.all_responses = [obj.all_responses; choseLater];
            obj.all_reaction_times = [obj.all_reaction_times; reaction_time];
            % must be called AFTER we've appended to previous_designs and all_responses
            obj = obj.updateBeliefs();
            
            obj.export_current_point_estimates();
            % Store summary data
            obj = obj.updateThetaRecord();
            
            obj = obj.update_experiment_results();
            % For extra caution, save response data after every response
            obj.export_experiment_results();
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
        
        
        function end_of_trial_plotting(obj)
            switch obj.p.Results.plotting
                case{'full', 'demo'}
                    obj.common_plot_functions();
                    figure(1), clf
                    [thetaStruct] = obj.model.theta_to_struct(obj.theta);
                    obj.model.plotting(thetaStruct, obj.data_table);
            end
        end
        
        
        function expt_options = setExperimentOptions(obj, p)
            isAgentHuman = @() strcmp(p.Results.agent,'real_agent');
            noOptionsProvided = @() numel(fields(p.Results.expt_options))==0;
            if isAgentHuman()
                if noOptionsProvided()
                    % ask for experiment options with a gui
                    [expt_options] = getHumanExperimentOptions();
                else
                    % use provided experiment options
                    expt_options = p.Results.expt_options;
                end
            else
                % default options for simulated participants
                expt_options.participantID = 'simulatedParticipant';
                expt_options.trials = p.Results.trials;
            end
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
                % Design optimisation ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                % THIS IS A VERY SPECIFIC WAY OF CREATING A FUNCTION HANDLE
                % TO A CLASS METHOD, WHEN THAT CLASS IS NOT A HANDLE CLASS,
                % IE A VALUE CLASS.
                log_predictive_y = @(theta,designs) obj.model.log_predictive_y(theta,designs);
                [chosen_design, design_utilties] = discrete_smc_search_binary_output(...
                    log_predictive_y, designs_allowed, obj.theta);
                % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                obj.plot_design_utilities(design_utilties)
            end
        end
        
        
        function obj = update_experiment_results(obj)
            % gather experiment information (designs, responses, reaction
            % times) into a Table
            
            assert(~isempty(obj.previous_designs), 'No previous designs')
            
            temp_data_table = array2table(obj.previous_designs,...
                'VariableNames', obj.model.design_variables);
            % convert R_A_over_R_B to R_A
            temp_data_table.R_A = temp_data_table.R_A_over_R_B .* temp_data_table.R_B;
            temp_data_table.R_A_over_R_B = [];
            % append responses column
            temp_data_table.R = obj.all_responses;
            % append reaction times
            temp_data_table.reaction_time = obj.all_reaction_times;
  
            obj.data_table = temp_data_table;
        end
        
        
        function export_experiment_results(obj)
            % incude model class name in the filename. Helps to keep things clear when
            % we are running multiple types of experiments on a single participant
            Model_class_name = class(obj.model);
            filename = [Model_class_name '-' obj.expt_options.participantID '.txt'];
            full_save_path_and_filename = fullfile(obj.p.Results.save_path, filename);
            exportData(full_save_path_and_filename, obj.data_table)
        end
        
        function export_current_point_estimates(obj)            
            % create table of median param estimates of free params
            free_param_names = obj.model.params(~obj.model.is_theta_fixed);
            pointEstimateTable = array2table(median(obj.theta),...
                'VariableNames',free_param_names);
            
            % Build filename
            Model_class_name = class(obj.model);
            filename = [Model_class_name...
                '-' obj.expt_options.participantID '-params' '.txt'];
            full_save_path_and_filename = fullfile(obj.p.Results.save_path, 'theta', filename);
            exportData(full_save_path_and_filename, pointEstimateTable)
        end
        
        % PLOTTING FUNCTIONS ==============================================
        
        
        function common_plot_functions(obj)
            % MODEL-INDEPENDENT PLOT: summary stats of theta over trials
            figure(6)
            obj.model.record_array.plot_summary()
            
            % corner plot of parameters
            figure (7)
            
            % var variable names of free params
            is_theta_fixed = obj.model.is_theta_fixed();
            allvariableNames = obj.model.params;
            variableNames = allvariableNames(~is_theta_fixed);
            
            samples = obj.theta;
            tri = mcmc.TriPlotSamples(samples,...
                variableNames,...
                'figSize', 15,...
                'pointEstimateType', 'median');
        end
        
        
        function end_of_experiment_plotting(obj)
            if strcmp(obj.p.Results.plotting,'end')
                [thetaStruct] = obj.model.theta_to_struct(obj.theta);
                obj.model.plotting(thetaStruct, obj.data_table);
                obj.common_plot_functions();
            end
        end
        
        
        function plot_design_utilities(obj, design_utilties)
            if strcmp(obj.p.Results.plotting, 'full')
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
