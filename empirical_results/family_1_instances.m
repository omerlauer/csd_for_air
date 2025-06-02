% this script create the first three layers of family 1 instances

%% first layer, d = 1

ACS_d_1 = 1;

K_d_1 = 1;

KHS_d_1 = K_d_1.';

%% second layer, d = 2

ACS_d_2 = [ACS_d_1(:, 1) 0
           0             ACS_d_1
           1             1
           1             1];

K_d_2 = [K_d_1         0             0
         0             K_d_1         0
         K_d_1(end, :) 0             1
         0             K_d_1(end, :) 1];

KHS_d_2 = K_d_2.';

%% third layer, d = 3

zero_A_col = zeros(size(ACS_d_2, 1), 1);

ACS_d_3 = [ACS_d_2(:, 1) ACS_d_2(:, 2) zero_A_col
           ACS_d_2(:, 1) zero_A_col    ACS_d_2(:, 2)
           zero_A_col    ACS_d_2(:, 1) ACS_d_2(:, 2)
           1             1             1
           1             1             1
           1             1             1];

zero_K_col = zeros(size(K_d_2, 1), 1);
zero_K_row = zeros(1, size(K_d_2, 2));
zero_K = zeros(size(K_d_2));

K_d_3 = [K_d_2         zero_K        zero_K        zero_K_col
         zero_K        K_d_2         zero_K        zero_K_col
         zero_K        zero_K        K_d_2         zero_K_col
         K_d_2(end, :) zero_K_row    zero_K_row    1
         zero_K_row    K_d_2(end, :) zero_K_row    1
         zero_K_row    zero_K_row    K_d_2(end, :) 1];

KHS_d_3 = K_d_3.';
