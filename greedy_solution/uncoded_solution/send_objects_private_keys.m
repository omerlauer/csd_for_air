function [SI, broadcast_table] = send_objects_private_keys(ACS, SI, ...
    broadcast_table)

% get users and the objects they still demand
[users, objects] = get_demand(ACS, SI);

% set parameters for uncoded broadcast broadcast with private key
private_key = 0;
utility = 1;

% go over each user with demands
for user_index = 1 : numel(users)

    % get user
    user = users(user_index);
    
    % create notes of private key of user
    notes = "uncoded private key, user " + user;

    % send objects of user
    for object = objects{user_index}
        [SI, broadcast_table] = send_objects_to_users(SI, broadcast_table, ...
            user, object, private_key, utility, notes);
    end

end

end
