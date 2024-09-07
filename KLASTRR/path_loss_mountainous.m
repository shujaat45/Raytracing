function [total_path_loss] = path_loss_mountainous(frequency_MHz, distance_meters, building_distance_meters, building_height_meters, foliage_density, weather_condition)

% Speed of light (m/s)
c = 299792458;
pi = 3.14159;

% Free space path loss (dB)
fs_loss_dB = 20*log10(4*pi*distance_meters/c) + 92.45;

% Building path loss (dB) - Simplified model
building_loss_dB = min(10*(building_height_meters ./ building_distance_meters), 15);

% Foliage Loss (replace with a more comprehensive model)
additional_foliage_loss_dB = 0;
if (foliage_density >= 0) && (foliage_density <= 1)
  additional_foliage_loss_dB = foliage_density * 2;  % Example: 2 dB loss per 0.1 density unit
end

% Weather Loss (placeholder for real-time data integration)
additional_weather_loss_dB = 0;
if strcmp(weather_condition, 'Rain')
  additional_weather_loss_dB = 3;  % Example: 3 dB loss for rain (adjust based on actual data)
end

% Total Path Loss (dB)
total_path_loss = fs_loss_dB + building_loss_dB + additional_foliage_loss_dB + additional_weather_loss_dB;

end

% Example usage
frequency_MHz = 900;
distance_meters = 1000;
building_distance_meters = 50;
building_height_meters = 10;
foliage_density = 0.7;  % Between 0 (no foliage) and 1 (dense foliage)
weather_condition = 'Clear';  % Or 'Rain', 'Snow', 'Fog' (replace with actual data)

[total_path_loss_dB] = path_loss_mountainous(frequency_MHz, distance_meters, building_distance_meters, building_height_meters, foliage_density, weather_condition);

disp(['Free space path loss at ', num2str(frequency_MHz), ' MHz and ', num2str(distance_meters), ' meters: ', num2str(fs_loss_dB), ' dB']);
disp(['Additional path loss due to building at ', num2str(building_distance_meters), ' meters and ', num2str(building_height_meters), ' meters height: ', num2str(building_loss_dB), ' dB']);
disp(['Additional foliage loss: ', num2str(additional_foliage_loss_dB), ' dB']);
disp(['Additional weather loss due to ', weather_condition, ': ', num2str(additional_weather_loss_dB), ' dB']);
disp(['Total path loss: ', num2str(total_path_loss_dB), ' dB']);
