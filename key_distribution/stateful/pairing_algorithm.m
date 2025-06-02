function KHS = pairing_algorithm(ACS, budget, enable_coding)

% check enable coding flag
if (nargin < 3)
    enable_coding = false;
end

% get number of users
num_users = get_num_users(ACS);

% create covered edges matrix, NaN - cannot be covered, 0 - uncovered, 1
% - covered once, 2 - covered twice, etc
covered_edges = ACS - 1;
covered_edges(covered_edges == -1) = NaN;

% create empty user and object key vectors
key_users = {};
key_objects = {};

% in a loop, assign key to pair or pairs with best metric, until budget is
% exhausted or terminated by flag (no new keys found)
stop_flag = false;

while (budget >= 2 && ~stop_flag)
    
    % find single pair with best metric
    [pair_users, pair_metric] = find_best_pair(ACS, covered_edges, ...
        key_users, enable_coding);
    
    % if is zero, stop the loop by setting the stop flag, else add pairs as key
    if (pair_metric == 0)
        stop_flag = true;
    else
        % add users and objects as new key
        key_users{end + 1} = pair_users;
        key_objects{end + 1} = get_shared_objects(ACS, pair_users);

        % update covered edges matrix
        covered_edges(key_users{end}, key_objects{end}) = ...
            covered_edges(key_users{end}, key_objects{end}) + 1;

        % update budget
        budget = budget - 2;
    end
    
end

% initialize empty KHS matrix
KHS = zeros(numel(key_users), num_users);

% populate KHS
for key = 1 : numel(key_users)
    KHS(key, key_users{key}) = 1;
end

end
