function T = atan2ComplexStep(Y,X)
% Complex-step-compatible atan2(). Input arrays can be any consistent size.
% This function reproduces MATLAB atan2() results for real inputs.  
% MATLAB atan2() reports an error when inputs are complex.
% 
% There is an output discontinuity at T = pi and -pi. However, the output 
% derivative is continuous, so, at T = pi and -pi, this function calculates
% the derivative analytically and adds complex-step-equivalent 
% perturbations to the output.
% 
% Because the function remains discontinuous, the user should carefully 
% consider before using atan2() output for gradient-based optimization.
% 
% Complex step is a numerical differentiation technique. See description:
% https://blogs.mathworks.com/cleve/2013/10/14/complex-step-differentiation/

% Anthony Ricciardi
% October 2021

% check n-dimensional array sizes
sizeX=size(X);
sizeY=size(Y);
if any(sizeX~=sizeY); error('Input array sizes must be consistent'); end
  
% get real parts of X and Y
realX = real(X);
realY = real(Y);

% create logical arrays for possible cases
case1 =      realX >  0;
case2 = and( realX <= 0, realY ~= 0);
case3 = and( realX <  0, realY == 0);
% case4 = and( realX == 0, realY == 0); Undefined -> leave as preallocated 0 value for MATLAB consistency

% assign values
T = zeros(sizeX);
T(case1) = 2*atan( Y(case1)./(sqrt(X(case1).^2+Y(case1).^2)+X(case1)) );
T(case2) = 2*atan((sqrt(X(case2).^2+Y(case2).^2)-X(case2))./Y(case2) );
if any(case3(:))
    % analytic gradients
    % dTdX = -Y./(X.^2+Y.^2) = 0;
    dTdY = zeros(sizeX);
    dTdY(case3) = X(case3)./(X(case3).^2+Y(case3).^2);
    
    % complex step size in Y
    complexStepSize = imag(Y);
    
    % add complex-step-equivalent perturbations to the output.
    T(case3) = pi + 1i*complexStepSize(case3).*dTdY(case3);
end
