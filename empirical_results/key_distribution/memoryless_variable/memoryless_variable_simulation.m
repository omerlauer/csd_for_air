%% initial setup

% set instance parameters
num_users = 50;
num_objects = 50;
p_list = [0.125, 0.25, 0.375];
num_p = numel(p_list);
num_budgets = 100;
budget_list = cell2mat(arrayfun(@(p) round(linspace(0, num_users * ...
    num_objects * p, num_budgets)), p_list.', 'UniformOutput', false));

% define number of instances
num_instances = 200;

% set seed for ACS generation
seed_ACS = 0;

% set seed for KHS generation with variable degree
seed_KHS_variable_degree = 1;

% set enable essentiality flag
enable_essentiality = true;

%% calculate parameters for random key distribution

% initialize optimal alpha vectors
optimal_alpha_vec_2 = zeros(num_p, num_budgets);
optimal_alpha_vec_3 = zeros(num_p, num_budgets);

% calculate optimal alpha 2 and 3
for p_index = 1 : num_p
    % get current p
    current_p = p_list(p_index);

    % caluclate optimal alpha for current p
    parfor budget_index = 1 : num_budgets
        % optimize alpha
        [optimal_alpha_vec_2(p_index, budget_index), ...
            optimal_alpha_vec_3(p_index, budget_index)] = ...
            optimize_alpha_2_3(num_users, num_objects, current_p, ...
            budget_list(p_index, budget_index));

        % display message of end of alpha optimization
        disp("alpha 2, 3 of budget_index " + budget_index + " out of " + ...
            num_budgets + " for p = " + current_p + " are optimized!");
    end
end

% merge alpha vectors to a single vector
optimal_alpha_vec = cat(3, zeros(num_p, num_budgets) , optimal_alpha_vec_2, ...
    optimal_alpha_vec_3);

%% generate ACSs

% seed rng
rng(seed_ACS);

ACS_list = zeros(num_p, num_users, num_objects, num_instances);

% generate ACS matrices
for p_index = 1 : num_p
    ACS_list(p_index, :, :, :) = binornd(1, p_list(p_index), [num_users, ...
        num_objects, num_instances]);
end

% calculate ACSs total weight
ACS_weight = squeeze(sum(ACS_list, [2, 3]));

%% generate KHSs

% create empty cell vector for KHS
KHS_list = cell(num_p, num_budgets, num_instances);

% create random stream for parallel computation for fixed key degree
sc_variable = parallel.pool.Constant(RandStream('Threefry', 'Seed', ...
    seed_KHS_variable_degree));

% run variable degree key distribution
for p_index = 1 : num_p
    % get current p
    current_p = p_list(p_index);

    % create KHS for current p
    parfor instance_index = 1 : num_instances
        % get worker random stream
        worker_stream = sc_variable.Value;
        worker_stream.Substream = instance_index;
            
        % create KHS for all budgets
        for budget_index = 1 : num_budgets
            % create KHS
            KHS_list{p_index, budget_index, instance_index} = ...
                variable_key_degree(squeeze(ACS_list(p_index, :, :, ...
                instance_index)), optimal_alpha_vec(p_index, budget_index, ...
                :), budget_list(p_index, budget_index), worker_stream);

            % display message of end of instance generation
            disp("variable key degree " + ((instance_index - 1) * ...
                num_budgets + budget_index) + " out of " + num_instances * ...
                num_budgets + " for p = " + current_p + " was created!");
        end
    end
end

%% simulation

% create costs vectors
uncoded_costs = zeros(num_p, num_budgets, num_instances);
coded_costs = zeros(num_p, num_budgets, num_instances);

% run greedy algorithms over all instances
parfor instance_index = 1 : num_p * num_budgets * num_instances
    % get worker ACS and KHS
    worker_ACS = squeeze(ACS_list(mod(instance_index - 1, num_p) + 1, :, :, ...
        ceil(instance_index / (num_p * num_budgets))));
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
    disp("instance " + instance_index + " out of " + num_budgets * ...
        num_instances * num_p + " is done!");

end

%% save results

save("empirical_results/key_distribution/memoryless_variable/data/" + ...
    "memoryless_variable_simulation_data_" + ...
    string(datetime('now','Format','yyyy-MM-dd_HH_mm_ss')) + ".mat", ...
    "num_users", "num_objects", "p_list", "num_p", "num_budgets", ...
    "budget_list", "num_instances", "seed_ACS", "seed_KHS_variable_degree", ...
    "enable_essentiality", "optimal_alpha_vec", "ACS_weight", ...
    "uncoded_costs", "coded_costs", "enable_essentiality");
