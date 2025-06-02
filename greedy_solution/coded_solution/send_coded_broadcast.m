function broadcast_table = send_coded_broadcast(PKS, key, utility, notes, ...
    broadcast_table)

% get key objects
objects = get_key_objects(PKS, key);

% add a new broadcast to broadcast table
broadcast_table = add_broadcast(broadcast_table, objects, key, utility, notes);

end
