% this script contains statistical calculations for testing the equations and
% expressions shown in Key Disribution section

%% set parameters

% matrix dimensions
m = 50;
n = 50;

% probability for '1' in matrix cell
p = 0.25;

% define degree probabilities (sum must be 1)
alpha_d = zeros(1, m);
alpha_d(2) = 0.2;
alpha_d(3) = 0.5;
alpha_d(4) = 0.1;
alpha_d(5) = 0.2;

% number of possible users in a column excluding our row
u_vector = 1 : m;

% probability that given my column I have key degree u
p_u = arrayfun(@(u) alpha_d(u) * (binopdf(u : m - 1, m - 1, p) * ...
    (u ./ ((u : m - 1) + 1)).') + binopdf(u - 1, m - 1, p) * ...
    sum(alpha_d(u : m)) , u_vector);

% probability that given another column I have key degree u
p_u_tag = p .^ u_vector .* p_u;

% average probability for key degree u
p_u_t = 1 / n * p_u + (n - 1) / n * p_u_tag;

% add p_0_t
p_u_t = [1 - sum(p_u_t), p_u_t];

% probability that a new key has degree u
pt_u = arrayfun(@(u) alpha_d(u) * sum(binopdf(u + 1 : m, m, p)) + ...
    binopdf(u, m, p) * sum(alpha_d(u : m)) , u_vector);

% add pt_0
pt_u = [1 - sum(pt_u), pt_u];

% average key degree
E_pt_u = u_vector * pt_u(2 : end).';

%% simulation
 
% seed rng
seed = 0;
rng(seed);

% number of graphs and iterations per trial
num_graphs = 1000;
num_iterations = 50;

% set number of keys with specific degree vector
num_keys_per_degree = zeros(num_graphs, m + 1);
num_users_per_key = zeros(num_graphs, num_iterations);

for graph_index = 1 : num_graphs

    % generate ACS matrix
    ACS = binornd(1, p, [m, n]);

    % set edge (1, 1) to 1
    ACS(1, 1) = 1;
    
    for interation_index = 1 : num_iterations

        % choose column
        chosen_column = randi(n);
        
        % choose degree
        chosen_d = datasample(1 : m, 1, 'Weights', alpha_d);
        
        % get all users in the chosen column
        column_users = find(ACS(:, chosen_column) == 1);

        % choose users
        chosen_users = randsample(column_users, min(numel(column_users), ...
            chosen_d));

        num_users_per_key(graph_index, interation_index) = ...
            numel(chosen_users);

        % get chosen_objects
        if (isempty(chosen_users))
            chosen_objects = [];
        else
            chosen_objects = get_shared_objects(ACS, chosen_users);
        end

        % check if edge (1, 1) was chosen
        if (ismember(1, chosen_users) && ismember(1, chosen_objects))
            num_keys_per_degree(graph_index, numel(chosen_users) + 1) = ...
                num_keys_per_degree(graph_index, numel(chosen_users) + 1) + 1;
        else
            num_keys_per_degree(graph_index, 1) = ...
                num_keys_per_degree(graph_index, 1) + 1;
        end

    end

end

%% calculations

avg_num_keys_per_degree = mean(num_keys_per_degree, 1);

%% plots
    
figure('Name', 'avgNumKeyDegree');
plot([0, u_vector], avg_num_keys_per_degree / num_iterations, '.', ...
    [0, u_vector], p_u_t, '-.', 'MarkerSize', 16);
legend('empirical', 'expected');

% number of users per key histogram
figure('Name', 'numTotalKeyDegree');
histogram(num_users_per_key(:), 'Normalization', 'probability');
xline(E_pt_u, 'r-', ...
    ['expected users : ', num2str(E_pt_u), newline, ...
     'emprical value = ', num2str(mean(num_users_per_key, 'all'))], ...
     'LabelOrientation' ,'horizontal');
