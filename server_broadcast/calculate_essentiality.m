function objects = calculate_essentiality(KHS, PKS, key, user)

% get key objects
key_objects = get_key_objects(PKS, key);

% get user keys
user_keys = get_user_keys(KHS, user);

% create essential flag per for each object
is_essential = false(size(key_objects));

% go over all key objects and check essentiality
for object_index = 1 : numel(key_objects)
    % get object keys
    object_keys = get_object_keys(PKS, key_objects(object_index));

    % key is essential to (user, object) pair if equals to intersection of key 
    % sets
    is_essential(object_index) = isequal(intersect(user_keys, object_keys), ...
        key);
end

% get objects of essential key
objects = key_objects(is_essential);

end
