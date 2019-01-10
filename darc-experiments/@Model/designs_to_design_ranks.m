function ranks = designs_to_design_ranks(obj,designs)

if isempty(designs)
    ranks = designs;
    return
end

n_names = numel(obj.design_variables);
ranks = NaN(size(designs));

for n=1:n_names
    n_this = numel(obj.(obj.design_variables{n}));
    if n_this==1
        ranks(:,n)=0.5;
    else
        ranks(:,n) = interp1((obj.(obj.design_variables{n}))',(0:(n_this-1))'/(n_this-1),designs(:,n));
    end
end

end