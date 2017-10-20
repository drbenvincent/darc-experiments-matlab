function bool = isstruct_or_table(x)
bool = or(isstruct(x),istable(x));
end