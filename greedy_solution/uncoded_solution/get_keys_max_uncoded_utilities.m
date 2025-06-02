function [utilities, objects] = get_keys_max_uncoded_utilities(KHS, PKS, SI, ...
    keys)

% create vectors for max utilities objects per key
utilities = zeros(size(keys));
objects = zeros(size(keys));

% go over all keys and get max uncoded utility
for key_index = 1 : numel(keys)
    [utilities(key_index), objects(key_index)] = ...
        get_key_max_uncoded_utility(KHS, PKS, SI, keys(key_index));
end

end
