clear 
close all
clc
%%%%%%%%%%%
%%%%%%%%%%%
viewer = siteviewer("Buildings","Ukmmap.osm","Basemap","topographic");

ss_perfect = zeros(1,100);
ss_concrete = zeros(1,100);
ss_weather = zeros(1,100);
ss_foliage = zeros(1,100);


% for f = 1:size(fq)
% tx = txsite("Name","UKM", ...
%     "AntennaHeight",30,...
%     "TransmitterPower",5, ...
%     "Latitude",2.92576900,"Longitude",101.78166600, ...
%     "Antenna",design(dipole,fq(f)),"TransmitterFrequency",fq(f));
% show(tx)
% end

% Define the ideal location for the base station
base_lat = 35.434837;
base_lon = 75.450385;

% Define the antenna frequency range
fq = 6e9;

% Loop over each frequency and create a transmitter


for f = 1:size(fq, 2)
    % Create the transmitter with a dipole antenna
    tx = txsite("Name", "UKM", ...
        "AntennaHeight", 30, ...
        "TransmitterPower", 5, ...
        "Latitude", base_lat, ...
        "Longitude", base_lon, ...
        "Antenna", design(dipole, fq(f)), ...
        "TransmitterFrequency", fq(f));
    
    
    show(tx);
end



%%%%Antena Designs 
% for f = 1:size(fq)
% tx = txsite("Name","MathWorks Apple Hill", ...
%     "AntennaHeight",30,...
%     "TransmitterPower",5, ...
%     "Latitude",2.92576900,"Longitude",101.78166600, ...
%     "Antenna",design(yagiUda,fq(f)), "TransmitterFrequency",fq(f));
% show(tx)
% end


% Define the number of users()
 num_users = 115;

% Define the locations as latitude and longitude coordinates
locations = [35.434837, 75.450385];

% % % Define the radius of the circular region around each location
  radius = 0.005;

% Pre-allocate an array to hold the users
rxs = repmat(rxsite(), 1, num_users * size(locations, 1));

% % Fixed location
latitudes = [35.4375427, 35.442995, 35.438062, 35.432468, 35.437224, 35.428743,	35.441624, 35.42713261, 35.434986, 35.425821, 35.427981,   35.444981,   35.433027,   35.43382129,	35.43233717, 35.434555,	35.43675212, 35.436202,	35.43689718,	35.43686446,	35.4330181,	    35.43184064,	35.43188906,	35.4391047,  	35.42557196,	35.43380048,	35.43618889,	35.43157314,	35.43722314,	35.4344804,	    35.43014549,	35.43564382,	35.43349609,	35.43278764,	35.43128039,	35.43514423,	35.42560635,	35.43284533,	35.43211926,	35.43027751,	35.43810049,	35.43116564,	35.43754017,	35.4397162,	    35.43405265,	35.436226,	    35.43803459,	35.43443211,	35.43754135,	35.42852418,    35.44038912,	35.42988919,	35.42569282,	35.44175949,	35.43452337,	35.43708161,	35.43302071,	35.42973408,	35.41947206,	35.43796839,	35.43340358,	35.43385029,	35.43686503,	35.42774026,	35.43118977,	35.44057364,	35.43782632,	35.42843059,	35.42382068,	35.43198077,	35.43590698,	35.43954888,	35.43530563,	35.42922544,	35.43636779,	35.42897533,	35.43003217,	35.43156832,	35.42869003,	35.43348217,	35.43033725,	35.43340857,	35.43252489,	35.43278807,	35.43231931,	35.44100349,	35.43788853,	35.43513236,	35.42750227,	35.42670798,	35.42501324,	35.44786298,	35.43969887,	35.4361219,	    35.4299658,	    35.42910518,	35.4375752,	    35.44266242,	35.42637028,	35.43259001,	35.43441554,	35.42487701,	35.43904323,	35.43276371,	35.4443979,	    35.43288251,	35.43688291,	35.42912486,	35.43171268,	35.42899339,	35.43679988,	35.4413462,	    35.43186879,   35.419149,  35.427979,   35.423469];
longitudes= [75.45256688, 75.456453, 75.444447, 75.457487, 75.446514, 75.443466, 75.452873,	75.44786319, 75.440409, 75.440928,  75.454590, 75.440338,	75.45089554, 75.467312,  	75.45636625, 75.458302,	75.45098641, 75.467116,	75.44520078,	75.44609948,	75.44953563,	75.44942666,	75.44605592,	75.45128832,	75.45671764,	75.44912915,	75.44936215,	75.43937739,	75.44651243,	75.44341864,	75.44845383,	75.45301293,	75.45800135,	75.45937747,	75.44980058,	75.44878402,	75.45447258,	75.4528358, 	75.45421126,	75.4542764,	    75.44298347,	75.45308682,	75.4499273,	    75.44658374,	75.44691702,	75.45679229,	75.44633631,	75.44420091,	75.45145843,	75.46043886,	75.45051277,	75.4519265,	    75.44569376,	75.45875608,	75.45100994,	75.45303551,	75.44562466,	75.45465521,	75.45233073,	75.44460499,	75.4505837,	    75.44813201,	75.45093124,	75.44913224,	75.44943549,	75.44522043,	75.44876854,	75.45421763,	75.45910837,	75.4445824,	    75.46227206,	75.45801539,	75.45122754,	75.44887897,	75.44689173,	75.45454885,	75.44691197,	75.44807559,	75.45480309,	75.45256472,	75.45486874,	75.45290866,	75.44838051,	75.44781576,	75.45436684,	75.44702905,	75.4563183,	    75.45433851,	75.45182361,	75.45040113,	75.45221309,	75.46801839,	75.44982282,	75.44260203,	75.45996051,	75.45343423,	75.44714544,	75.46347167,	75.45313975,	75.45185602,	75.44649578,	75.44506035,	75.44154293,	75.4482704, 	75.44511949,	75.45362378,	75.44879686,	75.45922996,	75.45793791,	75.45120505,	75.44897118,	75.45614583,	75.44465246,   75.442293,  75.439573,   75.467906];



% Loop over the locations
% for i = 1:size(locations, 1)
% 
%     % % Generate random points within the circular region around the location
%     % latitudes = locations(i, 1) + radius * randn(num_users, 1);
%     % longitudes = locations(i, 2) + radius * randn(num_users, 1);
%     % 
%     % Create users at each generated point
%     for j = 1:num_users
%         rxs((i-1)*num_users+j) = rxsite("Name", sprintf("User %d", (i-1)*num_users+j), ...
%                           "Latitude", latitudes(j), ...
%                           "Longitude", longitudes(j), ...
%                           "AntennaHeight", 1.5);
%     end
% end

 for i = 1:size(locations, 1)
% 
%     % Generate random points within the circular region around the location
%     latitudes = locations(i, 1) + radius * randn(num_users, 1);
%     longitudes = locations(i, 2) + radius * randn(num_users, 1);
    
    % Create users at each generated point
    for j = 1:num_users
        rxs((i-1)*num_users+j) = rxsite("Name", sprintf("User %d", (i-1)*num_users+j), ...
                          "Latitude", latitudes(j), ...
                          "Longitude", longitudes(j), ...
                          "AntennaHeight", 1.5, ...
                          "Antenna",design(dipole,tx.TransmitterFrequency), ...
                          "ReceiverSensitivity", -102);
                          
    end
 end




show(rxs);



% for f = 1:size(fq)
% tx = txsite("Name","Asrama ibrahim Yaaku", ... %  Transmitter
%     "Latitude",2.92576900, ...
%     "Longitude",101.78166600, ...
%     "AntennaHeight",30,...
%     "TransmitterPower",5, ...
%     "TransmitterFrequency",fq(f));


%%%%%%%%%%
% for f = 1:size(fq)
% tx = txsite("Name","MathWorks Apple Hill", ...
%     "AntennaHeight",30,...
%     "TransmitterPower",5, ...
%     "Latitude",2.92576900,"Longitude",101.78166600, ...
%     "Antenna",design(dipole,fq(f)),"TransmitterFrequency",fq(f));
%%%%%%%%%%


show(tx);

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

% Compute signal strength with foliage loss
for i = 1:size(rxs,2)
    rx = rxs(i);
    rx.SystemLoss = L;
    ss_foliage(f,i) = sigstrength(rx,tx,rtPlusWeather);
    disp(" foliage Signal strength at " + rx.Name + ":")
    disp(ss_foliage(f,i) + " dBm")
end

% Set the maximum number of reflections to 1 and maximum number of diffractions to 0
rtPlusWeather.PropagationModels(1).MaxNumReflections = 10;
rtPlusWeather.PropagationModels(1).MaxNumDiffractions = 0;

% Create a cell array to store the computed rays for each user
rayCellArray = cell(1, 100);

% Loop for 100 users
for i = 1
    % Perform ray tracing for the i-th user
    rayCellArray{i} = raytrace(tx, rxs, rtPlusWeather);
end

% Display the characteristics of the computed rays for the first user
disp(rayCellArray{1});


for i = 1:size(rx, 2)
    rx = rxs(i);
                       % Calculate the distance between the TX and the RX

   dme = distance(tx, rxs(i,: ));
   dkm = dme / 1000;
 

end


testmatrix = [ss_perfect; ss_concrete; ss_weather; ss_foliage];
writematrix("testmatrix", "testfile.xlsx", "FileType", "spreadsheet")
