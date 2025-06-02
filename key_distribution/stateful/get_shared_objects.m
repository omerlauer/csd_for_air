function shared_objects = get_shared_objects(ACS, users)

% get shared objects of all users
shared_objects = find(all(ACS(users, :), 1));

end
