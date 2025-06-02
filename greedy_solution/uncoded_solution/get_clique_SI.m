function clique_SI = get_clique_SI(KHS, PKS, SI, key)

% get users of key
users = get_key_users(KHS, key);

% get objects of key
objects = get_key_objects(PKS, key);

% clique SI is a sub matrix of SI of key users and key objects
clique_SI = SI(users, objects);

end
