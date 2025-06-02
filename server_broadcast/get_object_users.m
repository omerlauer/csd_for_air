function users = get_object_users(ACS, object)

% get users of object from ACS
users = find(ACS(:, object) == 1).';

end
