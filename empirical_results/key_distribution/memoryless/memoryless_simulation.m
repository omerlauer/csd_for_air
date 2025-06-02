%% initial setup

% set instance parameters
num_users = 50;
num_objects = 50;
p = 0.25;
num_budgets = 100;
budget_list = round(linspace(0, num_users * num_objects * p, num_budgets));

% define number of instances
num_instances = 200;

% define fixed key degrees
fixed_key_degrees = [2, 3];

% set number of algorithms
num_algorithms = numel(fixed_key_degrees) + 1;

% set seed for ACS generation
seed_ACS = 0;

% set seed for KHS generation with fixed degree
seed_KHS_fixed_degree = 1;

% set seed for KHS generation with variable degree
seed_KHS_variable_degree = 2;

% set enable essentiality flag
enable_essentiality = true;

%% calculate optimal alpha vector for variable key degree 

% initialize optimal alpha vectors
optimal_alpha_vec_2 = zeros(num_budgets, 1);
optimal_alpha_vec_3 = zeros(num_budgets, 1);

% calculate optimal alpha 2 and 3
parfor budget_index = 1 : num_budgets
    % optimize alpha
    [optimal_alpha_vec_2(budget_index), ...
        optimal_alpha_vec_3(budget_index)] = ...
        optimize_alpha_2_3(num_users, num_objects, p, ...
        budget_list(budget_index));

    % display message of end of alpha optimization
    disp("alpha 2, 3 of budget_index " + budget_index + " out of " + ...
        num_budgets + " are optimized!");
end

% merge alpha vectors two a single vector
optimal_alpha_vec = [zeros(num_budgets, 1), optimal_alpha_vec_2, ...
    optimal_alpha_vec_3];

%% generate ACSs

% seed rng
rng(seed_ACS);

% generate ACS matrices
ACS_list = binornd(1, p, [num_users, num_objects, num_instances]);

% calculate ACSs total weight
ACS_weight = squeeze(sum(ACS_list, [1, 2])).';

%% generate KHSs

% create empty cell vector for KHS
KHS_list = cell(num_algorithms, num_budgets, num_instances);

% create random stream for parallel computation 
sc_fixed = parallel.pool.Constant(RandStream('Threefry', 'Seed', ...
    seed_KHS_fixed_degree));

% run fixed degree key distribution
for fixed_key_degree_index = 1 : numel(fixed_key_degrees)
    % get algoritm index for parfor loop
    fixed_key_degree_algorithm_index = fixed_key_degree_index;

    parfor instance_index = 1 : num_instances
        % get worker random stream
        worker_stream = sc_fixed.Value;
        worker_stream.Substream = instance_index;

        % create KHS for all budgets
        for budget_index = 1 : num_budgets
            % create KHS
            KHS_list{fixed_key_degree_algorithm_index, budget_index, ...
                instance_index} = fixed_key_degree(ACS_list(:, :, ...
                instance_index), ...
                fixed_key_degrees(fixed_key_degree_index), ...
                budget_list(budget_index), worker_stream);

            % display message of end of instance generation
            disp("fixed key degree with d = " + fixed_key_degrees( ...
                fixed_key_degree_index) + " index "+ ...
                ((instance_index - 1) * num_budgets + budget_index) + ...
                " out of " + num_instances * num_budgets + " was created!");
        end
    end
end

% create random stream for parallel computation for fixed key degree
sc_variable = parallel.pool.Constant(RandStream('Threefry', 'Seed', ...
    seed_KHS_variable_degree));

variable_key_degree_algorithm_index = numel(fixed_key_degrees) + 1;

% run variable degree key distribution
parfor instance_index = 1 : num_instances
    % get worker random stream
    worker_stream = sc_variable.Value;
    worker_stream.Substream = instance_index;
        
    % create KHS for all budgets
    for budget_index = 1 : num_budgets
        % create KHS
        KHS_list{variable_key_degree_algorithm_index, budget_index, ...
        instance_index} = variable_key_degree(ACS_list(:, :, ...
            instance_index), optimal_alpha_vec(budget_index, :), ...
            budget_list(budget_index), worker_stream);

        % display message of end of instance generation
        disp("variable key degree " + ((instance_index - 1) * ...
            num_budgets + budget_index) + " out of " + num_instances * ...
            num_budgets + " was created!");
    end
end

%% simulation

% create costs vectors for algorithms
uncoded_costs = zeros(num_algorithms, num_budgets, num_instances);
coded_costs = zeros(num_algorithms, num_budgets, num_instances);

% loop over all instances
parfor instance_index = 1 : num_algorithms * num_budgets * num_instances

    % get worker ACS and KHS
    worker_ACS = ACS_list(:, :, ceil(instance_index / (num_algorithms * ...
        num_budgets)));
    worker_KHS = KHS_list{instance_index};
    
    uncoded_broadcast_table = find_greedy_uncoded_solution(worker_ACS, ...
        worker_KHS, enable_essentiality);
    coded_broadcast_table = find_greedy_coded_solution(worker_ACS, ...
        worker_KHS, enable_essentiality);

    uncoded_costs(instance_index) = size(uncoded_broadcast_table, 1);
    coded_costs(instance_index) = size(coded_broadcast_table, 1);

    % display message of end of run
    disp("instance " + instance_index + " out of " + num_algorithms * ...
        num_budgets * num_instances + " is done!");

end

%% save results

save("empirical_results/key_distribution/memoryless/data/" + ...
    "memoryless_simulation_data_" + ...
    string(datetime('now','Format','yyyy-MM-dd_HH_mm_ss')) + ".mat", ...
    "num_users", "num_objects", "p", "num_budgets", "budget_list", ...
    "num_instances", "fixed_key_degrees", "num_algorithms", "seed_ACS", ...
    "seed_KHS_fixed_degree", "seed_KHS_variable_degree", ...
    "enable_essentiality", "optimal_alpha_vec", "ACS_weight", ...
    "uncoded_costs", "coded_costs");
