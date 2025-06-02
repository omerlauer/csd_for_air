function [broadcast_table, satisfied] = find_greedy_coded_solution(ACS, KHS, ...
    enable_essentiality)

% check essentiality flag
if (nargin < 3)
    enable_essentiality = false;
end

% calculate PKS matrix
PKS = calculate_PKS(ACS, KHS);

% create user vector
users = 1 : get_num_users(ACS);

% create bipartite graph adjacency matrix for each user
adjacency_matrices = cell(size(users));
for user = users
    adjacency_matrices{user} = zeros(numel(get_user_objects(ACS, user)), ...
        numel(get_user_objects(ACS, user)));
end

% create vector of matchings size per user
matching_size_vector = zeros(size(users));

% create keys vector
keys = 1 : get_num_keys(KHS);

% create vector of number of broadcasts per key
broadcasts_per_key = zeros(size(keys));

% remove useless keys
keys = remove_useless_keys(PKS, keys);

% create empty broadcast table
broadcast_table = create_broadcast_table();

% send essential keys if feature is enabled
if (enable_essentiality)
    % send coded essential keys
    [broadcast_table, adjacency_matrices, matching_size_vector, ...
        broadcasts_per_key] = send_coded_essential_keys(ACS, KHS, PKS, ...
        broadcast_table, adjacency_matrices, matching_size_vector, ...
        keys, broadcasts_per_key);

    % remove exhausted keys
    keys(get_key_dim(PKS, keys) == broadcasts_per_key(keys)) = [];
end

% calculate users' total object demand
total_object_demand = sum(ACS, 2).';

% get key sizes
key_sizes = get_key_size(KHS, keys);

% sort keys according to key sizes
[key_sizes, sort_indices] = sort(key_sizes, 'descend');
keys = keys(sort_indices);

% broadcast while keys list is not empty and total demand does not equal user
% matching sizes
while (~isempty(keys) && ~isequal(total_object_demand, matching_size_vector))
    % create zero matrix for new matchings
    new_matchings = zeros(numel(keys), size(KHS, 2));

    % go over keys and users and check new matchings
    for key_index = 1 : numel(keys)
        for user = users
            if (KHS(keys(key_index), user) == 1)
                new_matchings(key_index, user) = is_new_matching(ACS, ...
                    PKS, user, adjacency_matrices{user}, keys(key_index), ...
                    matching_size_vector(user));
            end
        end
        % check if current key utility is bigger than possible utility of next
        % key, then break
        if ((key_index < numel(keys)) && ...
                (sum(new_matchings(key_index, :), 2) >= ...
                key_sizes(key_index + 1)))
            % cut new matching matrix up to tested key
            new_matchings((key_index + 1) : end, :) = [];
            break
        end
    end

    % count total number of new matchings per key
    matching_count = sum(new_matchings, 2);

    % get key with most matchings and add to user graphs
    [max_utility, most_matchings_key_index] = max(matching_count);
    if (max_utility > 0)
        for user = users
            if (new_matchings(most_matchings_key_index, user) == 1)
                adjacency_matrices{user} = add_key_node(ACS, PKS, user, ...
                    adjacency_matrices{user}, ...
                    keys(most_matchings_key_index), matching_size_vector(user));
            end
        end

        % add key to solution
        notes = "coded broadcast";
        broadcast_table = send_coded_broadcast(PKS, ...
            keys(most_matchings_key_index), max_utility, notes, ...
            broadcast_table);

        % update matchings size vector
        matching_size_vector = matching_size_vector + ...
            new_matchings(most_matchings_key_index, :);

        % increase number of key broadcasts of chosen key
        broadcasts_per_key(keys(most_matchings_key_index)) = ...
            broadcasts_per_key(keys(most_matchings_key_index)) + 1;

        % remove chosen key if exhausted
        if (get_key_dim(PKS, keys(most_matchings_key_index)) == ...
                broadcasts_per_key(keys(most_matchings_key_index)))
            keys(most_matchings_key_index) = [];
            key_sizes(most_matchings_key_index) = [];
            matching_count(most_matchings_key_index) = [];
        end

    end

    % remove keys which did not increase any matching
    exhausted_keys_indices = find(matching_count == 0);
    keys(exhausted_keys_indices) = [];
    key_sizes(exhausted_keys_indices) = [];

end

% send rest of object demand with private keys
for user = users
    for broadcast = (matching_size_vector(user) + 1) : total_object_demand(user)
        broadcast_table = send_coded_private_key(ACS, user, broadcast_table);
        matching_size_vector(user) = matching_size_vector(user) + 1;
    end
end

% set satisfied flag
satisfied = isequal(total_object_demand, matching_size_vector);

end
