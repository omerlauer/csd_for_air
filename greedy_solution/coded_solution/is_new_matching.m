function new_matching = is_new_matching(ACS, PKS, user, adjacency_matrix, ...
    key, matching_size)

% if graph is full, return 0
if (matching_size == numel(get_user_objects(ACS, user)))
    new_matching = 0;
    return
end

% add key as a new node to graph
adjacency_matrix = add_key_node(ACS, PKS, user, adjacency_matrix, key, ...
    matching_size);

% create sparse, non bipartite adjacency matrix for matching algorithm
adjacency_temp = sparse([zeros(size(adjacency_matrix, 1)), ...
    adjacency_matrix(:, 1 : matching_size + 1); ...
    adjacency_matrix(:, 1 : matching_size + 1).', zeros(matching_size + 1)]);

% find new maximum matching size
new_matching_size = sum(matching(adjacency_temp) > 0) / 2;

% check if new matching size is greater than current
if (new_matching_size > matching_size)
    new_matching = 1;
else
    new_matching = 0;
end

end
