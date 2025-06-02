function SI = create_SI(ACS)

% get number of users and objects
num_users = get_num_users(ACS);
num_objects = get_num_objects(ACS);

% create empty SI matrix
SI = zeros(num_users, num_objects);

end
