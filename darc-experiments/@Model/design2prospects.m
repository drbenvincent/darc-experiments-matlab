function [prospectA, prospectB] = design2prospects(obj, designs)

% Adds all the required variables to the workspace
obj.unpackDesigns(designs);
% packages design into prospects
prospectA = struct('reward', R_A, 'delay', D_A, 'prob', P_A);
prospectB = struct('reward', R_B, 'delay', D_B, 'prob', P_B);

end