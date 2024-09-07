% Specify the path to your .mat file containing buildingLayer data
matFilePath = 'buildingsLayer.mat';

% Load the variable containing buildingLayer data
loadedData = load(matFilePath);

% Check if 'buildingsLayer' is a variable in the loaded data and is a table
if isfield(loadedData, 'buildingsLayer') && isa(loadedData.buildingsLayer, 'table')
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

        % Set the seed for reproducibility
        rng('default');

        % Increase the number of replicates
        [clusterIndices, clusterCentroids] = kmeans(buildingInfo(:, 2:3), numClusters, 'Replicates', 10);

        % Initialize an empty cell array to store cluster boundaries
        clusterBoundaries = cell(numClusters, 1);

        % Initialize an array to store cluster distances in kilometers
        clusterDistances = zeros(numClusters, 1);

        % Initialize an array to store the number of buildings in each cluster
        clusterBuildingCounts = zeros(numClusters, 1);

        % Initialize a cell array to store UAV locations in each cluster
        uavLocations = cell(numClusters, 1);

        for i = 1:numClusters
            % Extract the latitudes and longitudes of buildings in each cluster
            clusterLatitudes = latitudes(clusterIndices == i);
            clusterLongitudes = longitudes(clusterIndices == i);

            % Create a convex hull around the buildings in the cluster
            k = convhull(clusterLongitudes, clusterLatitudes);

            % Store the boundary coordinates in the cell array
            clusterBoundaries{i} = [clusterLongitudes(k), clusterLatitudes(k)];

            % Calculate the perimeter of the convex hull in degrees
            clusterDistances(i) = calculatePerimeter(clusterBoundaries{i});

            % Convert the perimeter to kilometers
            conversionFactor = 111; % Approximate conversion factor for latitude in kilometers
            clusterDistances(i) = clusterDistances(i) * conversionFactor;

            % Count the number of buildings in each cluster
            clusterBuildingCounts(i) = sum(clusterIndices == i);

            % Generate random UAV locations within the cluster
            numUAVs = 5; % You can adjust the number of UAVs
            uavLatitudes = rand(numUAVs, 1) * range(clusterLatitudes) + min(clusterLatitudes);
            uavLongitudes = rand(numUAVs, 1) * range(clusterLongitudes) + min(clusterLongitudes);
            uavLocations{i} = [uavLongitudes, uavLatitudes];
        end

        % Visualize clusters, boundaries, and UAV locations on OpenStreetMap using geoplot
        figure
        geoscatter(latitudes, longitudes, 'b.'); % Scatter plot of all buildings

        hold on

        for i = 1:numClusters
            % Scatter plot of buildings in each cluster
            geoscatter(latitudes(clusterIndices == i), longitudes(clusterIndices == i), 'filled', 'DisplayName', ['Cluster ' num2str(i)]);

            % Plot the boundary for each cluster using geoplot
            geoplot(clusterBoundaries{i}(:, 2), clusterBoundaries{i}(:, 1), 'r-', 'LineWidth', 2, 'DisplayName', ['Boundary ' num2str(i)]);

            % Scatter plot of UAV locations in each cluster
            geoscatter(uavLocations{i}(:, 2), uavLocations{i}(:, 1), 'g^', 'filled', 'DisplayName', ['UAVs in Cluster ' num2str(i)]);
        end

        title('Building Clusters with Boundaries and UAV Locations on OpenStreetMap');
        legend('Location', 'eastoutside');
        hold off

    else
        error(['Column ''' targetColumnName ''' not found in the table.']);
    end
else
    error('Variable ''buildingsLayer'' not found in the .mat file or is not a table.');
end

function perimeter = calculatePerimeter(boundary)
    % Calculate the perimeter of the convex hull in degrees
    dx = diff(boundary(:, 1));
    dy = diff(boundary(:, 2));
    distances = hypot(dx, dy);
    perimeter = sum(distances);
end
 



