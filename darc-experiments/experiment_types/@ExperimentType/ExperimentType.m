classdef (Abstract) ExperimentType
	
	
	properties
		R_A_over_R_B
		D_A
		P_A
		R_B
		D_B
		P_B
		
		% handle to a plotting function to visualise time/prob/time+prob designs
		plotFuncHandle
		
		design_variables
		
		% Design override function.  Has no arguments and generates the
		% next design.  If empty then the optimization code for the design
		% is called instead
		design_override_function
		
		heuristic_order % This is the order in which heuristic will be invoked until enough designs are set
		heuristic_strategy % This dictates a strategy in generate_designs
		heuristic_rate % Proportion of times do use the heuristic, doing direct BED optimization
		% otherwise.  E.g. if equal to 2/3 then heuristic
		% used 2/3 of the time.
		n_design_opt % Number of distinct designs that will be considered by the design optimization
		% Only effects subjective_value_spreading heuristic
	end
	
	methods
		function obj = ExperimentType(varargin)
			obj.design_variables = {'R_A_over_R_B','D_A','P_A','R_B','D_B','P_B'};
		end
		
		% Declarations
		b_fixed = is_design_variable_fixed(obj)
		designs = packDesigns(obj,design_struct);
		unpackDesigns(obj, designs);
		
	end
end
