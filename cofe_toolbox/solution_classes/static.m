% Class that defines a static solution.
% Anthony Ricciardi
%
classdef static
    
    properties
        u
    end
    
    methods 
        function obj=solve(obj,MODEL)
            obj.u=zeros(MODEL.ngdof,1);
            f=MODEL.f;
            obj.u(f)=MODEL.K(f,f)\MODEL.p(f);
        end
    end
end

