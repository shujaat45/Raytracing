% Check if 'buildingsLayer' is a variable in the workspace
if exist('buildingsLayer', 'var') && isa(buildingsLayer, 'table')
    % Display all column names in the table
    disp('Column names in the table:');
    disp(buildingsLayer.Properties.VariableNames);

    % Check if the table contains a suitable column for building IDs
    target_column_name = 'ID';

    if ismember(target_column_name, buildingsLayer.Properties.VariableNames)
        disp(['Column ''' target_column_name ''' found in the table.']);

        % Extract the building IDs from the 'ID' column
        building_ids = buildingsLayer.(target_column_name);
        building_ids = building_ids(:);

        % Number of clusters
        k = 10;

        % Applying K-Means clustering to building IDs
        [idx, centroids] = kmeans(building_ids, k, 'Replicates', 5);

        % Displaying the cluster indices
        disp(idx);

        % Displaying the cluster centroids
        disp(centroids);
    else
        error(['Column ''' target_column_name ''' not found in the table.']);
    end
else
    error('Variable ''buildingsLayer'' not found in the workspace or is not a table.');
end
