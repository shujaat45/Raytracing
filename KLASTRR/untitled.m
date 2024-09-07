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
        [clusterIndices, ~] = kmeans(buildingInfo(:, 2:3), numClusters, 'Replicates', 10);

        % Initialize arrays to store UAV parameters and users served per cluster
        uavLocations = cell(numClusters, 1);

        % Initialize arrays for coverage area and interference
        coverageArea = zeros(numClusters, 1);
        interference = zeros(numClusters, 1);

        for i = 1:numClusters
            % Extract the latitudes and longitudes of buildings in each cluster
            clusterLatitudes = latitudes(clusterIndices == i);
            clusterLongitudes = longitudes(clusterIndices == i);

            % Check if there are buildings in the cluster
            if ~isempty(clusterLatitudes)
                % Ensure at least one UAV is deployed in each cluster
                numUAVs = max(1, ceil(numel(clusterLatitudes) / 10));  % Assuming 1 UAV per 10 buildings

                % Initialize arrays to store UAV positions
                uavLocations{i} = zeros(numUAVs, 2);

                % Randomly select UAV positions within the cluster boundaries
                for uavIndex = 1:numUAVs
                    % Randomly select a building within the cluster as the UAV position
                    randomIndex = randi(numel(clusterLatitudes));
                    uavLocations{i}(uavIndex, 1) = clusterLatitudes(randomIndex);
                    uavLocations{i}(uavIndex, 2) = clusterLongitudes(randomIndex);
                end

                % Calculate coverage area for each cluster (approximated as the area of the convex hull)
                if numUAVs > 2  % Check if there are enough unique points to compute convex hull
                    k = convhull(uavLocations{i}(:, 2), uavLocations{i}(:, 1));
                    clusterBoundaries = [uavLocations{i}(k, 2), uavLocations{i}(k, 1)];
                    coverageArea(i) = polyarea(clusterBoundaries(:, 1), clusterBoundaries(:, 2));
                end

                % Calculate interference in each cluster based on coverage area
                communicationRange = 500;  % Placeholder for UAV communication range (meters)
                interference(i) = coverageArea(i) / (communicationRange^2);  % Assuming interference is proportional to coverage area
            end
        end

        % Continue with visualization or any further analysis based on the calculated UAV parameters

        % Visualize clusters and optimized UAV locations on OpenStreetMap using geoplot
        figure
        geoscatter(latitudes, longitudes, 'b.'); % Scatter plot of all buildings
        hold on

        for i = 1:numClusters
            if ~isempty(uavLocations{i})
                % Scatter plot of optimized UAV locations in each cluster
                geoscatter(uavLocations{i}(:, 1), uavLocations{i}(:, 2), 'g^', 'filled', 'DisplayName', ['Optimized UAVs in Cluster ' num2str(i)]);
            end
        end

        title('Building Clusters with Optimized UAV Locations on OpenStreetMap');
        legend('Location', 'eastoutside');
        hold off

        % Display coverage area and interference for each cluster
        for i = 1:numClusters
            if ~isempty(uavLocations{i})
                fprintf('Cluster %d - Coverage Area: %.2f sq km, Interference: %.2f\n', i, coverageArea(i), interference(i));
            end
        end

    else
        error(['Column ''' targetColumnName ''' not found in the table.']);
    end
else
    error('Variable ''buildingsLayer'' not found in the .mat file or is not a table.');
end
