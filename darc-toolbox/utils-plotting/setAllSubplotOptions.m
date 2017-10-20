function setAllSubplotOptions(figHandle, nameValuePairCellArray)
% for the figure (handle provided) loop over all axes contained in it, and
% apply the axis preferences provided in nameValuePairCellArray

children = figHandle.Children;
N = numel(children);

for n = 1:N
	set( figHandle.Children(n), nameValuePairCellArray{:})
end
return