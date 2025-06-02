function objects = get_user_objects(ACS, user)

% get objects of user from ACS
objects = find(ACS(user, :) == 1);

end
