function keys = get_user_keys(KHS, user)

% get keys of user from KHS
keys = find(KHS(:, user) == 1).';

end
