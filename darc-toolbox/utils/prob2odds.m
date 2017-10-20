function odds = prob2odds(p)
% convert probability of recieving an award, to odds of recieving
odds = p./(1-p);
return
