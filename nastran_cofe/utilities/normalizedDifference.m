function normalizedDifference = normalizedDifference(array1,array2)
% Returns a normalized difference. Avoids dividing by numerical zero.
%
% INPUTS
% array1 = [n,m numeric]
% array2 = [n,m numeric]
%
% OUTPUT
% normalizedDifference = [n,m double]

% Anthony Ricciardi

%% Check inputs
if nargin < 2; error('At least two input arguments are required.'); end
if ~isnumeric(array1) || ~isnumeric(array2); error('Array inputs must be numeric'); end
[n1,m1]=size(array1);
[n2,m2]=size(array2);
if n1 ~= n2 || m1 ~= m2; error('Array sizes must be consistent'); end

%% Calculate normalized difference
norm1 = abs(array2);
norm2 = 0.001 * mean(abs(norm1(:))) * ones(n1,m1);
normalizedDifference = abs(array1-array2)./max(norm1,norm2);

end

