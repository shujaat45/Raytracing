viewer = siteviewer("Buildings","skardu.osm","Basemap","topographic");
boundery = 10;
num_users = 500;
% Define the location as a latitude and longitude coordinate
location = [35.286417, 75.61963];

% Define the radius of the circular region around the location
radius = 0.005;

% Pre-allocate an array to hold the users
rxs = repmat(rxsite(), 1, boundery);

% Generate random points within the circular region around the location
theta = linspace(0, 2*pi, boundery+1)';
theta = theta(1:end-1);
r = radius * ones(num_users, 1);
latitudes = location(1) + r .* cos(theta);
longitudes = location(2) + r .* sin(theta);

% Calculate the distance of each user from the center of the region
distances = distance(location(1), location(2), latitudes, longitudes);

% Sort the users in ascending order of distance from the center of the region
[distances, idx] = sort(distances);
latitudes = latitudes(idx);
longitudes = longitudes(idx);

% Create users at each fixed point within the circular region with numbered names
for i = 1:num_users
    rxs(i) = rxsite("Name", num2str(i), ...
                    "Latitude", latitudes(i), ...
                    "Longitude", longitudes(i), ...
                    "AntennaHeight", 1.5);
end

show();
