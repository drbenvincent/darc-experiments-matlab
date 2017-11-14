function exportData(full_save_path_and_filename, data_table)
% Export raw response data to a tab-delimited text file

assert(ischar(full_save_path_and_filename),'full_save_path_and_filename should be a string')

assert(istable(data_table),'data_table should be of type Table')

data_foldername = fileparts(full_save_path_and_filename);
ensureFolderExists( data_foldername )

% File format specific code here: comma separated .csv
full_save_path_and_filename = [full_save_path_and_filename '.csv'];
writetable(data_table, full_save_path_and_filename, 'Delimiter', ',')

end