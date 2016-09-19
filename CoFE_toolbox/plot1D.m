% Abstract superclass for 1D plot elements
% Anthony Ricciardi
%
classdef (Abstract) plot1D
    properties (Abstract, SetAccess = private)
        gdof
    end
    properties (Abstract, SetAccess = private, GetAccess = ?plot1D)
        x1
        x2
    end
    
    methods
        %%
        function ph = plot(obj,allDef,varargin)
            x = [obj.x1,obj.x2];
            
            if isempty(allDef);
                def = zeros(3,2);
            else
                def = allDef([obj.gdof(1:3),obj.gdof(7:9)]);
            end
            
            % points
            p = x + def;
            ph = plot3(p(1,:),p(2,:),p(3,:),varargin{1:end});
        end
    end
end
    
