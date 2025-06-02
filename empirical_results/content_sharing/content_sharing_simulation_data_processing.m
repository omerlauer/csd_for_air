%% run defaults

run("empirical_results/defaults_2_subfigures.m");

%% load data

% set data file
datafile = "content_sharing_simulation_data.mat";

% get data file date
datafile_date = regexp(datafile, '\d{4}-\d{2}-\d{2}_\d{2}_\d{2}_\d{2}', ...
    'match', 'once');
if ismissing(datafile_date)
    datafile_date = "";
end

% load data file
load("empirical_results/content_sharing/data/" + datafile);

%% calculations

% normalize costs
normalized_uncoded_costs = uncoded_costs ./ ACS_weight;
normalized_coded_costs = coded_costs ./ ACS_weight;

% calculate mean normalized costs
mean_normalized_uncoded_costs = mean(normalized_uncoded_costs, 2);
mean_normalized_coded_costs = mean(normalized_coded_costs, 2);

% calculate mean cost
mean_uncoded_costs = mean(uncoded_costs, 2);
mean_coded_costs = mean(coded_costs, 2);

% calculate coding reduction ratios
coding_reduction_ratios = coded_costs ./ uncoded_costs;

% calculate mean coded reduction ratios
mean_coded_reduction_ratios = mean(coding_reduction_ratios, 2);

% calculating expected uncoded costs
expected_uncoded_block = 3 * num_block_objects;
expected_uncoded_pairs = 3 * num_block_users / num_pair_users_per_block * ...
    num_pair_objects_per_block;
expected_uncoded_triplets = triplet_num_list * num_triplet_objects_per_pair * 3;
expected_uncoded_cost = expected_uncoded_block + expected_uncoded_pairs + ...
    expected_uncoded_triplets;

% calculating expected coded costs
expected_coded_block = expected_uncoded_block;  
expected_coded_pair = expected_uncoded_pairs / 2;
expected_coded_triplet = expected_uncoded_triplets / 3;
expected_coded_cost = expected_coded_block + expected_coded_pair + ...
    expected_coded_triplet;

%% plot mean normalized cost by ACS weight

% set figure name
figure("Name", "Mean normalized costs , m1=" + num_block_users + ", n1=" + ...
    num_block_objects + ", m2=" + num_pair_users_per_block + ", n2=" + ...
    num_pair_objects_per_block + ", n3=" + num_triplet_objects_per_pair + ...
     ", date: " + datafile_date);

% plot figure
plot(triplet_num_list, mean_normalized_uncoded_costs, '--',  ...
    triplet_num_list, mean_normalized_coded_costs, '-', "LineWidth", 2);

% set figure grid, labels and legend
grid on;
xlabel("3-way recommendation-and-sharing steps");
ylabel("mean normalized cost - $ \bar{T} $");
legend("uncoded solution", "coded solution", "location", "northwest");

% set figure filename
filename_1 = strjoin(["content_sharing_simulation_mean_cost", datafile_date( ...
    datafile_date ~= "")], "_");

% save figure
saveas(gcf, "empirical_results/content_sharing/plots/" + filename_1 + ".svg");

%% plot mean coding ratio

% set figure name
figure("Name", "Coding savings ratio , m1=" + num_block_users + ", n1=" + ...
    num_block_objects + ", m2=" + num_pair_users_per_block + ", n2=" + ...
    num_pair_objects_per_block + ", n3=" + num_triplet_objects_per_pair + ...
    ", date: " + datafile_date);

% plot figure
plot(triplet_num_list, mean_coded_reduction_ratios, '-', "LineWidth", 2);

% set figure grid, labels and legend
grid on;
xlabel("3-way recommendation-and-sharing steps");
ylabel("mean coding savings ratio");

% set figure filename
filename_2 = strjoin(["content_sharing_simulation_mean_coding_ratio", ...
    datafile_date(datafile_date ~= "")], "_");

% save figure
saveas(gcf, "empirical_results/content_sharing/plots/" + filename_2 + ".svg");
