function [figure_handle, h_row_labels, h_col_labels, h_main] = make_subplot_grid(row_labels, col_labels)
% [figure_handle,h_row_labels, h_col_labels, h_main] = make_subplot_grid({{'time discounting','(with magnitude effect)'}, {'probability', 'discounting'}, {'time and probabilty','discounting'}}, {'',''});

rows = numel(row_labels);
cols = numel(col_labels);

figure_handle = figure('Units', 'normalized');
figure_handle.Color = 'w';

b = 0.05; % border size
%siz = (1-0.1)/max([rows, cols])  % size of each subplot

main_edge_size = 0.075;

% set up row labels
for row = 1:rows
    width = b;
    height = (1-b)/rows;
    left = 0;
    bottom = 1-b-(row)*height; % 0 + (row-1)*height;
    h_row_labels(row) = subplot('position', [left bottom width height]);
    axis off
    
    t = text(0.5, 0.5,...
        row_labels{row},...
        'HorizontalAlignment', 'center',...
        'VerticalAlignment', 'middle',...
        'FontWeight', 'bold',...
        'Rotation', 90);
    
    t.FontSize = t.FontSize + 2;
end

% set up column labels
for col = 1:cols
    width = (1-b)/cols;
    height = b;
    left = b + (col-1)*width;
    bottom = 1-b;
    h_col_labels(row) = subplot('position', [left bottom width height]);
    axis off
    
    t = text(0.5, 0.5,...
        col_labels{col},...
        'HorizontalAlignment', 'center',...
        'VerticalAlignment', 'middle',...
        'FontWeight', 'bold');
end

% set up main row/col subplots
width = ((1-b)/cols);
height = ((1-b)/rows);
for row = 1:rows
    for col  = 1:cols
        width_adjusted = ((1-b)/cols) - 2*main_edge_size;
        height_adjusted = ((1-b)/rows) - 2*main_edge_size;
        left = b + (col-1)*width + main_edge_size;
        %bottom = 0 + (row-1)*height + main_edge_size;
        bottom = 1-b-(row)*height + main_edge_size;
        
        h_main(row,col) = subplot('position', [left bottom width_adjusted height_adjusted],...
            'TickDir', 'out');
        
        xlabel('this is the x-axis')
        ylabel('this is the y-axis')
    end
end

end