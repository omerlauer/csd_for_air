function broadcast_table = add_broadcast(broadcast_table, objects, key, ...
    utility, notes)

% create a new broadcast
broadcast = create_broadcast(objects, key, utility, notes);

% add broadcast to table
broadcast_table = [broadcast_table; broadcast];

end
