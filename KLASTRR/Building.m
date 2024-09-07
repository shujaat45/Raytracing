filename = "skardu.osm";
% linesLayer = readgeotable(filename,Layer="lines");
% figure
% geoplot(linesLayer)
% title("Lines Layer")
% pointsLayer = readgeotable(filename,Layer="points");
% hold on
% geoplot(pointsLayer)
% title("Points and Lines Layers")

buildingsLayer = readgeotable(filename,Layer="buildings");

figure
geoplot(buildingsLayer,ColorVariable="MaxHeight")

title("Maximum Heights of Buildings")
colormap sky
c = colorbar;
c.Label.String = "Height in Meters";

% Specify the path to your .mat file containing buildingLayer data
mat_file_path = 'buildingsLayer.mat';

% Load the variable containing buildingLayer data
loaded_data = load(mat_file_path);

% Check if 'buildingsLayer' is a variable in the loaded data
if isfield(loaded_data, 'buildingsLayer') && isa(loaded_data.buildingsLayer, 'table')
    % Display all column names in the table
    disp('Column names in the table:');
    disp(loaded_data.buildingsLayer.Properties.VariableNames);
    
    % Check if the table contains a suitable column for building IDs
    target_column_names = {'ID', 'Centroid'};

    if ismember(target_column_name, loaded_data.buildingsLayer.Properties.VariableNames)
        disp(['Column ''' target_column_name ''' found in the table.']);

        % Extract the building IDs from the target column
        building_ids = double(loaded_data.buildingsLayer.(target_column_name));
        building_ids = building_ids(:);


        % Continue with the rest of your code...
        % Number of clusters
        k = 25;

        % Applying K-Means clustering to building IDs
        [idx, centroids] = kmeans(building_ids, k, 'Replicates', 5);

        % Displaying the cluster indices
        disp('Cluster Indices:');
        disp(idx);

        % Displaying the cluster centroids
        disp('Cluster Centroids:');
        disp(centroids);

        % Visualize clusters on the map using geobubble
        figure
        for i = 1:k
            cluster_i_building_ids = building_ids(idx == i);
            sampled_building_ids = datasample(cluster_i_building_ids, min(1000, numel(cluster_i_building_ids)), 'Replace', false);

            % Display information about each cluster
            disp(['Cluster ' num2str(i) ' has ' num2str(numel(cluster_i_building_ids)) ' buildings.']);

            % Uncomment the line below if you want to display sampled_building_ids
            % disp(sampled_building_ids);

            % The code here can be adjusted based on your specific requirements
        end
        title('Building Clusters based on Building IDs');

    else
        error(['Column ''' target_column_name ''' not found in the table.']);
    end
else
    error('Variable ''buildingsLayer'' not found in the .mat file or is not a table.');
end
