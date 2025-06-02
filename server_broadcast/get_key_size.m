function key_size = get_key_size(KHS, key)

% calculate number of key users from KHS
key_size = sum(KHS(key, :), 2).';

end
