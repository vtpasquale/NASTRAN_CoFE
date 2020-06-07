% clearvars; close all; clc
% addpath(genpath(fullfile('..','..','nastran_cofe')));
cofeOptions.bulkDataOnly = true;
cofeOptions.assemble = false;
cofeOptions.output = false;

%% Trasform locations to basic reference frame - simple case
cofe = Cofe('simple_case.dat',cofeOptions);
cofe_basic = Cofe('simple_case_basic.dat',cofeOptions);

transformedLocation = [cofe.model.point.x_0];
basicLocation = [cofe_basic.model.point.x_p];
locationDifference = normalizedDifference(transformedLocation,basicLocation);

% compare values
assert(all(locationDifference(:)<1e-6),'Coordinate transformation error.')

%% Transform locations to basic reference frame - complex case
cofe = Cofe('complex_case.dat',cofeOptions);
cofe_basic = Cofe('complex_case_basic.dat',cofeOptions);

transformedLocation = [cofe.model.point.x_0];
basicLocation = [cofe_basic.model.point.x_p];
locationDifference = normalizedDifference(transformedLocation,basicLocation);

% compare values
assert(all(locationDifference(:)<5e-6),'Coordinate transformation error.')
% large field formatting would have allowed for tighter tolerances