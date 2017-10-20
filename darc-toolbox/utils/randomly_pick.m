function y = randomly_pick(x)
% randomly pick one value from list provided
y = x( randi([1 numel(x)]) );
return
