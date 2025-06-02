function [ACS, KHS] = generate_content_sharing_instance(num_block_users, ...
    num_block_objects, num_pair_users_per_block, num_pair_objects_per_block, ...
    num_triplets, num_triplet_objects_per_pair, stream)

% if no stream is given, set stream to global stream
if (nargin < 7)
    stream = RandStream.getGlobalStream;
end

% number of blocks, hardcoded
num_blocks = 3;

% create blocks
block_users = cell(1, num_blocks);
block_objects = cell(1, num_blocks);

% create keys for blocks
for block = 1 : num_blocks
    % calculate users and objects of current block
    users = (block - 1) * num_block_users + 1 : block * num_block_users;
    objects = (block - 1) * num_block_objects + 1 : block * num_block_objects;
    
    % create key
    block_users{block} = users;
    block_objects{block} = objects;
end

% create pairs in threes
pair_users = cell(1, floor(num_block_users / ...
    (2 * num_pair_users_per_block)) * num_blocks);
pair_objects = cell(1, floor(num_block_users / ...
    (2 * num_pair_users_per_block)) * num_blocks);

for triple_pair = 1 : numel(pair_users) / num_blocks
    % create three pairs
    for block = 1 : num_blocks

        % gather users and objects for pair
        users = cell(1, 2);
        objects = cell(1, 2);

        for in_block = 1 : numel(users)
            % choose users for pair
            users{in_block} = block_users{mod(block - numel(users) + ...
                in_block, num_blocks) + 1}(1 + 2 * ...
                num_pair_users_per_block * (triple_pair - 1) + ...
                (in_block - 1) * num_pair_users_per_block : 2 * ...
                num_pair_users_per_block * (triple_pair - 1) + in_block * ...
                num_pair_users_per_block);

            % choose random objects for pair
            objects{in_block} = sort(randsample(stream, block_objects{mod(block - ...
                numel(objects) + in_block, num_blocks) + 1}, ...
                num_pair_objects_per_block));
        end
        
        % add users and objects as pair
        pair_users{num_blocks * (triple_pair - 1) + block} = users;
        pair_objects{num_blocks * (triple_pair - 1) + block} = objects;
    end
end

% calculate number of triplets to create
num_triplets = min(num_triplets, numel(pair_users) * ...
    num_pair_users_per_block * 2 / num_blocks);

% create triplets
triplet_users = cell(1, num_triplets);
triplet_objects = cell(1, num_triplets);

for triplet = 1 : num_triplets
    % calculate first pair for triplet
    pair_triplet = num_blocks * ceil(triplet / ...
        (2 * num_pair_users_per_block)) - num_blocks + 1;

    % calculate in_block
    in_block = (mod(triplet - 1, 2 * num_pair_users_per_block) + 1 > ...
        num_pair_users_per_block) + 1;

    % calculate user index within in_block
    user_index = mod(triplet - 1, num_pair_users_per_block) + 1;
    
    % gather users and objects from chosen in_block
    users = cell(1, 3);
    objects = cell(1, 3);

    for pair_index = 1 : num_blocks
        % pick on user from in_block
        users{pair_index} = pair_users{pair_triplet + ...
            pair_index - 1}{in_block}(user_index);

        % gather objects from other in_block
        objects{pair_index} = sort(randsample(stream, pair_objects{ ...
            pair_triplet + pair_index - 1}{num_blocks - in_block}, ...
            num_triplet_objects_per_pair));
    end

    % add users and objects as triplet
    triplet_users{triplet} = users;
    triplet_objects{triplet} = objects;
end

% count number of keys, users and objects
num_users = sum(num_block_users);
num_objects = sum(num_block_objects);
num_keys = num_blocks + numel(pair_users) + numel(triplet_users);

% create empty ACS and KHS matrices
ACS = zeros(num_users, num_objects);
KHS = zeros(num_keys, num_users);

% populate ACS and KHS with blocks
for block = 1 : num_blocks
    ACS(block_users{block}, block_objects{block}) = 1;
    KHS(block, block_users{block}) = 1;
end

% populate ACS and KHS with pairs
for pair = 1 : numel(pair_users)
    ACS(cell2mat(pair_users{pair}), cell2mat(pair_objects{pair})) = 1;
    KHS(num_blocks + pair, cell2mat(pair_users{pair})) = 1;
end

% populate ACS and KHS with triplets
for triplet = 1 : numel(triplet_users)
    ACS(cell2mat(triplet_users{triplet}), cell2mat(triplet_objects{ ...
        triplet})) = 1;
    KHS(num_blocks + numel(pair_users) + triplet, cell2mat(triplet_users{ ...
        triplet})) = 1;
end

end