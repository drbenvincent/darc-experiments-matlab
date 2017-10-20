function [choseB, reaction_time] = presentQuestionGUI(question_posed, aText, bText)


% options for GUI
window_title = '';
set(0,'DefaultUicontrolFontSize',30)
options.FontSize = 10;
options.Interpreter = 'none';
options.Default = [];

% randomise the left/right position of option A and B
if rand<0.5
	question_start_time = tic; % start timer to record reaction time
	y = questdlg(question_posed,...
		window_title,...
		aText, bText,...
		options);
else
	question_start_time = tic; % start timer to record reaction time
	y = questdlg(question_posed,...
		window_title,...
		bText, aText,...
		options);
end

% return reaction time
reaction_time = toc(question_start_time);

% return response chosen, taking into account the randomised left/right ordering
switch y
case{aText}
		choseB = 0;
	case{bText}
		choseB = 1;
	otherwise
		error('Failed to match output of questdlg to a response')
end

end
