function KHS = variable_key_degree(ACS, alpha_vec, budget, stream)

% if no stream is given, set stream to global stream
if (nargin < 4)
    stream = RandStream.getGlobalStream;
end

% create empty KHS
KHS = [];

% if ACS column weights are 1 or less, return empty KHS
if (all(sum(ACS, 1) <= 1))
    return
end

% get ACS dimensions
[num_users, num_objects] = size(ACS);

% set possible key degrees
possible_degrees = 1 : numel(alpha_vec);

% create keys while budget is bigger than zero
while (budget > 0)
    % pick random column (object)
    random_object = randi(stream, num_objects);
    
    % choose random number of users sharing random object (if possible)
    sharing_users = find(ACS(:, random_object) == 1);
    key_degree = randsample(stream, possible_degrees, 1, true, alpha_vec);
    random_users = randsample(stream, sharing_users, ...
        min([key_degree, numel(sharing_users)]));
    
    % create new KHS row if users were selected
    if (~isempty(random_users))
        % pick fewer users if budget does not allow it
        random_users = randsample(stream, random_users, ...
            min(numel(random_users), budget));

        % decrease budget
        budget = budget - numel(random_users);
        
        % add KHS row
        KHS_row = zeros(1, num_users);
        KHS_row(random_users) = 1;
        KHS = [KHS; KHS_row];
    end
end

% remove identical rows, no need to sort rows
KHS = unique(KHS, 'rows', 'stable');

% remove private keys
KHS(sum(KHS, 2) == 1, :) = [];

end
