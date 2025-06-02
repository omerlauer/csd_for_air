function dim = get_key_dim(PKS, key)

% calculate number of key objects from PKS
dim = sum(PKS(key, :), 2).';

end
