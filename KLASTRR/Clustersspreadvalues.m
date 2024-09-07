% Specify the path to your .mat file containing buildingLayer data
matFilePath = 'buildinginfo.mat';

% Load the variable containing buildingLayer data
loadedData = load(matFilePath);

% Check if 'buildingsLayer' is a variable in the loaded data and is a table
if isfield(loadedData, 'buildinginfo') && isa(loadedData.buildingsLayer, 'table')
    % Check if the table contains a suitable column for building IDs
    targetColumnName = 'ID';

    if ismember(targetColumnName, loadedData.buildingsLayer.Properties.VariableNames)
        disp(['Column ''' targetColumnName ''' found in the table.']);

        % Extract the building IDs, longitudes, and latitudes from the table
        buildingIDs = double(loadedData.buildingsLayer.(targetColumnName));
        longitudes = loadedData.buildingsLayer.Centroid.Longitude;
        latitudes = loadedData.buildingsLayer.Centroid.Latitude;

        % Combine extracted information into a matrix
        buildingInfo = [buildingIDs, longitudes, latitudes];

        % Number of clusters
        numClusters = 2;

        % Applying K-Means clustering to building information
        [clusterIndices, clusterCentroids] = kmeans(buildingInfo(:, 2:3), numClusters);

        % Initialize an empty cell array to store cluster boundaries
        clusterBoundaries = cell(numClusters, 1);

        % Initialize an array to store cluster distances in kilometers
        clusterDistances = zeros(numClusters, 1);

        % Initialize cell arrays to store latitudes and longitudes of each cluster
        clusterLatitudesCell = cell(numClusters, 1);
        clusterLongitudesCell = cell(numClusters, 1);

        for i = 1:numClusters
            % Extract the latitudes and longitudes of buildings in each cluster
            clusterLatitudes = latitudes(clusterIndices == i);
            clusterLongitudes = longitudes(clusterIndices == i);

            % Store latitudes and longitudes in the cell arrays
            clusterLatitudesCell{i} = clusterLatitudes;
            clusterLongitudesCell{i} = clusterLongitudes;

            % Create a convex hull around the buildings in the cluster
            k = convhull(clusterLongitudes, clusterLatitudes);

            % Store the boundary coordinates in the cell array
            clusterBoundaries{i} = [clusterLongitudes(k), clusterLatitudes(k)];

            % Calculate the perimeter of the convex hull in degrees
            clusterDistances(i) = calculatePerimeter(clusterBoundaries{i});

            % Convert the perimeter to kilometers
            conversionFactor = 111; % Approximate conversion factor for latitude in kilometers
            clusterDistances(i) = clusterDistances(i) * conversionFactor;
        end

        % Write the latitudes and longitudes of each cluster to separate spreadsheets
        for i = 1:numClusters
            clusterData = table(clusterLatitudesCell{i}, clusterLongitudesCell{i}, ...
                'VariableNames', {'Latitude', 'Longitude'});
            writetable(clusterData, ['Cluster_' num2str(i) '_LatLong.xlsx']);
            disp(['Cluster ' num2str(i) ' data written to Cluster_' num2str(i) '_LatLong.xlsx']);
        end

    else
        error(['Column ''' targetColumnName ''' not found in the table.']);
    end
else
    error('Variable ''buildinginfo'' not found in the .mat file or is not a table.');
end

function perimeter = calculatePerimeter(boundary)
    % Calculate the perimeter of the convex hull in degrees
    dx = diff(boundary(:, 1));
    dy = diff(boundary(:, 2));
    distances = hypot(dx, dy);
    perimeter = sum(distances);
end
