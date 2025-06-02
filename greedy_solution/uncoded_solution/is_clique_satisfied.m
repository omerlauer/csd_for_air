function satisfied = is_clique_satisfied(KHS, PKS, SI, key)

% get clique SI
clique_SI = get_clique_SI(KHS, PKS, SI, key);

% check if clique SI is all ones
satisfied = all(clique_SI, 'all');

end
