% Abstract superclass for 0D plot elements
% Anthony Ricciardi
%
classdef (Abstract) plot0D
    properties (Abstract)
        gdof_plot
        x1
        eke
        ese
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
        function ph = contour(obj,allDef,mode_number,fopts)
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
                    contourValues = 1;
                case 'Displacements'
                    switch fopts.contourTypeSpecificOpt
                        case 'Magnitude'
                            contourValues = norm_cs(def);
                        case 'X Component'
                            contourValues = def(1);
                        case 'Y Component'
                            contourValues = def(2);
                        case 'Z Component'
                            contourValues = def(3);
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
                            contourValues = norm_cs(r);
                        case 'X Component'
                            contourValues = r(1);
                        case 'Y Component'
                            contourValues = r(2);
                        case 'Z Component'
                            contourValues = r(3);
                    end
                case {'Stress','Strain'}
                    contourValues = 0; % no stress/strain definition
                case 'Element Strain Energy'
                    contourValues = obj.ese(mode_number);
                case 'Element Kinetic Energy'
                    contourValues = obj.eke(mode_number);
                otherwise
                    error([fopts.contourType, 'Contour type not supported'])
            end
            % Plot
            switch fopts.contourType
                case 'None'
                    ph = plot3(p(1),p(2),p(3),'o',...
                        'color',fopts.def0DMarkerRgb,...
                        'MarkerFaceColor',fopts.def0DMarkerRgb,...
                        'MarkerSize',fopts.def0DMarkerSize);
                otherwise
                    % Contour Plot
                    ph = scatter3(p(1),p(2),p(3),[],contourValues,'filled');
            end
        end
        
    end
end

%% complex step friendly norm
function p = norm_cs(v)
p = sqrt(v(1).^2+v(2).^2+v(3).^2);
end
