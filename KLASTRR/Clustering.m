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

        % Constants for UAV parameters
        power_threshold = 10;       % Power threshold in watts
        height_threshold = 0.5;     % Height threshold in meters
        bw_uav = 5;                 % UAV bandwidth in MHz
        alpha = 0.5;                % Path loss exponent
        chan_capacity_thresh = 1;   % Channel capacity threshold in Mbps
        var_n = 0.5;                % Noise variance

        % Initialize matrix for optimal UAV parameters (power, height, radius, users served, bandwidth, antenna type, frequency, concrete effects)
        optimal_data = zeros(numClusters, 8);

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

            % Initialize matrix for optimal UAV parameters
            optimal_data(i, :) = [power_threshold, height_threshold, 0, 0, bw_uav, 0, 0, 0]; % Initialize the last three columns

            % Calculate optimal UAV parameters for each UAV in the cluster
            for j = 1:clusterBuildingCounts(i)
                % Assume simple path loss model for coverage radius
                coverage_radius = sqrt((power_threshold / var_n) / (10^(chan_capacity_thresh / (10 * alpha))));

                % Calculate number of users served based on coverage area
                num_users_served = sum(pdist2([clusterCentroids(i, 1), clusterCentroids(i, 2)], [clusterLatitudes, clusterLongitudes]) < coverage_radius);

                % Store optimal data in the matrix
                optimal_data(i, 3:8) = [coverage_radius, num_users_served, bw_uav, 'your_antenna_type', 28e9, 7, 1];
            end
        end

        % Display the optimal data for each cluster
        disp('Optimal UAV Parameters for Each Cluster:');
        disp('------------------------------------------------------------------------------------------------------------');
        disp('Cluster | Power (W) | Height (m) | Radius (m) | Users Served | Bandwidth (MHz) | Antenna Type | Frequency (Hz) | Concrete Effects');
        disp('------------------------------------------------------------------------------------------------------------');
        for i = 1:numClusters
            disp([num2str(i) '       | ' num2str(optimal_data(i, 1)) '      | ' num2str(optimal_data(i, 2)) '        | '...
                  num2str(optimal_data(i, 3)) '       | ' num2str(optimal_data(i, 4)) '            | ' num2str(optimal_data(i, 5)) '               | '...
                  optimal_data(i, 6) '             | ' num2str(optimal_data(i, 7)) '        | ' num2str(optimal_data(i, 8))]);
        end

        % Visualize clusters and boundaries on OpenStreetMap
        figure
        geoscatter(latitudes, longitudes, 'b.'); % Scatter plot of all buildings

        hold on

        for i = 1:numClusters
            % Scatter plot of buildings in each cluster
            geoscatter(latitudes(clusterIndices == i), longitudes(clusterIndices == i), 'filled', 'DisplayName', ['Cluster ' num2str(i)]);

            % Plot the boundary for each cluster using geoplot
            geoplot(clusterBoundaries{i}(:, 2), clusterBoundaries{i}(:, 1), 'r-', 'LineWidth', 2, 'DisplayName', ['Boundary ' num2str(i)]);
        end

        title('Building Clusters with Boundaries on OpenStreetMap');
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
