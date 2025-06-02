function broadcast_table = send_coded_private_key(ACS, user, broadcast_table)

% set broadcast parameters for personal key
objects = get_user_objects(ACS, user);
key = 0;
utility = 1;
notes = "coded private key, user " + user;

% add broadcast
broadcast_table = add_broadcast(broadcast_table, objects, key, utility, notes);

end
