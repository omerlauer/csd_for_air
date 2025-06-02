function users = get_key_users(KHS, key)

% get users of key from KHS
users = find(KHS(key, :) == 1);

end
