function [s1,s2,angle] = calculatePrincipal(s)
%
% INPUT
% s = 3D or 2D stress or strain in Voigt notation 
%      3D [ [s11 s22 s33 s23 s13 s12]',nVectors] double] 
%
%      2D [ [s11 s22 s12]',nVectors] double] 
%          Assumes s33 = s23 = s13 == 0
%
%
% OUTPUT
n = size(s,1);
if n == 3
    c1 = .5*(s(1,:)+s(2,:));
    c2 = sqrt( (.5*(s(1,:)-s(2,:))).^2 + s(3,:).^2 );
    s1 = c1 + c2;
    s2 = c1 - c2; 
    angle = .5*(180/pi)*atan2ComplexStep(2*s(3,:),(s(1,:)-s(2,:)));
elseif n == 6
    a = ones(1,size(s,2));
    b = s(1,:) + s(2,:) + s(3,:);
    c = s(1,:).*s(2,:) + s(2,:).*s(3,:) + s(1,:).*s(3,:) ...
        - s(4,:).^2 - s(5,:).^2 - s(6,:).^2 ;
    d = s(1,:).*s(2,:).*s(3,:) + 2*s(4,:).*s(5,:).*s(6,:) ...
        - s(1,:).*s(4,:).^2 ...
        - s(2,:).*s(5,:).^2 ...
        - s(3,:).*s(6,:).^2;
    [x1,x2,x3] = calculateCubicEquationRoots(a,-1*b,c,-1*d);
    s1 = real(x3);
    % i1 = imag(x3);
    s2 = real(x1);
    % i2 = imag(x1);
    warning('This process will not work with complex step')
    if nargout>2
        error('angle output not implemented for 3D')
    end
else
    error('Input stress/strain dimension not allowed.')
end