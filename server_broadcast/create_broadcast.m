function broadcast = create_broadcast(objects, key, utility, notes)

% create a cell as the new broadcast
broadcast = {strjoin(string(objects), "+"), key, utility, notes};

end
