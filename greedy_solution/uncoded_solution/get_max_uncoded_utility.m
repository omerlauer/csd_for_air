function [utility, object, key] = get_max_uncoded_utility(KHS, PKS, SI, keys)

% get max uncoded utility of all keys
[utilities, objects] = get_keys_max_uncoded_utilities(KHS, PKS, SI, keys);

% find max utility and its corresponding key and object
[utility, utility_index] = max(utilities);
object = objects(utility_index);
key = keys(utility_index);

end
