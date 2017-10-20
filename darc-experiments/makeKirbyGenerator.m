function f = makeKirbyGenerator()
% This function returns a function which will spit out the next design of
% the 27-item Kirby experiment.
%
% Once the number of trials are up, it will return an empty value, []
%
% Example usage:
%  KirbyDesignGenerator = makeKirbyGenerator();
%  design = KirbyDesignGenerator()
%  design = KirbyDesignGenerator()
%  ...


trial = 1;
% define the questions in the 27-item Kirby questionnaire
R_A = [80;34;25;11;49;41;34;31;19;22;55;28;47;14;54;69;54;25;27;40;54;15;33;24;78;67;20];
D_A = [0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0];
R_B = [85;50;60;30;60;75;35;85;25;25;75;30;50;25;80;85;55;30;50;55;60;35;80;35;80;75;55];
D_B = [157;30;14;7;89;20;186;7;53;136;61;179;160;19;30;91;117;80;21;62;111;13;14;29;162;119;7];
P_A = ones(27,1);
P_B = ones(27,1);
% convert to our R_A_over_R_B
R_A_over_R_B = R_A ./ R_B;
% package up
DESIGNS = [R_A_over_R_B D_A P_A R_B D_B P_B]; % TODO: DOES ORDER MATTER? IF SO, IS THIS CORRECT?


	function design = designGetter(~,~)
		if trial>size(DESIGNS,1)
			design=[];
		else
			design = DESIGNS(trial,:);
			trial = trial + 1;
		end
	end

f = @designGetter;

end
