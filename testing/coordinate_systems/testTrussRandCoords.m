% clearvars; close all; clc
% addpath(genpath(fullfile('..','..','nastran_cofe')));

cofe = Cofe('truss_rand_coords.dat','output',false);

%% Transform node locations to local reference frame

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
        
for i = 1:size(csysList,1)
    coordinateSystem = cofe.model.coordinateSystem.getCoordinateSystem(csysList(i),cofe.model);
    cofeLocation(:,i) = coordinateSystem.x_c(cofe.model.point(nodeID).x_0);
end

locationDifference = normalizedDifference(location,cofeLocation);
assert(all(locationDifference(:)<1e-6),'Coordinate transformation error.') % [location;cofeLocation]

%% Displacement in global (local) reference frames
nastran_u_g = csvread('truss_rand_coords_u_g.csv',1,2);
cofe_u_g = [cofe.solution.displacement_g.T1,cofe.solution.displacement_g.T2,cofe.solution.displacement_g.T3];
u_gDifference = normalizedDifference(nastran_u_g,cofe_u_g);
assert(all(u_gDifference(:)<1e-5),'Displacement result different than verification case.') % [location;cofeLocation]


%% Displacement in basic reference frame
nastran_u_0 = csvread('truss_rand_coords_u_0.csv',1,2);
cofe_u_0 = [cofe.solution.displacement_0.T1,cofe.solution.displacement_0.T2,cofe.solution.displacement_0.T3];
u_0Difference = normalizedDifference(nastran_u_0,cofe_u_0);
assert(all(u_0Difference(:)<1e-5),'Displacement result different than verification case.') % [location;cofeLocation]



