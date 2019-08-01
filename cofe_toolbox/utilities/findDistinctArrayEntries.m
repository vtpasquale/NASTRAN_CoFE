function isDistinct = findDistinctArrayEntries(array, tol)
% Returns a logical array that is true where distinct entries exist in the input array
%
% INPUTS
% array = [n,m numeric]
% tol = optional [double] distinctness tolerance, where two values u and v 
%                are within tolerance if: abs(u-v) <= TOL*max(abs(A(:))) 
%                -> Implemented by Matlab uniquetol()
%
% OUTPUT
% isUnique = [n,m logical] true where distinct entries exist in input array

% Anthony Ricciardi

%% Check Inputs
if nargin < 1; error('Missing input argument "array".'); end
if ~isnumeric(array); error('Input array should be numeric'); end
if nargin > 1
    if ~isa(tol,'double'); error('Optional input argument "tol" should be type double.'); end
    useTolerance = true;
else
    useTolerance = false;
end
[n,m]=size(array);

%% Check distinctness
if useTolerance
    [~,ia] = uniquetol(array,tol); % no "stable" option for uniquetol
else
    [~,ia] = unique(array);
end

% convert ia to logical array
iaLogical = false(n,m);
iaLogical(ia) = true;

% nondistinct entries
if useTolerance
    lai = ismembertol(array,array(~iaLogical),tol);
else
    lai = ismember(array,array(~iaLogical));
end

% distinct entries
isDistinct = true(n,m); 
isDistinct(lai) = false;

end

