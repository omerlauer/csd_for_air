function essentialities = get_key_essentialities(KHS, PKS, key)

% get key users and objects
key_users = get_key_users(KHS, key);

% create empty essentialities cell vector
essentialities = cell(size(key_users));

% calculate essentiality for every user
for user_index = 1 : numel(key_users)
    essentialities{user_index} = calculate_essentiality(KHS, PKS, key, ...
        key_users(user_index));
end
