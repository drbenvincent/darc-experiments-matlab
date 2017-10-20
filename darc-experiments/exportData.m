function exportData(full_save_path_and_filename, data_table)
% Export raw response data to a tab-delimited text file

assert(ischar(full_save_path_and_filename),'full_save_path_and_filename should be a string')

assert(istable(data_table),'data_table should be of type Table')

% save
% data_foldername = fullfile(savePath(),'data');
% %ensureFolderExists( fullfile(cd, data_foldername) )
% ensureFolderExists( data_foldername )
% saveas = fullfile(data_foldername,[participantID '.txt']);

data_foldername = fileparts(full_save_path_and_filename);
ensureFolderExists( data_foldername )

writetable(data_table, full_save_path_and_filename, 'Delimiter', 'tab')

%fprintf('\nSAVED AS: %s\n',full_save_path_and_filename)
end