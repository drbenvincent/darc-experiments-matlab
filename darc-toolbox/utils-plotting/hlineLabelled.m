function handles=hlineLabelled(targetAxis, yvalue, textStr, varargin)
% [h] = hlineLabelled(gcf, 1, 'mylabel', 'lineprops', {'Color', 'r'}, 'textprops', {'HorizontalAlignment','right'})

p = inputParser;
p.FunctionName = mfilename;
p.addRequired('targetAxis',@isgraphics)
p.addRequired('yvalue',@isnumeric);
p.addRequired('textStr',@isstr);
p.addParameter('lineprops',{}, @iscellstr);
p.addParameter('textprops',{}, @iscellstr);
p.parse(targetAxis, yvalue, textStr, varargin{:});


%% Line
xlim = get(targetAxis,'Xlim');
handles.line = line(xlim, [yvalue yvalue]); % horizontal line

% Apply default formatting
line_defaults = {'Color', 'k',...
	'LineStyle', '-',...
	'LineWidth', 0.5};
set(handles.line,line_defaults{:});

% Overwrite with any supplied formatting
if ~isempty(p.Results.lineprops)
	set(handles.line, p.Results.lineprops{:});
end

% send the line to the back
uistack(handles.line,'bottom');


%% Text label
text_y_offset = 0.2;
xpos = xlim(2);
% defaults
handles.text = text(xpos, yvalue+text_y_offset, textStr,...
	'HorizontalAlignment','right',...
	'VerticalAlignment', 'bottom' );

% Apply formatting provided
if ~isempty(p.Results.textprops)
	set(handles.text, p.Results.textprops{:});
end
end