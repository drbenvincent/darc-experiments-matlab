function dF = probHyperboloid(prospect, params)
%probHyperboloid Calculates the discount fraction
% The present subjective value of a prospect is given by the reward multiplied by the discount fraction. This function just calculates the discount fraction.
%
% dF = w(prob)
% w(prob) = 1 / (1+h.odds)^s, where odds = (1-prob)/prob

% calc w(prob)
odds_against = prob2oddsagainst(prospect.prob);

dF = bsxfun(@rdivide, 1,...
    bsxfun(@power, (1 + bsxfun(@times, odds_against, params.h)), params.s));

end
