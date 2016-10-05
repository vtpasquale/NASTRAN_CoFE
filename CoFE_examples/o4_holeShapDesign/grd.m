% Objective function, constrants, and derivatives for optimization
%
function [objective,con] = grd(X,FEM)

[~,FEM_prime] = CoFE_design(FEM,X,@X_2_FEM);

% von Mises stress at all recover points for all elements
svmAll = [FEM_prime(1).CQUAD4.vonMisesStress;
          FEM_prime(2).CQUAD4.vonMisesStress;
          FEM_prime(3).CQUAD4.vonMisesStress;
          FEM_prime(4).CQUAD4.vonMisesStress;
          FEM_prime(5).CQUAD4.vonMisesStress;
          FEM_prime(6).CQUAD4.vonMisesStress;
          FEM_prime(7).CQUAD4.vonMisesStress];

% pick von Mises at element center - bottom face
svm = svmAll(:,1:10:270);

% Stress constraints
con =   svm;

% calculate mass
objective = zeros(7,1);
massDof = 1:6:FEM_prime(1).ndof; % pick all of one displacement dof
for i = 1:7
    objective(i) = d(full(sum(sum(FEM_prime(i).M_G(massDof,massDof)))));
end