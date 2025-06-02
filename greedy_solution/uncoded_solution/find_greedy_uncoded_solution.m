function [broadcast_table, satisfied] = find_greedy_uncoded_solution(ACS, ...
    KHS, enable_essentiality)

% check essentiality flag
if (nargin < 3)
    enable_essentiality = false;
end

% calculate PKS matrix
PKS = calculate_PKS(ACS, KHS);

% create empty SI matrix
SI = create_SI(ACS);

% create empty broadcast table
broadcast_table = create_broadcast_table();

% create keys vector
keys = 1 : get_num_keys(KHS);

% remove useless keys
keys = remove_useless_keys(PKS, keys);

% send essential keys if feature is enabled
if (enable_essentiality)
    % send uncoded essential keys
    [SI, broadcast_table] = send_uncoded_essential_keys(KHS, PKS, SI, keys, ...
        broadcast_table);
end

% remove exhausted keys
keys = remove_uncoded_exhausted_keys(KHS, PKS, SI, keys);

% begin broadcasting objects with keys from key list
% while key list is not empty and users are not yet satisfied, find key and
% object with maximum uncoded utility and send it
while (~isempty(keys) && ~isequal(ACS, SI))

    % send object of key with maximum uncoded utility
    [SI, broadcast_table] = send_max_uncoded_utility(KHS, PKS, SI, keys, ...
        broadcast_table);

    % remove exhausted keys
    keys = remove_uncoded_exhausted_keys(KHS, PKS, SI, keys);
    
end

% send remaining objects with personal keys
[SI, broadcast_table] = send_objects_private_keys(ACS, SI, broadcast_table);

% set satisfied flag
satisfied = isequal(ACS, SI);

end
