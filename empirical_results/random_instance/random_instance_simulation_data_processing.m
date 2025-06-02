%% run defaults

run("empirical_results/defaults.m");

%% load data

% set data file
datafile = "random_instance_simulation_data.mat";

% get data file date
datafile_date = regexp(datafile, '\d{4}-\d{2}-\d{2}_\d{2}_\d{2}_\d{2}', ...
    'match', 'once');
if ismissing(datafile_date)
    datafile_date = "";
end

% load data file
load("empirical_results/random_instance/data/" + datafile);

%% calculations

% normalize costs
normalized_uncoded_costs = uncoded_costs ./ ACS_weight;
normalized_coded_costs = coded_costs ./ ACS_weight;

% calculate mean normalized costs
mean_normalized_uncoded_costs = mean(normalized_uncoded_costs, 2);
mean_normalized_coded_costs = mean(normalized_coded_costs, 2);

% calculate mean total number of keys
mean_KHS_num_total_keys = mean(KHS_num_total_keys, 2);

% calculate coding reduction ratios
coding_reduction_ratios = coded_costs ./ uncoded_costs;

% calculate mean coded reduction ratios
mean_coded_reduction_ratios = mean(coding_reduction_ratios, 2);

%% plot mean normalized costs by ACS weight

% set figure name
figure("Name", "Mean normalized costs, m=" + num_users + ", n=" + ...
    num_objects + ", p=" + p + ", date: " + datafile_date);

% plot figure
plot(mean_KHS_num_total_keys, mean_normalized_uncoded_costs, "--", ...
    mean_KHS_num_total_keys, mean_normalized_coded_costs, "-", "LineWidth", 2);

% set figure grid, labels and legend
grid on;
xlabel("number of keys - $ N $");
ylabel("mean normalized cost - $ \bar{T} $");
legend("uncoded solution", "coded solution", "location", "northeast");
ax = gca;
ax.XAxis.Exponent = 0;
xlim([0 18000]);
ylim([0.4, 1]);

% set figure filename
filename = strjoin(["random_instance_simulation_mean_cost", datafile_date( ...
    datafile_date ~= "")], "_");

% save figure
saveas(gcf, "empirical_results/random_instance/plots/" + filename + ".svg");
