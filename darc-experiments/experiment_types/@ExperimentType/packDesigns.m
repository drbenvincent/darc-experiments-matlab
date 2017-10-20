function designs = packDesigns(obj,design_struct)
%designs = packDesigns(obj,design_struct)
%
% Converts a structure with design variable fields to an array with columns
% arranged in the correct order.  This ensures consistency with the unpack
% used elsewhere.  Fields that are fixed design variables in the model
% definition should not be included in the design_struct, but variables set
% to be fixed by generate designs (i.e. locally fixed) should.
%
% TR 01/10/16

b_fixed = obj.is_design_variable_fixed();
fields_to_set = fields(design_struct);
fields_to_set = fields_to_set(~b_fixed);

for n=1:numel(fields_to_set)
    if ~any(strcmp(obj.design_variables,fields_to_set{n}))
        error(['Field "' fields_to_set{n} '" in design_struct is not a free design variable in the model']);
    end
end

designs = NaN(size(design_struct.(fields_to_set{1}),1),numel(b_fixed));

for n=1:numel(obj.design_variables)
    if b_fixed(n)
       designs(:,n) = obj.(obj.design_variables{n});
    else
        designs(:,n) = design_struct.(obj.design_variables{n});
    end
end

end