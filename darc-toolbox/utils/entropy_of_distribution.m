function E = entropy_of_distribution(samples, grid)
% bin the distribution of samples
N = histcounts(samples, grid);
% normalise 
P = N./sum(N);
% entropy, in bits
E = -sum(P.*log2(P),'omitnan');
end