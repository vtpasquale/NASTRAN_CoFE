% Abstract superclass for 2D plot elements
% Anthony Ricciardi
%
classdef (Abstract) plot2D
    properties (Abstract, SetAccess = private)
        gdof
    end
    properties (Access = private)
        gdofTranslational
    end
    properties (Abstract, SetAccess = private, GetAccess = ?plot2D)
        x1
        x2
        x3
        x4
    end
    
    methods
        %%
        function ph = plot(obj,allDef,varargin)
            x = [obj.x1,obj.x2,obj.x3,obj.x4];
            if isempty(allDef);
                def = zeros(3,4);
            else
                def = allDef(obj.gdof(obj.gdofTranslational));
            end
            p = x + def;
            ph = surf([p(1,1:2);p(1,4:-1:3)],[p(2,1:2);p(2,4:-1:3)],[p(3,1:2);p(3,4:-1:3)],'facecolor','none','edgecolor',varargin{2:end});
        end
        
    end
end
    
