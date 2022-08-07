classdef (Abstract) VtkCells < matlab.mixin.Heterogeneous
    % Abstract superclass for vtk cells
    
    % Anthony Ricciardi
    % October 2021
    
%     properties (Constant = true,Hidden=true)
%         NUM_POINTS % [uint32] number of points per cell
%         CELL_TYPE % [uint32] vtk cell type ID
%     end
    properties (Abstract)
        eid % [uint32] user-defined ID used for results mapping.
    end
    methods (Abstract)
        print_sub(obj,fid) % print to VtkFile
    end
    properties (Hidden=true,Dependent=true)
       cell_type_access % dependent property workaround to allow concatenation of [VtkCells.CELL_TYPE] as [VtkCells.cell_type_access]
    end
    methods
        function value = get.cell_type_access(obj)
            % This is a workaround to allow concatenation of [VtkCells.CELL_TYPE] as [VtkCells.cell_type_access]
            value = obj.CELL_TYPE;
        end
    end
    methods (Static=true, Sealed=true)
        function [obj,sizeCells]= elements2cells(CofeElements)
            % create VtkCells from CoFE Elements
            % sizeCells [uint32] total number of integers is CELLS data block
            
            % identify unique cell types
            cellTypes = [CofeElements.vtk_cell_type_access].';
            uniqueCellTypes = unique(cellTypes);
            nUniqueCellTypes = size(uniqueCellTypes,1);
            
            % loop over unique types and create cell objects
            nCells = 0;
            sizeCells = 0;
            for i = 1:nUniqueCellTypes
                cellType = uniqueCellTypes(i);
                elements = CofeElements(cellTypes==cellType);
                objAppend = feval(elements(1).VTK_CELL_CLASSNAME,elements);
                nAppend = size(objAppend,1);
                sizeCells = sizeCells + nAppend*(1+objAppend(1).NUM_POINTS);
                obj(nCells+1:nCells+nAppend,1) = objAppend;
                nCells = nCells+nAppend;
            end
        end
    end
    methods (Sealed=true)
        function print(obj,fid,sizeCells,pointID)
            % print to vtk file
            nCells = size(obj,1);
            fprintf(fid,'CELLS %d %d\n',nCells,sizeCells);
            
            % print cells in blocks by type
            cellTypes = [obj.cell_type_access].';
            uniqueCellTypes = unique(cellTypes);
            nUniqueCellTypes = size(uniqueCellTypes,1);
            for i = 1:nUniqueCellTypes
                cellType = uniqueCellTypes(i);
                obj(cellTypes==cellType).print_sub(fid,pointID);
            end
            
%             % print cells
%             cellTypes = [obj.cell_type_access].';
%             for i = 1:nCells
%                 obj(i).print_sub(fid,pointID);
%             end

            % types 
            fprintf(fid,'CELL_TYPES %d\n',nCells);
            fprintf(fid,'%d\n',cellTypes);
                        
        end
    end
end

