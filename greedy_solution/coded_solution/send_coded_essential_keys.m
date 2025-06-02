function [broadcast_table, adjacency_matrices, matching_size_vector, ...
    broadcasts_per_key] = send_coded_essential_keys(ACS, KHS, PKS, ...
    broadcast_table, adjacency_matrices, matching_size_vector, keys, ...
    broadcasts_per_key)

% set notes for coded broadcast of essential key
notes = "coded essential key";

% go over each key, get essentialities and send coded broadcasts
for key = keys
    % get key essentialities
    key_essentialities = get_key_essentialities(KHS, PKS, key);

    % calculate number of required broadcasts
    num_broadcasts = max(cellfun(@numel, key_essentialities));

    % get key users
    key_users = get_key_users(KHS, key);

    % send coded essential broadcasts
    for broadcast = 1 : num_broadcasts
        
        % set utility variable
        utility = 0;

        for user = key_users
            % check if adding broadcast increases matching
            if (is_new_matching(ACS, PKS, user, adjacency_matrices{user}, ...
                    key, matching_size_vector(user)) == 1)
                % add key as right node
                adjacency_matrices{user} = add_key_node(ACS, PKS, user, ...
                    adjacency_matrices{user}, key, matching_size_vector(user));

                % update matchings size
                matching_size_vector(user) = matching_size_vector(user) + 1;

                % increase utility
                utility = utility + 1;
            end
        end
        
        % add broadcast to broadcast table
        broadcast_table = send_coded_broadcast(PKS, key, utility, notes, ...
            broadcast_table);

        % increase number of key broadcasts
        broadcasts_per_key(key) = broadcasts_per_key(key) + 1;
    end

end

end
