function odds_against = prob2oddsagainst(p)
% convert probability of recieving an award, to odds against recieving
odds_against = (1-p)./p;
return
