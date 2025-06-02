function [utility, object] = get_key_max_uncoded_utility(KHS, PKS, SI, key)

% get objects of key
key_objects = get_key_objects(PKS, key);

% calculate utilities for all objects of key
utilities = get_key_uncoded_utilities(KHS, SI, key, key_objects);

% find maximum utility and its index
[utility, utility_index] = max(utilities);

% get object associated with maximum utility
object = key_objects(utility_index);

end
