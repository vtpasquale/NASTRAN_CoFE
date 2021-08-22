% CoFE Solutions
cofe_8     = Cofe('square_plate_8_clamped-000.dat');
cofe_8tri  = Cofe('square_plate_8tri_clamped-000.dat');
cofe_irreg = Cofe('square_plate_irregular_clamped-000.dat');

E =  cofe_8.model.material.E;
nu = cofe_8.model.material.nu;
h =  cofe_8.model.property.t;
D = E*h^3/(12*(1-nu^2));

q = 3;
a = 2;

% Reference solution (Reddy Page 659)
wbar = 0.1495; % 4x4 linear solution
factor = D*100/(q*a^4);
wref = wbar/factor;

% Compare CoFE to reference solution
referenceFraction = ...
[cofe_8.solution.displacement.T3(177) / wref
 cofe_8tri.solution.displacement.T3(177) / wref
 cofe_irreg.solution.displacement.T3(636) / wref];

%% PLOAD4 with CQUAD4
assert(100*abs(referenceFraction(1)-1)<5,'PLOAD4 with CQUAD4')

%% PLOAD4 with CTRIA3
assert(100*abs(referenceFraction(2)-1)<5,'PLOAD4 with CTRIA3')

%% PLOAD4 with CQUAD4 & CTRIA3
assert(100*abs(referenceFraction(3)-1)<5,'PLOAD4 with CQUAD4 & CTRIA3')