function [optimal_alpha_2, optimal_alpha_3] = optimize_alpha_2_3(m, n, p, ...
    budget)

% calculate savings for several alphas
num_samples = 100;
savings_vector = zeros(1, num_samples);
alpha_2_vector = linspace(0.001, 1, num_samples);

% number of possible users in a column excluding our row
u_vector = 1 : m;

for sample_index = 1 : num_samples

    % define degree probabilities (sum must be 1)
    alpha_d = zeros(1, m);
    alpha_d(2) = alpha_2_vector(sample_index);
    alpha_d(3) = 1 - alpha_2_vector(sample_index);

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

    % calculate Q_u
    Q_u_t = cumsum(p_u_t);
    % calculate Z_u
    T_u_t = Q_u_t .^ (budget / E_pt_u);
    Z_u_t = T_u_t - [0, T_u_t(1 : end - 1)];
    
    % calculate gain
    savings_vector(sample_index) = [1, 1 ./ u_vector] * Z_u_t.';
end

[~, index] = min(savings_vector);
optimal_alpha_2 = alpha_2_vector(index);
optimal_alpha_3 = 1 - optimal_alpha_2;

% optional - plot all calculated alpha_2
% figure('Name', 'alpha d for d=2');
% plot(alpha_2_vector, savings_vector);

end
