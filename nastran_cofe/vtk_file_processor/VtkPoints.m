classdef VtkPoints
    % class for vtk points data
    
    % Anthony Ricciardi
    % October 2021
    properties
        points  % [nPoints,3 double] point locations
        pointID % [nPoints,1 uint32] user-defined ID used for cell connectivity and results mapping.
    end
    
    methods
        function obj = VtkPoints(CofeNodes)
            obj.points  = [CofeNodes.x_0].';
            obj.pointID =  [CofeNodes.id].';
        end
        function print(obj,fid)
            % print to vtk file
            nPoints = size(obj.points,1);
            fprintf(fid,'POINTS %d float\n',nPoints);
            fprintf(fid,'%f %f %f\n',obj.points.');
        end
    end
    
end

