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

        % Applying K-Means clustering to building information
        [clusterIndices, clusterCentroids] = kmeans(buildingInfo(:, 2:3), numClusters, 'Replicates', 5);

        % Initialize an empty cell array to store cluster boundaries
        clusterBoundaries = cell(numClusters, 1);

        % Initialize an array to store cluster distances in kilometers
        clusterDistances = zeros(numClusters, 1);

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
        end

        % Visualize clusters and boundaries on OpenStreetMap using geoplot
        figure
        geoscatter(latitudes, longitudes, 'b.'); % Scatter plot of all buildings

        hold on

        for i = 1:numClusters
            % Scatter plot of buildings in each cluster
            geoscatter(latitudes(clusterIndices == i), longitudes(clusterIndices == i), 'filled', 'DisplayName', ['Cluster ' num2str(i)]);

            % Plot the boundary for each cluster using geoplot
            geoplot(clusterBoundaries{i}(:, 2), clusterBoundaries{i}(:, 1), 'r-', 'LineWidth', 2, 'DisplayName', ['Boundary ' num2str(i)]);

            % Display the distance covered by each cluster in kilometers
            disp(['Cluster ' num2str(i) ' covers a distance of ' num2str(clusterDistances(i)) ' kilometers.']);
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
