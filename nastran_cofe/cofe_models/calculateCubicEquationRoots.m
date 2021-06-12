function [x1,x2,x3] = calculateCubicEquationRoots(a,b,c,d)
% Finds the roots of the general cubic formula ax^3+bx^2+cx+d=0. 
% This function is designed for the unique situation where the user needs 
% to evaluate many independent cubic equations at once. Input coefficients 
% a, b, c, and d can be arrays of any dimension (including 3D and beyond). 
% Array processing is used exclusively for efficiency (i.e., no loops). 
% Three roots of each equation are provided in separate output arrays.
%
% If the user requires the solution for a single cubic equation, the user 
% should consider using the MATLAB roots() function for this purpose. 
%
% INPUTS
%   a      Size-consistent n-dimensional coefficient  
%   b      arrays for independent cubic equation(s)
%   c        
%   d       f(x) = a.*x.^3 + b.*x.^2 + c.*x + d
%
% OUTPUTS
%   x1      Roots (n-dimensional arrays). Each array contains
%   x2      one of the three roots of the equation(s).
%   x3    
%

% Anthony Ricciardi
% June 2021

% input checks
if ~all([isfloat(a),isfloat(b),isfloat(c),isfloat(d)])
    error('Inputs must be a floating point number array.')
end
if ~all([all(size(a)==size(b)),all(size(a)==size(c)),all(size(a)==size(d))])
    error('Input dimensions must be consistent')
end
if any(a(:)==0)
    error(['calculateCubicEquationRoots() should only be called for ',...
           'cubic functions. Functions are quadratic if a==0. The ',...
           'quadratic formula should be used for quadratic functions.'] );
end

% preallocate arrays
x1=zeros(size(a));
x2=x1;
x3=x1;

% Following https://en.wikipedia.org/wiki/Cubic_equation
% intermediate results
d0 = b.^2 - 3.*a.*c;
d1 = 2*b.^3 - 9*a.*b.*c + 27*a.^2.*d;
d2 = sqrt(d1.^2-4.*d0.^3);
if any(abs(d2(:))<1e-5)
    warning(['calculateCubicEquationRoots() has been called for at ',... 
             'least one function that is approaching a quadratic. One ',... 
             'of three roots may be numerical infinity. MATLAB roots()',...
             ' will have the same outcome for the same function.'])
end

% conditions
cUndefinedFlag = and(d0 == 0, d1 ==0);
cDefinedFlag = ~cUndefinedFlag;

% conditional calculations
if any(cUndefinedFlag(:))
    x1(cUndefinedFlag) = -b(cUndefinedFlag)./(3.*a(cUndefinedFlag));
    x2(cUndefinedFlag) = x1(cUndefinedFlag);
    x3(cUndefinedFlag) = x1(cUndefinedFlag);
end
if any(cDefinedFlag(:))
    c = zeros(size(a));
    % keep the larger of the two possible c constants
    c1=c;
    c2=c;
    c1(cDefinedFlag) = ((d1(cDefinedFlag)+d2(cDefinedFlag))./2).^(1/3);
    c2(cDefinedFlag) = ((d1(cDefinedFlag)-d2(cDefinedFlag))./2).^(1/3);
    keepC1Flag = (c1>c2);
    c( keepC1Flag)=c1( keepC1Flag);
    c(~keepC1Flag)=c2(~keepC1Flag);

    % xi0 = 1;
    xi1 = (-1+sqrt(-3))/2;
    xi2 = (-1-sqrt(-3))/2;
    % xi1.^2 - xi2 = 0
    
    x1(cDefinedFlag) = -1./(3*a(cDefinedFlag)).*(b(cDefinedFlag) ...
             + c(cDefinedFlag) + d0(cDefinedFlag)./     c(cDefinedFlag)  );
    x2(cDefinedFlag) = -1./(3*a(cDefinedFlag)).*(b(cDefinedFlag) ...
         + xi1*c(cDefinedFlag) + d0(cDefinedFlag)./(xi1*c(cDefinedFlag)) );
    x3(cDefinedFlag) = -1./(3*a(cDefinedFlag)).*(b(cDefinedFlag) ...
         + xi2*c(cDefinedFlag) + d0(cDefinedFlag)./(xi2*c(cDefinedFlag)) );
end