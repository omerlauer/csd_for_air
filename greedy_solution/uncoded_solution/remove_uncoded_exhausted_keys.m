function keys = remove_uncoded_exhausted_keys(KHS, PKS, SI, keys)

% create empty list of flags of satisfied cliques
is_satisfied_list = false(size(keys));

% go over all keys and fill the list of flags
for key_index = 1 : numel(keys)
    is_satisfied_list(key_index) = is_clique_satisfied(KHS, PKS, SI, ...
        keys(key_index));
end

% remove exhausted keys using list of flags
keys(is_satisfied_list) = [];

end
