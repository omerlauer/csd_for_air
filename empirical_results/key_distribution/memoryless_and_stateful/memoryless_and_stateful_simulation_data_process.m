%% run defaults

run("empirical_results/defaults.m");

%% load data

% set data file
datafile = "memoryless_and_stateful_simulation_data.mat";

% get data file date
datafile_date = regexp(datafile, '\d{4}-\d{2}-\d{2}_\d{2}_\d{2}_\d{2}', ...
    'match', 'once');
if ismissing(datafile_date)
    datafile_date = "";
end

% load data file
load("empirical_results/key_distribution/memoryless_and_stateful/data/" + ...
    datafile);

%% calculations

% normalize costs
normalized_uncoded_costs = uncoded_costs ./ reshape(ACS_weight, 1, 1, []);
normalized_coded_costs = coded_costs ./ reshape(ACS_weight, 1, 1, []);

% calculate mean normalized costs
mean_normalized_uncoded_costs = mean(normalized_uncoded_costs, 3);
mean_normalized_coded_costs = mean(normalized_coded_costs, 3);

% normalize budget list
normalized_budget_list = 1 / (num_users * num_objects * p) * budget_list;

%% plot mean normalized costs by ACS weight

% set figure name
figure("Name", "Key distribution, mean normalized costs for memoryless and " + ...
    "stateful, " + "m = " + num_users + ", n=" + num_objects + ", p=" + p + ...
    ", date: " + datafile_date);

% plot figure
plot(normalized_budget_list, mean_normalized_coded_costs(1, :), "-", ...
    normalized_budget_list, mean_normalized_uncoded_costs(2, :), "--", ...
    normalized_budget_list, mean_normalized_coded_costs(3, :), "-", ...
    "LineWidth", 2);

% set figure grid, labels and legend
grid on;
xlabel("normalized budget - $ \bar{\tau} $");
ylabel("mean normalized cost - $ \bar{T} $");
legend("fixed degree, $ d = 2 $, coded solution", ...
    "pair-covering, uncoded variant + solution", ...
    "pair-covering, coded variant + solution", ...
    "location", "northeast");
ylim([0.4 1]);
xlim([0, 0.5]);

% set figure filename
filename = strjoin(["memoryless_and_stateful_simulation_mean_cost", ...
    datafile_date(datafile_date ~= "")], "_");

% save figure
saveas(gcf, "empirical_results/key_distribution/memoryless_and_stateful/" + ...
    "plots/" + filename + ".svg");
