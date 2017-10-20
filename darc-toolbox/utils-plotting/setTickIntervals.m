function setTickIntervals(XTickInterval, YTickInterval)
%setTickIntervals Set the major tick intervals on axes of 2D plot. This is
% handy as you do not need to concern yourself with entire ranges for the
% tick limits as you would if you did the traditional approach of:
%     set(gca,'XTick',[-3:0.25:3])
%
% Examples
% setTickIntervals(1, 0.5)
% setTickIntervals(1, [])

h = gca;

if ~isempty(XTickInterval)
	h.XTick = [ceil(min(h.XTick)):XTickInterval:ceil(max(h.XTick))];
end

if ~isempty(YTickInterval)
	h.YTick = [ceil(min(h.YTick)):YTickInterval:ceil(max(h.YTick))];
end