clear
clc
viewer = siteviewer("Buildings","Ukmmap.osm","Basemap","topographic");
fq =[3.5e9; 6e9; 28e9; 60e9];
ss_perfect = zeros(1,100);
ss_concrete = zeros(1,100);
ss_weather = zeros(1,100);
ss_foliage = zeros(1,100);


% Define the number of users
num_users = 100;

% Define the locations as latitude and longitude coordinates
locations = [2.922137,101.779533];

% Define the radius of the circular region around each location
radius = 0.00250;

% Pre-allocate an array to hold the users
rxs = repmat(rxsite(), 1, num_users * size(locations, 1));

% Loop over the locations
for i = 1:size(locations, 1)
    
    % Generate random points within the circular region around the location
    latitudes = locations(i, 1) + radius * randn(num_users, 1);
    longitudes = locations(i, 2) + radius * randn(num_users, 1);
    
    % Create users at each generated point
    for j = 1:num_users
        rxs((i-1)*num_users+j) = rxsite("Name", sprintf("User %d", (i-1)*num_users+j), ...
                          "Latitude", latitudes(j), ...
                          "Longitude", longitudes(j), ...
                          "AntennaHeight", 1.5);
    end
end


show(rxs);



for f = 1:size(fq)
tx = txsite("Name","Asrama ibrahim Yaaku", ... %  Transmitter
    "Latitude",2.92109, ...
    "Longitude",101.779560, ...
    "AntennaHeight",160,...
    "TransmitterPower",5, ...
    "TransmitterFrequency",fq(f));



show(tx)

rtpm = propagationModel("raytracing", ...
    "Method","SBR", ...
    "MaxNumReflections",10, ...
    "BuildingsMaterial","perfect-reflector", ...
    "TerrainMaterial","perfect-reflector");

% % coverage(tx,rtpm, ...
%     "SignalStrengths",-80:-40, ...
%     "MaxRange",250, ...
%     "Resolution",3, ...
%     "Transparency",0.6)



%  los(tx,rxs)

rtpm.MaxNumReflections =10;
raytrace(tx,rxs, rtpm)

for i = 1:size(rxs,2)
    rx = rxs(i);
    ss_perfect(f,i) = sigstrength(rx, tx, rtpm);
    disp("Received power using perfect reflection: " + rx.Name + ":")
    disp(ss_perfect(f,i) + " dBm")
end

 
rtpm.BuildingsMaterial = "concrete";
rtpm.TerrainMaterial = "concrete";
for i = 1:size(rxs,2)
    rx = rxs(i);
    ss_concrete(f,i) = sigstrength(rx, tx, rtpm);
    disp("Received power using concrete materials: " + rx.Name + ":")
    disp(ss_concrete(f,i) + " dBm")
    
end

rtPlusWeather = rtpm + propagationModel("gas") + propagationModel("rain");
raytrace(tx,rx,rtPlusWeather)

for i = 1:size(rxs,2)
    rx = rxs(i);
    ss_weather(f,i) = sigstrength(rx,tx, rtPlusWeather);
    disp("Received power including weather loss: " + rx.Name + ":")
    disp(ss_weather(f,i) + " dBm")

end



% Assume that propagation path travels through 5 m of foliage
foliageDepth = 5;
L = 0.45*((fq(f)/1e9)^0.284)*foliageDepth; % Weissberger model for d < 14
disp("Path loss due to foliage: " + L + " dB")

% Assign foliage loss as static SystemLoss on each receiver site

for i = 1:size(rxs,2)
    rx = rxs(i);
    rx.SystemLoss = L;
end

% Compute signal strength with foliage loss
for i = 1:size(rxs,2)
    rx = rxs(i);
    rx.SystemLoss = L;
    ss_foliage(f,i) = sigstrength(rx,tx,rtPlusWeather);
    disp(" foliage Signal strength at " + rx.Name + ":")
    disp(ss_foliage(f,i) + " dBm")
end
for i = 1:size(rx, 2)
    rx = rxs(i);
                       % Calculate the distance between the TX and the RX

   dme = distance(tx, rxs(i,: ));
   dkm = dme / 1000;
  
end
               %Calculate the azimuth and elevation angles between the sites
for i = 1:size(rx, 2)
    rx = rxs(i);
[azD,elD] = angle(tx, rxs(i,: ));

end

for i = 1:size(tx, 2)
    rx = rxs(i);
[az,el] = angle(rxs, tx(i,: ));


end
end


testmatrix = [ss_perfect; ss_concrete; ss_weather; ss_foliage];
writematrix("testmatrix", "testfile.xlsx", "FileType", "spreadsheet")
