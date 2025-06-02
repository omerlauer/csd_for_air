function [pair_users, pair_metric] = find_best_pair(ACS, covered_edges, ...
    key_users, enable_coding)

% convert key users to matrix
key_users = cell2mat(key_users.');

% calculate possible edges matrix, depending on coding enable flag, if disabled
% only uncovered edges considered
if (enable_coding)
    possible_edges = (covered_edges == 0) | (covered_edges == 1);
else
    possible_edges = (covered_edges == 0);
end

% find all possible users for pairing, only users with possible edges are taken
possible_users = find(sum(possible_edges, 2) > 0).';

% if there are less than two possible users, return
if (numel(possible_users) < 2)
    pair_users = {};
    pair_metric = 0;
    return
end

% create all possible pairs from possible users
possible_pairs = nchoosek(possible_users, 2);

% remove pairs who already have a key
if (~isempty(key_users))
    possible_pairs(ismember(possible_pairs, key_users, 'rows'), :) = [];
end

% create empty metric vector
metrics = zeros(1, size(possible_pairs, 1));

% create empty covered edges per pair vector
covered_edges_per_pair = zeros(1, size(possible_pairs, 1));

% calculate metric for each possible pair
for pair_index = 1 : size(possible_pairs, 1)
    % get current pair
    current_pair = possible_pairs(pair_index , :);

    % get shared object of current pair
    shared_objects = get_shared_objects(ACS, possible_pairs(pair_index , :));

    % get covered edges of pair
    covered_edges_per_pair(pair_index) = sum(covered_edges(current_pair, ...
        shared_objects), "all");

    % calculate metric of pair
    metrics(pair_index) = 2 * sum(sum(covered_edges(current_pair, ...
        shared_objects), 1) == 0);
    
    % if coding is enabled, modify metric
    if (enable_coding)
         metrics(pair_index) = metrics(pair_index) + sum(sum(covered_edges( ...
             current_pair, shared_objects), 1) == 1);
    end
end

% sort pairs by covered edges per pair
[~, sorted_indices] = sort(covered_edges_per_pair);
possible_pairs = possible_pairs(sorted_indices, :);
metrics = metrics(sorted_indices);

% find pair with maximum metric
[pair_metric, metric_index] = max(metrics);
pair_users = possible_pairs(metric_index, :);

end
