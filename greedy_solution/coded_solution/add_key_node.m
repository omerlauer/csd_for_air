function adjacency_matrix = add_key_node(ACS, PKS, user, adjacency_matrix, ...
    key, matching_size)

% get user objects
user_objects = get_user_objects(ACS, user);

% update adjacency matrix
adjacency_matrix(:, matching_size + 1) = PKS(key, user_objects).';

end
