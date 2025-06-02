function keys = get_object_keys(PKS, object)

% get keys of object from PKS
keys = find(PKS(:, object) == 1).';

end
