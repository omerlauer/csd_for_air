function broadcast_table = create_broadcast_table()

% set columns names and types
variable_names = ["objects", "key", "utility", "notes"];
variable_types = ["string", "double", "double", "string"];

% set table size
table_size = [0, numel(variable_names)];

% create empty table with defined columns
broadcast_table = table('Size', table_size, 'VariableTypes', variable_types, ...
    'VariableNames', variable_names);

end
