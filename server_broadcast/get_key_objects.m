function objects = get_key_objects(PKS, key)

% get objects of key from PKS
objects = find(PKS(key, :) == 1);

end
