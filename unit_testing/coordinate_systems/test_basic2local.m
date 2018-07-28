% clearvars; close all; clc
% addpath(genpath(fullfile('..','..','cofe_toolbox')));

%% Transform locations to local reference frame

% ID	Def CSys	X-Def	Y-Def	Z-Def	Active Csys	X-Act	Y-Act	Z-Act
% 4	6558	169.8167	-216.2057	-3.539755	0..Global Rectangular	-3.311129E-12	120.	240.
% 4	6558	169.8167	-216.2057	-3.539755	3..Cylindrical Coordinate System	120.	90.	240.
% 4	6558	169.8167	-216.2057	-3.539755	4..Spherical Coordinate System	268.3282	26.56505	90.
% 4	6558	169.8167	-216.2057	-3.539755	120..Cylindrical Coordinate System	209.2676	-154.5887	-74.69447
% 4	6558	169.8167	-216.2057	-3.539755	319..Spherical Coordinate System	234.6864	90.48062	41.28919
% 4	6558	169.8167	-216.2057	-3.539755	1419..Spherical Coordinate System	221.4435	72.45807	-126.0349
% 4	6558	169.8167	-216.2057	-3.539755	1270..Rectangular Coordinate System	-188.6176	-30.08591	220.797
% 4	6558	169.8167	-216.2057	-3.539755	7547..Rectangular Coordinate System	146.0503	-122.6481	-95.02941
% 4	6558	169.8167	-216.2057	-3.539755	1712..Spherical Coordinate System	180.9601	30.36212	155.6088
% 4	6558	169.8167	-216.2057	-3.539755	1869..Cylindrical Coordinate System	205.0785	177.0128	-76.73323

nodeID = 4;
csysList = [0,3,4,120,319,1419,1270,7547,1712,1869]';
location = [-3.311129E-12	120.	240.
            120.	90.	240.
            268.3282	26.56505	90.
            209.2676	-154.5887	-74.69447
            234.6864	90.48062	41.28919
            221.4435	72.45807	-126.0349
            -188.6176	-30.08591	220.797
            146.0503	-122.6481	-95.02941
            180.9601	30.36212	155.6088
            205.0785	177.0128	-76.73323]';
        
% test case
ENTRY = entry.import_entries('truss_rand_coords.dat');
MODEL = ENTRY.entry2model_all();
MODEL = MODEL.preprocess();
MODEL = MODEL.assemble();

for i = 1:size(csysList,1)
    cord_id = MODEL.cordCIDs==csysList(i);
    cofeLocation(:,i) = MODEL.CORD(cord_id).X_C(MODEL.NODE(nodeID).X_0);
end

% 
assert(max(max(abs([location-cofeLocation])))<1e-4) % [location;cofeLocation]


