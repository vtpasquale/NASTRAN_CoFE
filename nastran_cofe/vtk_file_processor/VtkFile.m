classdef VtkFile
    % class for vtk files - simple legacy format
    %
    % See File Formats for VTK Version 4.2, Kitware
    % This class implementation supports unstructured grids only
    
    % Anthony Ricciardi
    % October 2021

    properties (Constant = true)
        LINE_ONE = '# vtk DataFile Version 3.0\n'; % [char]  file version and identifier.
    end
    properties
        header = 'CoFE Output'% [char] The header consists of a character string terminated by end-of-line character '\n'. The header is 256 characters maximum. The header can be used to describe the data and include any other pertinent information.
    end
    properties (Constant = true)
        FILE_FORMAT = 'ASCII'; % [char]  file format.
    end
    properties
        vtkPoints % [VtkPoints] Points object
        vtkCells % [VtkCells] Cell object array
        pointData % [VtkVector] Vector results data
        cellData % [VtkScalar] Scalar results data
    end
    properties (Hidden=true)
       sizeCells % [uint32] total number of integers is CELLS data block
    end
    
    methods
        function obj = VtkFile(cofe)
            % Class constructed from Cofe object
            if size(cofe.model,1)~=1; error('Vtk files do not support superelements'); end
            
            % model data (superelement 0 only)
            obj.vtkPoints = VtkPoints(cofe.model(1).point(cofe.model(1).nodeFlag) );
            [obj.vtkCells,obj.sizeCells]= VtkCells.elements2cells(cofe.model(1).element);
            
            if ~isempty(cofe.solution)
                obj.pointData = VtkVector.fromSolution(cofe.solution,obj.vtkPoints.pointID);
                obj.cellData  = VtkScalar.fromSolution(obj,cofe); % .solution,[obj.vtkCells.eid].',[obj.vtkCells.resultType].');
            end
                
        end
        function print(obj,filename)
            % print to VTK file
            fid = fopen(filename,'w+');
            
            fprintf(fid,obj.LINE_ONE);
            fprintf(fid,'%s\n',obj.header);
            fprintf(fid,'ASCII\n');
            
            fprintf(fid,'\nDATASET UNSTRUCTURED_GRID\n');
            obj.vtkPoints.print(fid);
            obj.vtkCells.print(fid,obj.sizeCells,obj.vtkPoints.pointID);
            
            fprintf(fid,'POINT_DATA %d\n',size(obj.vtkPoints.points,1));
            obj.pointData.print(fid)
            
            fprintf(fid,'CELL_DATA %d\n',size(obj.vtkCells,1));
            obj.cellData.print(fid)
            
            fclose(fid);
        end
    end
    
end

