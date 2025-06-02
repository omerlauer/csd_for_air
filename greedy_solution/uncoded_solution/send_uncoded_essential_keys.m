function [SI, broadcast_table] = send_uncoded_essential_keys(KHS, PKS, SI, ...
    keys, broadcast_table)

% set notes for uncoded essential broadcast
notes = "uncoded essential key";

% go over each key, get essentialities and send uncoded broadcasts
for key = keys
    % get key essentialities
    key_essentialities = get_key_essentialities(KHS, PKS, key);
    
    % get objects to send, union of all individual essentialities
    objects = unique(cell2mat(key_essentialities));
        
    % send objects if not empty
    if (~isempty(objects))
        % calculate objects utilities
        utilities = get_key_uncoded_utilities(KHS, SI, key, objects);
    
        % get users of key
        key_users = get_key_users(KHS, key);
        
        % send each object with uncoded broadcast
        for object_index = 1 : numel(objects)
            [SI, broadcast_table] = send_objects_to_users(SI, ...
                broadcast_table, key_users, objects(object_index), key, ...
                utilities(object_index), notes);
        end
    end

end

end
