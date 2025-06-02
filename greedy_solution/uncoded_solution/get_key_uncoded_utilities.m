function utilities = get_key_uncoded_utilities(KHS, SI, key, objects)

% get users of key
users = get_key_users(KHS, key);

% calculate utilities
utilities = sum(~SI(users, objects), 1);

end
