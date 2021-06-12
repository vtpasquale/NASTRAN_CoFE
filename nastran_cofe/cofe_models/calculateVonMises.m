function vonMises = calculateVonMises(s)
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
    vonMises=sqrt(s(1,:).^2 - s(1,:).*s(2,:) + s(2,:).^2 + 3*s(3,:).^2);
elseif n == 6
    vonMises=sqrt(.5*((s(1,:)-s(2,:)).^2+(s(2,:)-s(3,:)).^2 ...
             +(s(3,:)-s(1,:)).^2)+ 3*(s(4,:).^2 + s(5,:).^2 + s(6,:).^2) );
else
    error('Input stress/strain dimension not allowed.')
end