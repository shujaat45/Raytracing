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
        numClusters = 25;

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

        % Initialize arrays to store UAV parameters and users served per cluster
        uavPower = zeros(numClusters, 1);
        uavHeight = zeros(numClusters, 1);
        coverageArea = zeros(numClusters, 1);
        usersServed = cell(numClusters, 1);
        uavLocations = cell(numClusters, 1);

        for i = 1:numClusters
            % Extract the latitudes and longitudes of buildings in each cluster
            clusterLatitudes = latitudes(clusterIndices == i);
            clusterLongitudes = longitudes(clusterIndices == i);

            % Check if there are buildings in the cluster
            if ~isempty(clusterLatitudes)
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

                % Optimize UAV placement using random strategy based on the number of buildings in the cluster
                [optimizedUavLatitudes, optimizedUavLongitudes] = optimizeUavPlacementRandom(clusterLatitudes, clusterLongitudes, clusterBuildingCounts(i));

                % Store optimized UAV locations
                uavLocations{i} = [optimizedUavLongitudes, optimizedUavLatitudes];

                % Assume some logic to determine building IDs served in each cluster
                % Replace the following line with your actual logic
                usersServed{i} = buildingIDs(clusterIndices == i);

                % Calculate optimal UAV parameters based on the building IDs served
                % Replace the following lines with your actual calculations
                % Example: Set some arbitrary values for demonstration purposes
                uavPower(i) = 100;  % in watts
                uavHeight(i) = 50;  % in meters
                coverageArea(i) = 100;  % in square kilometers
            end
        end

        % Continue with visualization or any further analysis based on the calculated UAV parameters

        % Visualize clusters, boundaries, and optimized UAV locations on OpenStreetMap using geoplot
        figure
        geoscatter(latitudes, longitudes, 'b.'); % Scatter plot of all buildings

        hold on

        for i = 1:numClusters
            if ~isempty(uavLocations{i})
                % Scatter plot of buildings in each cluster
                geoscatter(latitudes(clusterIndices == i), longitudes(clusterIndices == i), 'filled', 'DisplayName', ['Cluster ' num2str(i)]);

                % Plot the boundary for each cluster using geoplot
                geoplot(clusterBoundaries{i}(:, 2), clusterBoundaries{i}(:, 1), 'r-', 'LineWidth', 2, 'DisplayName', ['Boundary ' num2str(i)]);

                % Scatter plot of optimized UAV locations in each cluster
                geoscatter(uavLocations{i}(:, 2), uavLocations{i}(:, 1), 'g^', 'filled', 'DisplayName', ['Optimized UAVs in Cluster ' num2str(i)]);
            end
        end

        title('Building Clusters with Boundaries and Optimized UAV Locations on OpenStreetMap');
        legend('Location', 'eastoutside');
        hold off

        % Display UAV parameters and users served
        for i = 1:numClusters
            if ~isempty(uavLocations{i})
                fprintf('Cluster %d - UAV Power: %d Watts, UAV Height: %d meters, Coverage Area: %.2f sq km\n', ...
                    i, uavPower(i), uavHeight(i), coverageArea(i));

                fprintf('Users Served in Cluster %d: %s\n', i, num2str(usersServed{i}));
            end
        end
    else
        error(['Column ''' targetColumnName ''' not found in the table.']);
    end
else
    error('Variable ''buildingsLayer'' not found in the .mat file or is not a table.');
end

% Add the calculatePerimeter function at the end of the script
function perimeter = calculatePerimeter(boundary)
    % Calculate the perimeter of the convex hull in degrees
    dx = diff(boundary(:, 1));
    dy = diff(boundary(:, 2));
    distances = hypot(dx, dy);
    perimeter = sum(distances);
end

% Random UAV placement strategy with the number of UAVs based on the number of buildings in the cluster
function [optimizedUavLatitudes, optimizedUavLongitudes] = optimizeUavPlacementRandom(clusterLatitudes, clusterLongitudes, numUAVsPerCluster)
    % Generate UAV positions randomly within the cluster boundaries
    numBuildings = length(clusterLatitudes);
    
    % Ensure at least one UAV is deployed in each cluster
    if numUAVsPerCluster < 100000
        numUAVsPerCluster = 1;
    end
    
    % Generate UAV positions based on the number of UAVs required for the cluster
    numUAVs = min(numUAVsPerCluster, numBuildings);
    indices = randperm(numBuildings, numUAVs);
    optimizedUavLatitudes = clusterLatitudes(indices);
    optimizedUavLongitudes = clusterLongitudes(indices);
end
