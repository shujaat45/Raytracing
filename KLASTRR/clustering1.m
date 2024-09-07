% Specify the path to your .mat file containing buildingLayer data
mat_file_path = 'buildingsLayer.mat';

% Load the variable containing buildingLayer data
loaded_data = load(mat_file_path);

% Check if 'buildingsLayer' is a variable in the loaded data
if isfield(loaded_data, 'buildingsLayer') && isa(loaded_data.buildingsLayer, 'table')
    % Check if the table contains a suitable column for building IDs
    target_column_name = 'ID';

    if ismember(target_column_name, loaded_data.buildingsLayer.Properties.VariableNames)
        % Extract the building IDs from the target column
        building_ids = double(loaded_data.buildingsLayer.(target_column_name));
        building_ids = building_ids(:);

        % Number of clusters
        k = 10;

        % Applying K-Means clustering to building IDs
        [idx, centroids] = kmeans(building_ids, k, 'Replicates', 5);

        % Displaying the cluster indices and centroids
        disp('Cluster Indices:');
        disp(idx);
        disp('Cluster Centroids:');
        disp(centroids);

        % Visualize original buildings with geobubble
        figure
        geobubble(loaded_data.buildingsLayer.LatColumn, loaded_data.buildingsLayer.LonColumn, ...
            'SizeVariable', 'MaxHeight', 'ColorVariable', 'MaxHeight');
        title('Original Buildings with Size and Color based on MaxHeight');
        colormap(sky);
        c = colorbar;
        c.Label.String = 'Height in Meters';

        % Add clusters with 1000 buildings from each cluster
        hold on
        for i = 1:k
            cluster_i_building_ids = building_ids(idx == i);
            sampled_building_ids = datasample(cluster_i_building_ids, min(1000, numel(cluster_i_building_ids)), 'Replace', false);

            % Filter the buildingsLayer for the sampled_building_ids
            cluster_i_buildings = loaded_data.buildingsLayer(ismember(building_ids, sampled_building_ids), :);

            % Plot the buildings in this cluster with a unique color
            % geobubble(cluster_i_buildings.LatColumn, cluster_i_buildings.LonColumn, ...
                % 'SizeVariable', 'MaxHeight', 'ColorVariable', 'MaxHeight', ...
                % 'Color', rand(1, 3), 'DisplayName', ['Cluster ' num2str(i)], 'LegendVisible', 'on');
        end
        hold off
        title('Building Clusters with 1000 Buildings in Each Cluster');
        % legend('Location', 'eastoutside');
    else
        error(['Column ''' target_column_name ''' not found in the table.']);
    end
else
    error('Variable ''buildingsLayer'' not found in the .mat file or is not a table.');
end

