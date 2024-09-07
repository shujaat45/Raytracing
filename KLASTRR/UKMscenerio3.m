clear
clc
viewer = siteviewer("Buildings","Ukmmap.osm","Basemap","topographic");
fq = [3.5e9; 6e9; 26e9; 28e9]; %  GHz
ss_perfect = zeros(3,10);
ss_concrete = zeros(3,10);
ss_weather = zeros(3,10);
ss_foliage = zeros(3,10);


rxBedfords = rxsite("Name","UKMSs", ... %Reciver
    "Latitude",2.923984, ...
    "Longitude",101.780819);


rxStAs = rxsite("Name","UKMYs", ...
    "Latitude",2.923127, ...
    "Longitude",101.778742);

rxGPDs = rxsite("Name","DORIs", ...
    "Latitude",2.924454, ...
    "Longitude",101.778449);

rxBedfordt = rxsite("Name","UKMSrt", ... 
    "Latitude",2.924575, ...
    "Longitude",101.782107);

rxStAt = rxsite("Name","UKMYrt", ...
    "Latitude",2.921336, ...
    "Longitude",101.779700);

rxGPDt = rxsite("Name","DORIrt", ...
    "Latitude",2.926548, ...
    "Longitude",101.780906);

rxGPDu = rxsite("Name","DORIu", ...
    "Latitude",2.924861, ...
    "Longitude",101.780785);

rxGPDx = rxsite("Name","DORIx", ...
    "Latitude",2.927302, ...
    "Longitude",101.780244);

rxGPDy = rxsite("Name","DORIy", ...
    "Latitude",2.925823, ...
    "Longitude",101.779094);


rxGPDz = rxsite("Name","DORIz", ...
    "Latitude",2.922016, ...
    "Longitude",101.780525);



 rxs = [rxBedfords, rxStAs, rxGPDs, rxBedfordt, rxStAt, rxGPDt, rxGPDu,  rxGPDx, rxGPDy, rxGPDz];
 show(rxs)

rxBedfords.AntennaHeight =1.5;
rxStAs.AntennaHeight =1.5;
rxGPDs.AntennaHeight = 1.5;
rxBedfordt.AntennaHeight =1.5;
rxStAt.AntennaHeight = 1.5;
rxGPDt.AntennaHeight = 1.5;
rxGPDu.AntennaHeight =1.5;
rxGPDx.AntennaHeight = 1.5;
rxGPDy.AntennaHeight = 1.5;
rxGPDz.AntennaHeight =1.5;




for f = 1:size(fq)
tx = txsite("Name","Asrama ibrahim Yaaku", ... %  Transmitter
    "Latitude",2.924324, ...
    "Longitude",101.780103, ...
    "AntennaHeight",120,...
    "TransmitterPower",1, ...
    "TransmitterFrequency",fq(f));



% show(tx)

rtpm = propagationModel("raytracing", ...
    "Method","sbr", ...
    "MaxNumReflections",10, ...
    "BuildingsMaterial","perfect-reflector", ...
    "TerrainMaterial","perfect-reflector"); 

% coverage(tx,rtpm, ...
%     "SignalStrengths",-80:-40, ...
%     "MaxRange",250, ...
%     "Resolution",3, ...
%     "Transparency",0.6)



 los(tx,rxs)

rtpm.MaxNumReflections =5;
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
    ss_concrete(f,i) = sigstrength(rx,tx, rtpm);
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
for rx = rxs
    rx.SystemLoss = L;
end

% Compute signal strength with foliage loss
for i = 1:size(rxs,2)
    rx = rxs(i);
    rx.SystemLoss = L;
    ss_foliage(f,i) = sigstrength(rx,tx,rtPlusWeather);
    disp("Signal strength at " + rx.Name + ":")
    disp(ss_foliage(f,i) + " dBm")
end

end


testmatrix = [ss_perfect; ss_concrete; ss_weather; ss_foliage];
writematrix("testmatrix", "testfile.xlsx", "FileType", "spreadsheet")