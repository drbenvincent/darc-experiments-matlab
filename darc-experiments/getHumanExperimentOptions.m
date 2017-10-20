function [expt_options] = getHumanExperimentOptions()

prompt={'Participant initials', 'Trials'};
default = {'TEST', '40'};
answer = inputdlg(prompt, 'Enter information', 1, default);
% deal with max number of trials
expt_options.trials =  str2double(answer{2});
% add date/time stamp to partipant ID
datestamp = char( datetime('now', 'Format','yyyyMMMdd-HH.mm') );
expt_options.participantID = sprintf('%s-%s',answer{1},datestamp);
end
