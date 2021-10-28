classdef VtkCellQuad < VtkCells
    % Class for VTK quad cells [VTK_QUAD (=9)]
    
    % Anthony Ricciardi
    % October 2021
    properties (Constant = true, Hidden=true)
        NUM_POINTS = 4;% [uint32] number of points per cell
        CELL_TYPE = 9;% [uint32] vtk cell type ID
    end
    properties
        eid % [uint32] user-defined ID used for results mapping.
        vertices % [4,1 uint32] user-defined point IDs at vertex locations.
    end
    methods
        function obj = VtkCellQuad(CofeElements)
            % Construct from CoFE Element object
            if nargin > 0
                nElements = size(CofeElements,1);
                for i = 1:nElements
                    obj(i,1) = VtkCellQuad();
                    obj(i,1).eid = CofeElements(i).eid;
                    obj(i,1).vertices = CofeElements(i).g;
                end
            end
        end
        function print_sub(obj,fid,pointID) 
            % print to VtkFile
            userVertices=[obj.vertices];
            [~,base1index] = ismember(userVertices,pointID);

            fprintf(fid,'4 %d %d %d %d\n',base1index-1);
        end
    end
    
end

