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
    angle = .5*atan2d(2*s(3,:),(s(1,:)-s(2,:)));
elseif n == 6
    a = s(1,:) + s(2,:) + s(3,:);
    b = s(1,:).*s(2,:) + s(2,:).*s(3,:) + s(1,:).*s(3,:) ...
        - s(4,:).^2 - s(5,:).^2 - s(6,:).^2 ;
    c = s(1,:).*s(2,:).*s(3,:) + 2*s(4,:).*s(5,:).*s(6,:) ...
        - s(1,:).*s(4,:).^2 ...
        - s(2,:).*s(5,:).^2 ...
        - s(3,:).*s(6,:).^2;
    
%     https://math.vanderbilt.edu/schectex/courses/cubic/

%     roots([0,0;-a(1:2);b(1:2);-c(1:2)]')
% 
%     keyboard
    
else
    error('Input stress/strain dimension not allowed.')
end