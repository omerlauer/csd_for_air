function [users, objects] = get_demand(ACS, SI)

% calculate demand matrix as difference between ACS and SI
demand_matrix = ACS - SI;

% get users who demand objects
users = find(any(demand_matrix, 2).');

% create objects vector for demand
objects = cell(size(users));

% for each user get objects which she demands
for user_index = 1 : numel(users)
    objects{user_index} = find(demand_matrix(users(user_index), :) == 1);
end

end
