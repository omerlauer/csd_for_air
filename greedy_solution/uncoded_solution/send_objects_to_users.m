function [SI, broadcast_table] = send_objects_to_users(SI, broadcast_table, ...
    users, objects, key, utility, notes)

% add broadcast to table
broadcast_table = add_broadcast(broadcast_table, objects, key, utility, notes);

% update SI
SI = update_SI(SI, users, objects);

end
