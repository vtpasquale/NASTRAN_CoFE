function ph = contour(obj,allDef,mode_number,fopts)

%% Points
x = [obj.x1,obj.x2];
if isempty(allDef);
    def = zeros(3,2);
else
    def = allDef([obj.gdof(1:3),obj.gdof(7:9)]);
end
p = x + fopts.scaleFac * def;

%% Contour Values
switch fopts.contourType
    case 'None'
        contourValues = [0 0; 0 0];
    case 'Displacements'
        switch fopts.contourTypeSpecificOpt
            case 'Magnitude'
                contourValues = ...
                [norm_cs(def(:,1)),norm_cs(def(:,2));
                 norm_cs(def(:,1)),norm_cs(def(:,2))];
            case 'X Component'
                contourValues = ...
                [def(1,1),def(1,2);
                 def(1,1),def(1,2)];
            case 'Y Component'
                contourValues = ...
                [def(2,1),def(2,2);
                 def(2,1),def(2,2)];
            case 'Z Component'
                contourValues = ...
                [def(3,1),def(3,2);
                 def(3,1),def(3,2)];
        end
    case 'Rotations'
        % extract deformed rotations
        if isempty(allDef);
            r = zeros(3,2);
        else
            r = allDef([obj.gdof(4:6),obj.gdof(10:12)]);
        end
        switch fopts.contourTypeSpecificOpt
            case 'Magnitude'
                contourValues = ...
                [norm_cs(r(:,1)),norm_cs(r(:,2));
                 norm_cs(r(:,1)),norm_cs(r(:,2))];
            case 'X Component'
                contourValues = ...
                [r(1,1),r(1,2);
                 r(1,1),r(1,2)];
            case 'Y Component'
                contourValues = ...
                [r(2,1),r(2,2);
                 r(2,1),r(2,2)];
            case 'Z Component'
                contourValues = ...
                [r(3,1),r(3,2);
                 r(3,1),r(3,2)];
        end        
    case 'Element Nodal Forces'
        contourValues = obj.force(mode_number)*[1 1; 1 1];
    case 'Stress'
        contourValues = obj.stress(mode_number)*[1 1; 1 1];
    case 'Strain'
        contourValues = obj.strain(mode_number,1)*[1 1; 1 1];
    case 'Element Strain Energy'
        contourValues = obj.ese(mode_number)*[1 1; 1 1];
    case 'Element Kinetic Energy'
        contourValues = obj.eke(mode_number)*[1 1; 1 1];
    otherwise
        error([fopts.contourType, 'Contour type not supported'])
end

    
%% Contour Plot
ph = surf([p(1,:);p(1,:)],...
    [p(2,:);p(2,:)],...
    [p(3,:);p(3,:)],...
    contourValues,...
    'facecolor','none',...
    'edgecolor','interp',...
    'linewidth',fopts.defLineWidth);

end

%% complex step friendly norm
function p = norm_cs(v)
    p = sqrt(v(1).^2+v(2).^2+v(3).^2);
end