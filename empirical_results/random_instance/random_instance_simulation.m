%% setup

% set instance parameters
num_users = 50;
num_objects = 50;
p = 0.25;
num_keys_list = 0 : 5 : (num_users * num_objects * p);

% define number of instances
num_instances = 100;

% set seed for ACS generation
seed_ACS = 0;

% set seed for KHS generation
seed_KHS = 1;

% set essentiality feature
enable_essentiality = false;

%% generate ACSs

% seed rng
rng(seed_ACS);

% generate ACS matrices
ACS_list = binornd(1, p, [num_users, num_objects, num_instances]);

% calculate ACSs total weight
ACS_weight = squeeze(sum(ACS_list, [1, 2])).';

%% generate KHSs

% create random stream for parallel computation
sc = parallel.pool.Constant(RandStream('Threefry', 'Seed', seed_KHS));

% generate KHS matrices
KHS_list = cell(numel(num_keys_list), num_instances);
KHS_num_total_keys = zeros(numel(num_keys_list), num_instances);

parfor instance_index = 1 : numel(num_keys_list) * num_instances
    % get worker random stream
    worker_stream = sc.Value;
    worker_stream.Substream = instance_index;

    % get worker ACS
    worker_ACS = ACS_list(:, :, ceil(instance_index / numel(num_keys_list)));

    % generate KHS
    [KHS_list{instance_index}, KHS_num_total_keys(instance_index)] = ...
        create_random_KHS(worker_ACS, num_keys_list(mod(instance_index - 1, ...
        numel(num_keys_list)) + 1), worker_stream);

    % display message of end of run
    disp("KHS " + instance_index + " out of " + numel(num_keys_list) * ...
        num_instances + " is done!");
end

%% simulation

% create cost vectors
uncoded_costs = zeros(numel(num_keys_list), num_instances);
coded_costs = zeros(numel(num_keys_list), num_instances);

% run greedy algorithms over all instances
parfor instance_index = 1 : numel(num_keys_list) * num_instances
    % get worker ACS and KHS
    worker_ACS = ACS_list(:, :, ceil(instance_index / numel(num_keys_list)));
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
    disp("instance " + instance_index + " out of " + numel(num_keys_list) * ...
        num_instances + " is done!");
end

%% save results

save("empirical_results/random_instance/data/" + ...
    "random_instance_simulation_data_"  + ...
    string(datetime('now','Format','yyyy-MM-dd_HH_mm_ss')) + ".mat" , ...
    "num_users", "num_objects", "p", "num_keys_list", "num_instances", ...
    "seed_ACS", "seed_KHS", "enable_essentiality", "ACS_weight", ...
    "KHS_num_total_keys", "uncoded_costs", "coded_costs");
