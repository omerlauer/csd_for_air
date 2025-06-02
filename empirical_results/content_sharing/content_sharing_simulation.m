%% setup

% set instance parameters
num_block_users = 200;
num_block_objects = 50;
num_pair_users_per_block = 10;
num_pair_objects_per_block = 10;
triplet_num_list = 0 : 10 : 200;
num_triplet_num = numel(triplet_num_list);
num_triplet_objects_per_pair = 7;

% set number of instances per number of triplets
instances_per_triplet_num = 20;

% get number of instances
num_instances = num_triplet_num * instances_per_triplet_num;

% set seed for content sharing instance generation
seed_content_sharing = 0;

% set essentiality feature
enable_essentiality = true;

%% generate content sharing instances

% create empty cell vectors for generated instances
ACS_list = cell(num_triplet_num, instances_per_triplet_num);
KHS_list = cell(num_triplet_num, instances_per_triplet_num);

% create random stream for parallel computation for content sharing generation
sc_content_sharing = parallel.pool.Constant(RandStream('Threefry', 'Seed', ...
    seed_content_sharing));
        
% generate content sharing instances
parfor triplet_num_index = 1 : num_triplet_num
    % get worker random stream
    worker_stream = sc_content_sharing.Value;
    worker_stream.Substream = triplet_num_index;

    for instance_index = 1 : instances_per_triplet_num
        % generate instance
        [ACS_list{triplet_num_index, instance_index}, ...
            KHS_list{triplet_num_index, instance_index}] = ...
            generate_content_sharing_instance(num_block_users, ...
            num_block_objects, num_pair_users_per_block, ...
            num_pair_objects_per_block, triplet_num_list(triplet_num_index), ...
            num_triplet_objects_per_pair, worker_stream);

        % display message of end of instance generation
        disp("content sharing instance index " + ((triplet_num_index ...
            - 1) * instances_per_triplet_num + instance_index) + ...
            " out of " + num_instances + " was created!");
    end
end

% calculate ACSs total weight
ACS_weight = cellfun(@(x) sum(x, 'all'), ACS_list);

%% simulation

% create cost vectors
uncoded_costs = zeros(numel(triplet_num_list), instances_per_triplet_num);
coded_costs = zeros(numel(triplet_num_list), instances_per_triplet_num);

% run greedy algorithms over all instances
parfor instance_index = 1 : num_instances
    % get worker ACS and KHS
    worker_ACS = ACS_list{instance_index};
    worker_KHS = KHS_list{instance_index};
    
    % run greedy algorithms
    uncoded_broadcast_table = find_greedy_uncoded_solution(worker_ACS, ...
        worker_KHS, enable_essentiality);
    coded_broadcast_table = find_greedy_coded_solution(worker_ACS, ...
        worker_KHS, enable_essentiality);
    
    % get communication costs
    uncoded_costs(instance_index) = size(uncoded_broadcast_table, 1);
    coded_costs(instance_index) = size(coded_broadcast_table, 1);

    % display message of end of iteration
    disp("instance " + instance_index + " out of " + num_instances + ...
        " is done!");
end

%% save results

save("empirical_results/content_sharing/data/" + ...
    "content_sharing_simulation_data_" + ...
    string(datetime('now','Format','yyyy-MM-dd_HH_mm_ss')) + ".mat", ...
    "num_block_users", "num_block_objects", "num_pair_users_per_block", ...
    "num_pair_objects_per_block", "triplet_num_list", ...
    "num_triplet_objects_per_pair", "instances_per_triplet_num", ...
    "num_instances", "seed_content_sharing", "enable_essentiality", ...
    "ACS_weight", "uncoded_costs", "coded_costs");
