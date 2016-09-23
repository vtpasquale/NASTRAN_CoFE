% Function to plot element and results
% Anthony Ricciardi
%
% Inputs:
% obj = element object
% allDef = fem.u [fem.ndof,1] static deformation, vibration
%          eigenvector, or buckling eigenvector.  Optional. Omit for
%          undeformed.
% mode_number = [int] response number for plotting.
% fopts = [struct] plotting options
%
% Outputs
% ph = [graphics handle] handle of contour plot
%
function ph = contour(obj,allDef,mode_number,fopts)
% points
x = [obj.x1,obj.x2,obj.x3,obj.x4];
if isempty(allDef);
    def = zeros(3,4);
else
    def = allDef([obj.gdof(1:3),obj.gdof(7:9),obj.gdof(13:15),obj.gdof(19:21)]);
end
p = x + fopts.scaleFac *def;

%% Contour Values
switch fopts.contourType
    case 'None'
        contourValues = [0 0 0 0];
    case 'Displacements'
        switch fopts.contourTypeSpecificOpt
            case 'Magnitude'
                contourValues = ...
                    [norm_cs(def(:,1)), norm_cs(def(:,2)), norm_cs(def(:,3)), norm_cs(def(:,4))];
            case 'X Component'
                contourValues = ...
                    [def(1,1), def(1,2), def(1,3), def(1,4)];
            case 'Y Component'
                contourValues = ...
                    [def(2,1), def(2,2), def(2,3), def(2,4)];
            case 'Z Component'
                contourValues = ...
                    [def(3,1), def(3,2), def(3,3), def(3,4)];
        end
    case 'Rotations'
        % extract deformed rotations
        if isempty(allDef);
            r = zeros(3,2);
        else
            r = allDef([obj.gdof(4:6),obj.gdof(10:12),obj.gdof(16:18),obj.gdof(22:24)]);
        end
        switch fopts.contourTypeSpecificOpt
            case 'Magnitude'
                contourValues = ...
                    [norm_cs(r(:,1)), norm_cs(r(:,2)), norm_cs(r(:,3)), norm_cs(r(:,4))];
            case 'X Component'
                contourValues = ...
                    [r(1,1), r(1,2), r(1,3), r(1,4)];
            case 'Y Component'
                contourValues = ...
                    [r(2,1), r(2,2), r(2,3), r(2,4)];
            case 'Z Component'
                contourValues = ...
                    [r(3,1), r(3,2), r(3,3), r(3,4)];
        end
    case 'Stress'
        switch fopts.contourTypeSpecificOpt
            case 'von Mises'
                contourValues = obj.vonMisesStress(mode_number,fopts.quad4RP);
            case 'X Component'
                vs = obj.voigtStress(1,mode_number,fopts.quad4RP);
                contourValues = [vs(1,1,1) vs(1,1,2) vs(1,1,3) vs(1,1,4)];
            case 'Y Component'
                vs = obj.voigtStress(2,mode_number,fopts.quad4RP);
                contourValues = [vs(1,1,1) vs(1,1,2) vs(1,1,3) vs(1,1,4)];
            case 'Z Component'
                vs = obj.voigtStress(3,mode_number,fopts.quad4RP);
                contourValues = [vs(1,1,1) vs(1,1,2) vs(1,1,3) vs(1,1,4)];
            case 'XY Component'
                vs = obj.voigtStress(6,mode_number,fopts.quad4RP);
                contourValues = [vs(1,1,1) vs(1,1,2) vs(1,1,3) vs(1,1,4)];
            case 'YZ Component'
                vs = obj.voigtStress(4,mode_number,fopts.quad4RP);
                contourValues = [vs(1,1,1) vs(1,1,2) vs(1,1,3) vs(1,1,4)];
            case 'ZX Component'
                vs = obj.voigtStress(5,mode_number,fopts.quad4RP);
                contourValues = [vs(1,1,1) vs(1,1,2) vs(1,1,3) vs(1,1,4)];
            otherwise
                error(['fopts.contourTypeSpecificOpt type ',fopts.contourTypeSpecificOpt,' not supported.']);
        end
    case 'Strain'
        switch fopts.contourTypeSpecificOpt
            case 'von Mises'
                vms = obj.vonMisesStrain(mode_number,fopts.beamRP);
                contourValues = [vms(1) vms(2); vms(1) vms(2)];
            case 'X Component'
                vs = obj.voigtStrain;
                s1 = vs(1,mode_number,fopts.beamRP(1));
                s2 = vs(1,mode_number,fopts.beamRP(2));
                contourValues = [s1 s2; s1 s2];
            case 'Y Component'
                vs = obj.voigtStrain;
                s1 = vs(2,mode_number,fopts.beamRP(1));
                s2 = vs(2,mode_number,fopts.beamRP(2));
                contourValues = [s1 s2; s1 s2];
            case 'Z Component'
                vs = obj.voigtStrain;
                s1 = vs(3,mode_number,fopts.beamRP(1));
                s2 = vs(3,mode_number,fopts.beamRP(2));
                contourValues = [s1 s2; s1 s2];
            case 'XY Component'
                vs = obj.voigtStrain;
                s1 = vs(6,mode_number,fopts.beamRP(1));
                s2 = vs(6,mode_number,fopts.beamRP(2));
                contourValues = [s1 s2; s1 s2];
            case 'YZ Component'
                vs = obj.voigtStrain;
                s1 = vs(4,mode_number,fopts.beamRP(1));
                s2 = vs(4,mode_number,fopts.beamRP(2));
                contourValues = [s1 s2; s1 s2];
            case 'ZX Component'
                vs = obj.voigtStrain;
                s1 = vs(5,mode_number,fopts.beamRP(1));
                s2 = vs(5,mode_number,fopts.beamRP(2));
                contourValues = [s1 s2; s1 s2];
            otherwise
                error(['fopts.contourTypeSpecificOpt type ',fopts.contourTypeSpecificOpt,' not supported.']);
        end
    case 'Element Strain Energy'
        contourValues = obj.ese(mode_number)*[1 1; 1 1];
    case 'Element Kinetic Energy'
        contourValues = obj.eke(mode_number)*[1 1; 1 1];
    otherwise
        error([fopts.contourType, 'Contour type not supported'])
end


% % %%
% % ph = surf([p(1,1:2);p(1,4:-1:3)],[p(2,1:2);p(2,4:-1:3)],[p(3,1:2);p(3,4:-1:3)],'facecolor','none',...
% %     'edgecolor',fopts.def2DLineRgb,...
% %     'LineWidth',fopts.def2DLineWidth);

%% Plot
switch fopts.contourType
    case 'None'
        ph = surf([p(1,1:2);p(1,4:-1:3)],...
            [p(2,1:2);p(2,4:-1:3)],...
            [p(3,1:2);p(3,4:-1:3)],...
            'EdgeColor',fopts.def2DLineRgb,...
            'LineWidth',fopts.def2DLineWidth,...
            'FaceColor',fopts.def2DFaceRgb,...
            'FaceAlpha',fopts.def2DFaceAlpha);
    otherwise
        % Contour Plot
       ph = surf([p(1,1:2);p(1,4:-1:3)],...
           [p(2,1:2);p(2,4:-1:3)],...
           [p(3,1:2);p(3,4:-1:3)],...
           [contourValues(1:2);contourValues(4:-1:3)],...
           'FaceColor','interp',...
           'EdgeColor',fopts.def2DLineRgb,...
           'linewidth',fopts.def2DLineWidth,...
           'FaceAlpha',fopts.def2DFaceAlpha);
end

end

%% complex step friendly norm
function p = norm_cs(v)
p = sqrt(v(1).^2+v(2).^2+v(3).^2);
end