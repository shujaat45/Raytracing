% Constants
CELL_RADIUS = 1000;
NUM_USERS = 100;
NUM_DRONES = 5;
CELL_COUNT = 5;
INITIAL_HEIGHT = 30;
MAX_HEIGHT = 120;
HEIGHT_STEP = 15;
SIMULATION_TIME = 1;  % in seconds
TIME_STEP = 0.1;  % in seconds
MAX_SPEED = 0.5;  % in meters per second
MOVE_TOWARDS_USERS_PROBABILITY = 0.8;  % Probability to move towards areas with high user density
% Generate drone and cell positions
drone_positions = [2000, 2000; 4000, 2000; 6000, 2000; 4000, 4000; 6000, 4000];
cell_centers = drone_positions;
% Initialize height range
height_range = INITIAL_HEIGHT:HEIGHT_STEP:MAX_HEIGHT;
for h = height_range
   % Simulate user positions and calculate RSRP
   all_users = cell(NUM_DRONES, 1);
   all_rsrp = cell(NUM_DRONES, 1);
   for i = 1:NUM_DRONES
       users = generate_users(cell_centers(i, :), NUM_USERS, CELL_RADIUS);
       all_users{i} = users;
       rsrp = calculate_rsrp(users, drone_positions(i, :), h, 33);
       all_rsrp{i} = rsrp;
   end
   % Mobility and communication simulation
   figure;
   for t = 1:SIMULATION_TIME
       for i = 1:NUM_DRONES
           % Move users
           users = all_users{i};
           new_users = move_users(users, cell_centers(i, :), CELL_RADIUS, MAX_SPEED);
           all_users{i} = new_users;
           % Update RSRP
           rsrp = calculate_rsrp(new_users, drone_positions(i, :), h, 33);
           all_rsrp{i} = rsrp;
       end
       % Drone-to-drone communication
       drone_rsrp = calculate_drone_to_drone_rsrp(drone_positions, h, 33);
       all_rsrp = transmit_signal(drone_rsrp, all_rsrp);
       % Move drones towards areas with high user density
       for i = 1:NUM_DRONES
           users = all_users{i};
           drone_pos = drone_positions(i, :);
           if rand < MOVE_TOWARDS_USERS_PROBABILITY
               % Compute centroid of user positions
               centroid = mean(users);
               % Compute direction vector towards centroid
               direction = centroid - drone_pos;
               % Normalize direction vector
               direction = direction / norm(direction);
               % Compute new drone position by moving in the direction of the centroid
               new_drone_pos = drone_pos + direction * MAX_SPEED;
               % Update drone position if it is within the cell radius
               if sqrt((new_drone_pos(1) - cell_centers(i, 1))^2 + (new_drone_pos(2) - cell_centers(i, 2))^2) <= CELL_RADIUS
                   drone_positions(i, :) = new_drone_pos;
               end
           end
       end
       % Plot user positions and RSRP
       clf;
       for i = 1:NUM_DRONES
           users = all_users{i};
           rsrp = all_rsrp{i};
           scatter(users(:, 1), users(:, 2), 50, rsrp, 'filled');
           hold on;
                       scatter(drone_positions(i, 1), drone_positions(i, 2), 100, 'kx');
       end
       colorbar;
       title(sprintf('RSRP for Users in Different Cells (t = %d, Height = %d)', t, h));
       xlabel('Cell Radius(m) ');
       ylabel('Cell Radius(m)');
       drawnow;
       pause(TIME_STEP);
   end
end
% Function Definitions
% Generate random user positions within a cell
function users = generate_users(cell_center, num_users, cell_radius)
   users = zeros(num_users, 2);
   for i = 1:num_users
       angle = 2 * pi * rand;  % Random angle
       radius = cell_radius * sqrt(rand);  % Random radius within the cell
       x = cell_center(1) + radius * cos(angle);  % Compute x-coordinate
       y = cell_center(2) + radius * sin(angle);  % Compute y-coordinate
       users(i, :) = [x, y];
   end
end
% Calculate path loss between a user and a drone
function pl = path_loss(user_pos, drone_pos, drone_height)
   distance_2d = sqrt((user_pos(1) - drone_pos(1))^2 + (user_pos(2) - drone_pos(2))^2);
   distance_3d = sqrt(distance_2d^2 + drone_height^2);
   pl = 20 * log10(distance_3d) + 20 * log10(2.4 * 10^9) + 20 * log10(4 * pi / 3 * 10^-8);
end
% Calculate RSRP (Reference Signal Received Power) for each user
function rsrp = calculate_rsrp(users, drone_pos, drone_height, tx_power)
   num_users = size(users, 1);
   rsrp = zeros(num_users, 1);
   for i = 1:num_users
       pl = path_loss(users(i, :), drone_pos, drone_height);
       rsrp(i) = tx_power - pl;
   end
end
% Move users randomly within a cell, considering cell boundaries
function new_users = move_users(users, cell_center, cell_radius, max_speed)
   num_users = size(users, 1);
   new_users = users;
   for i = 1:num_users
       angle = 2 * pi * rand;  % Random angle
       speed = max_speed * rand;  % Random speed within the maximum speed
       x = users(i, 1) + speed * cos(angle);  % Compute new x-coordinate
       y = users(i, 2) + speed * sin(angle);  % Compute new y-coordinate
      
       if sqrt((x - cell_center(1))^2 + (y - cell_center(2))^2) <= cell_radius
           % Check if the new position is within the cell radius
           new_users(i, :) = [x, y];
       end
   end
end
% Calculate RSRP (Reference Signal Received Power) between each pair of drones
function drone_rsrp = calculate_drone_to_drone_rsrp(drone_positions, drone_height, tx_power)
   num_drones = size(drone_positions, 1);
   drone_rsrp = zeros(num_drones, num_drones);
   for i = 1:num_drones
       for j = 1:num_drones
           if i ~= j
               pl = path_loss(drone_positions(i, :), drone_positions(j, :), drone_height);
                               drone_rsrp(i, j) = tx_power - pl;
           end
       end
   end
end
% Transmit signal between drones based on RSRP
function all_rsrp = transmit_signal(drone_rsrp, all_rsrp)
   num_drones = size(drone_rsrp, 1);
   for i = 1:num_drones
       for j = 1:num_drones
           if i ~= j
               received_rsrp = drone_rsrp(j, i);
               all_rsrp{i} = max(all_rsrp{i}, received_rsrp);
           end
       end
   end
end

