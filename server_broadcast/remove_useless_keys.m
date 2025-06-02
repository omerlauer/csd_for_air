function keys = remove_useless_keys(PKS, keys)

% create empty list of flags of useless keys
useless_list = false(size(keys));

% go over all keys and fill the list of flags
for key_index = 1 : numel(keys)
    key_objects = get_key_objects(PKS, keys(key_index));
    if (isempty(key_objects))
        useless_list(key_index) = 1;
    end
end

% remove useless keys using list of flags
keys(useless_list) = [];

end
