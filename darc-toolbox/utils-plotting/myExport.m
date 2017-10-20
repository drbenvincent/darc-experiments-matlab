function myExport(saveName, varargin)
% a wrapper for `export_fig`

p = inputParser;
p.FunctionName = mfilename;
p.addRequired('saveName',@isstr);
p.addParameter('prefix','',@isstr);
p.addParameter('suffix','',@isstr);
p.addParameter('saveFolder','',@isstr);
p.addParameter('formats',{'png'},@iscellstr);
p.addParameter('delimiter','-',@isstr);
p.parse(saveName, varargin{:});

%% construct `save_path_and_filename`
components = {p.Results.prefix, p.Results.saveName, p.Results.suffix};
% remove empty components
components = components(~cellfun('isempty',components));
saveFileName = strjoin(components, p.Results.delimiter);
save_path_and_filename = fullfile('figs', p.Results.saveFolder, saveFileName);

ensureFolderExists(fullfile('figs', p.Results.saveFolder))

%% do the exporting

% set background as white
set(gcf,'Color','w');

% TODO: export in all formats defined in 'formats'

% % .pdf
% print('-opengl','-dpdf','-r2400', [save_path_and_filename '.pdf'])
% .png
export_fig(saveAs, '-png', '-m4')
% .fig
%hgsave(save_path_and_filename)

%% finish up
fprintf('Figure saved: %s\n\n', save_path_and_filename);

return
