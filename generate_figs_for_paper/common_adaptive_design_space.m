function [bvec, D_B, R_A_over_R_B] = common_adaptive_design_space()
bvec = 100;
D_B = default_D_B();
R_A_over_R_B = (1:1:100-1) ./ 100;
end
