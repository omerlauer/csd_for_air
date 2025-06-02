function PKS = calculate_PKS(ACS, KHS)

% get number of keys, users and objects
num_keys = get_num_keys(KHS);
num_users = get_num_users(ACS);
num_objects = get_num_objects(ACS);

% initialize PKS to be all ones matrix
PKS = ones(num_keys, num_objects);

% calculate PKS
for key = 1 : num_keys
    for object = 1 : num_objects
        for user = 1 : num_users
            % if user has key but has no access to object, set PKS entry to zero
            if ((KHS(key, user) == 1) && (ACS(user, object) == 0))
                PKS(key, object) = 0;
            end
        end
    end
end

end
