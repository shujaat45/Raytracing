
gax = geoaxes(Basemap="satellite");
latlimits = [34.5553  34.5553];
lonlimits = [69.2075  69.2075];
geolimits(latlimits,lonlimits);
geocenter = [mean(latlimits) mean(lonlimits) 0];
refHeight = 400;
hold on

interactiveROI = false;
load  Kabul river-latest.osm
helperPlotTakeoffROILanding(gax,takeoffLat,takeoffLon,landLat,landLon,llapoints);
