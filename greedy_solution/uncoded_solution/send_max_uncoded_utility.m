function [SI, broadcast_table] = send_max_uncoded_utility(KHS, PKS, SI, ...
    keys, broadcast_table)

% get maximum uncoded utility with its object and key
[utility, object, key] = get_max_uncoded_utility(KHS, PKS, SI, keys);

% get users of key with maximum utility
users = get_key_users(KHS, key);

% set parameters for uncoded broadcast
notes = "uncoded broadcast";

% send uncoded object with maximum uncoded utility
[SI, broadcast_table] = send_objects_to_users(SI, broadcast_table, users, ...
    object, key, utility, notes);

end
