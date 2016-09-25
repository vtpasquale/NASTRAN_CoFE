% Abstract superclass for 0D plot elements
% Anthony Ricciardi
%
classdef (Abstract) plot0D
    properties (Abstract)
        eke
        ese
    end
    properties (Abstract, SetAccess = private, GetAccess = ?plot0D)
        x1
        gdof_plot
    end
    methods
        
        %%
        function ph = plot(obj,allDef,varargin)
            if isempty(allDef);
                def = zeros(3,1);
            else
                def = allDef(obj.gdof_plot);
            end
            
            % point
            p = obj.x1 + def;
            ph = plot3(p(1,:),p(2,:),p(3,:),varargin{:});
        end
        
        %%
        function ph = contour(obj,allDef,mode_number,fopts,ph)
            % Points
            if isempty(allDef);
                def = zeros(3,1);
            else
                def = allDef(obj.gdof_plot);
            end
            p = obj.x1 + fopts.scaleFac * def;
            % Contour Values
            switch fopts.contourType
                case 'None'
                    contourValue = 1;
                case 'Displacements'
                    switch fopts.contourTypeSpecificOpt
                        case 'Magnitude'
                            contourValue = norm_cs(def);
                        case 'X Component'
                            contourValue = def(1);
                        case 'Y Component'
                            contourValue = def(2);
                        case 'Z Component'
                            contourValue = def(3);
                    end
                case 'Rotations'
                    % extract deformed rotations
                    if isempty(allDef)
                        r = zeros(3,1);
                    else
                        r = allDef(obj.gdof_plot+3);
                    end
                    switch fopts.contourTypeSpecificOpt
                        case 'Magnitude'
                            contourValue = norm_cs(r);
                        case 'X Component'
                            contourValue = r(1);
                        case 'Y Component'
                            contourValue = r(2);
                        case 'Z Component'
                            contourValue = r(3);
                    end
                case {'Stress','Strain'}
                    contourValue = 0; % no stress/strain definition
                case 'Element Strain Energy'
                    contourValue = obj.ese(mode_number);
                case 'Element Kinetic Energy'
                    contourValue = obj.eke(mode_number);
                otherwise
                    error([fopts.contourType, 'Contour type not supported'])
            end
            % Plot
            switch fopts.contourType
                case 'None'
                    MarkerFaceColor=fopts.def0DMarkerRgb;
                otherwise
                    MarkerFaceColor = 'flat';
            end
            if nargin < 5
                ph = scatter3(p(1),p(2),p(3),[],contourValue,'filled',...
                            'MarkerFaceColor',MarkerFaceColor,...
                            'MarkerEdgeColor','none');
            else
                set(ph,'XData',p(1),'YData',p(2),'ZData',p(3),...
                'CData',contourValue,...
                'MarkerFaceColor',MarkerFaceColor);
            end
        end
        
    end
end

%% complex step friendly norm
function p = norm_cs(v)
p = sqrt(v(1).^2+v(2).^2+v(3).^2);
end
