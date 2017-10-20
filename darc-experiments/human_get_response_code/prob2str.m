function probString = prob2str(p)
% immediate?
if p==1
	probString = '';
	return
else
    probString = [' with a ' sprintf('%g',p*100) '% chance'];
end
end
