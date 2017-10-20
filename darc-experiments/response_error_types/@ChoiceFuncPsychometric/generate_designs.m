function designs_allowed = generate_designs(obj, previous_designs, responses, thetas)
%generate_designs
%
% Create a matrix of possible designs. These will be considered by our
% optimization procedure.
%
% Inputs
%
% Outputs
% designs_allowed: A matrix of designs. Each column is one component of the
%				design space. Each row is one design.
%
% Tom Rainforth 01/10/16

%% Setup options and variables

free_design_fields = obj.design_variables(~obj.is_design_variable_fixed());
free_design_vals = struct;
for n=1:numel(free_design_fields)
    free_design_vals.(free_design_fields{n}) = obj.(free_design_fields{n});
end

fixed_design_fields = obj.design_variables(obj.is_design_variable_fixed());
fixed_design_vals = struct;
for n=1:numel(fixed_design_fields)
    fixed_design_vals.(fixed_design_fields{n}) = obj.(fixed_design_fields{n});
end

% Load previous designs into the workspace
obj.unpackDesigns(previous_designs);

n_d = size(previous_designs,1);
mod_h = mod(n_d,1/obj.heuristic_rate);
b_use_heuristic = ~isnan(mod_h) && mod_h<0.9999; % Numerical stability
if b_use_heuristic
    strategy = obj.heuristic_strategy;
else
    strategy = 'no_heuristic';
end

%% Read in designs

if strcmpi(strategy,'random_no_replacement')
    % This is the old strategy that uses the heuristic order and then
    % randomly chooses all but the number.  For this not all designs are
    % evaluated
    
    free_params = obj.params(~obj.is_theta_fixed());
    free_params = setdiff(free_params,{'alpha','epsilon'}); % Ignore alpha and epsilon
    n_design_allowed = numel(free_params);
    n_designs_to_set = numel(free_design_fields)-n_design_allowed;
    
    heuristic_counter = 1;
    
    for n=1:numel(obj.heuristic_order)
        if heuristic_counter > n_designs_to_set
            break
        end
        if any(strcmp(obj.heuristic_order{n},free_design_fields))
            eval(['heuristic_value = random_no_replacement(obj,' obj.heuristic_order{n} ',''' obj.heuristic_order{n} ''');']);
            free_design_vals = rmfield(free_design_vals,obj.heuristic_order{n});
            fixed_design_vals.(obj.heuristic_order{n}) = heuristic_value;
            heuristic_counter = heuristic_counter+1;
        end
    end
    designs_allowed = gen_designs(obj,free_design_vals,fixed_design_vals);
else
    % Other strategies start by laying out all the designs
    
    % First generate all the possible designs
    designs_allowed = gen_designs(obj,free_design_vals,fixed_design_vals);
end

%% Eliminate designs already tried of with no chance of being helpful

% Eliminate designs already tried
if ~isempty(previous_designs)
    designs_allowed = setdiff(designs_allowed,previous_designs,'rows');
end

% Eliminate designs whose response is effectively known using the point
% estimate
% Now make a point estimate for theta and use it to calculate the
% sooner and later subjective values for all of these possible
% designs
theta = point_estimate_theta(obj,thetas,'mean');
alpha = [];
obj.unpackTheta(theta);
[VA, VB] = obj.subjective_values(theta,designs_allowed);
Vsum = VA+VB;
Vdiff = VB-VA;

% Eliminate Vsum points where the response is effectively certain
% such that these are clearly poor designs
p_raw = normcdf(Vdiff/alpha); % Prob response ignoring epsilon
b_extreme = p_raw<0.005 | p_raw>0.995;
n_not_extreme = sum(~b_extreme);
if n_not_extreme<10
    % Cop out as we don't have a reasonable number of sensible
    % designs left, take the ten smallest differences (with some
    % noise to split ties randomly)
    [~,is] = sort(abs(Vdiff)+(1e-10)*rand(size(Vdiff)));
    n_take = min(10,numel(is));
    designs_allowed = designs_allowed(is(1:n_take),:);
    return
end
Vsum = Vsum(~b_extreme);
p_raw = p_raw(~b_extreme);
designs_allowed = designs_allowed(~b_extreme,:);

%% Do further design elimination heuristics

if any(strcmpi(strategy,{'no_heuristic','random_no_replacement'}))
    
    % For no_heuristic heuristic and random_no_replacement we are now done
    
elseif strcmpi(strategy,'subjective_value_spreading')
    
    
    if size(previous_designs,1)<4 % Old was 2
        % Not enough previous designs.  Let the experimental design
        % method do its magic
        return
    end
    
    % Use a kernel density estimator to get the distribution of
    % Vsum and evaluate at the Vsum points.
    [VSp,VLp] = obj.subjective_values(theta,previous_designs);
    Vpsum = VSp+VLp;
    Vpdiff = VLp-VSp;
    p_raw_p = normcdf(Vpdiff/alpha);
    b_p_extreme = p_raw_p<0.005 | p_raw_p>0.995;
    if sum(~b_p_extreme) > 3 % Old was 1
        % We don't care about even spacing with what turned out to
        % be useless questions.  We want an even spacing of the
        % pertinent ones.  Therefore we only look at distance to
        % helpful questions for choosing were to go.
        Vpsum = Vpsum(~b_p_extreme);
        Vpdiff = Vpdiff(~b_p_extreme);
    else
        % There are 3 or less useful questions remain so again don't
        % care about even space.  Let the optimizer do its magic
        return
    end
    % Find the point in Vsum space that is further from previous
    % values using
    hard_coded_scale = 0.1;
    Vden = kernel_dist(Vsum,Vpsum,hard_coded_scale*(max(Vsum)-min(Vsum)));
    [~,imin] = min(Vden);
    
    % Now only look at points that are close to this in Vsum space.
    % What we will do is to chop up the p_raw space (i.e. bin the
    % output probabilities, ignoring epsilon) and then choose the
    % closest sample to Vsum(imin) in each bin.  This gives a good
    % spread of probabilities while maintaining points close the target
    % Vsum.
    VsumDiff = Vsum-Vsum(imin);
    % Partitions are uneven as more likely to want to be near the
    % middle, for now will be even though
    bin_pos = 0:(1/obj.n_design_opt):1;
    %bin_pos = betacdf(0:(1/obj.n_design_opt):1,0.5,0.5); % Alternative
    %for uneven
    [~,i_bin] = histc(p_raw,bin_pos);
    % Sort first by bin then the absolute difference to target point.
    [i_p,i_s] = sortrows([i_bin,abs(VsumDiff)]);
    % Take the first of each type
    i_take = [1;1+find(diff(i_p(:,1))~=0)];
    prob_diffs_take = i_p(i_take,2)/(max(Vsum)-min(Vsum));
    % We want to eliminate any differences that are too high without
    % removing all of them
    hard_closeness_coded_threshold = 0.4/sqrt(size(previous_designs,1));
    b_too_far = prob_diffs_take>hard_closeness_coded_threshold;
    i_take = i_take(~b_too_far);
    designs_allowed = designs_allowed(i_s(i_take),:);
    
    % To see whats going on set below to true
    b_debug_plot = false;
    
    if b_debug_plot && size(previous_designs,1)>2 && size(previous_designs,1)>5 && mod(size(previous_designs,1),5)==0
        % First lets look at Vsum vs p_raw for the candidates (blue),
        % previous designs (red), and designes selected to be allowed
        % (green).
        figure;
        plot(VA+VB,normcdf((VB-VA)/alpha),'x');
        hold on;
        plot([Vsum(imin),Vsum(imin)],[0,1],'--g','LineWidth',2);
        plot(Vpsum,normcdf(Vpdiff/alpha),'rx','MarkerSize',6,'LineWidth',4);
        [VSdebug,VLdebug] = obj.subjective_values(theta,designs_allowed);
        plot(VSdebug+VLdebug,normcdf((VLdebug-VSdebug)/alpha),'gx','MarkerSize',6,'LineWidth',4);
        % Now lets look at the density of previously chosen Vrank's
        % along with their positions and the new allowed positions.
        figure;
        plot(Vsum,Vden,'x');
        hold on;
        plot(Vpsum,zeros(size(Vpsum)),'rx','MarkerSize',6,'LineWidth',4);
        plot(VSdebug+VLdebug,zeros(size(VSdebug)),'gx','MarkerSize',6,'LineWidth',4);
        % Pause to let us look
        keyboard;
    end
    
end

end

function designs_allowed = gen_designs(obj,free_design_vals,fixed_design_vals)

free_design_fields = fields(free_design_vals);
% Generates variables in this file for the previous design variables

design_vars = fixed_design_vals;
for m=1:numel(free_design_fields)
    design_vars.(free_design_fields{m}) = free_design_vals.(free_design_fields{m});
end

nd_grid_string = '[';
for m=1:numel(obj.design_variables)
    nd_grid_string = [nd_grid_string, obj.design_variables{m} ','];
end
nd_grid_string = [nd_grid_string(1:end-1) '] = ndgrid('];
for m=1:numel(obj.design_variables)
    nd_grid_string = [nd_grid_string, 'design_vars.' obj.design_variables{m} ','];
end
nd_grid_string = [nd_grid_string(1:end-1) ');'];
eval(nd_grid_string);

designs_allowed = [];
for m=1:numel(fields(design_vars))
    eval(['designs_allowed = [designs_allowed,' obj.design_variables{m} '(:)];']);
end

end

function v = random_no_replacement(obj,previous_vals,var_name)
allowed_vals = obj.(var_name);
left_vals = setdiff(allowed_vals,previous_vals);
if isempty(left_vals)
    [~,i_int] = unique(previous_vals);
    i_left = setdiff(1:numel(previous_vals),i_int);
    twice_vals = previous_vals(i_left);
    if isempty(twice_vals)
        left_vals = previous_vals;
    else
        v = random_no_replacement(obj,twice_vals,var_name);
        return
    end
end
v = datasample(left_vals,1);

end

function d = kernel_dist(V1,V2,scale)

d = mean(exp(-(bsxfun(@minus,V1,V2').^2)/scale^2),2);

end