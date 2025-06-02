function [KHS, num_total_keys] = create_random_KHS(ACS, num_keys, stream)

% if no stream is given, set stream to global stream
if (nargin < 3)
    stream = RandStream.getGlobalStream;
end

% get number of users and objects from ACS
[num_users, num_objects] = size(ACS);

% create empty KHS
KHS = zeros(num_keys, num_users);

% fill KHS with keys
num_keys_created = 0;
num_total_keys = 0;
while (num_keys_created < num_keys)
    
    % create random KHS row for a new key with at least two users
    key_users = randsample(stream, num_users, randi(stream, [2, num_users]));

    % calculate PKS row
    PKS_row = ones(1, num_objects);
    for object = 1 : num_objects
        if (~all(ACS(key_users, object)))
            PKS_row(object) = 0;
        end
    end

    % if PKS row is not all zeros, add key
    if (any(PKS_row))
        num_keys_created = num_keys_created + 1;
        KHS(num_keys_created, key_users) = 1;
    end
    
    num_total_keys = num_total_keys + 1;

end

end
