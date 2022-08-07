classdef VtkScalar
    % class for vtk scalar data
    
    properties
        dataName % [char]
        data     % [n,1 double] data
    end
    
    methods
        function obj = VtkScalar(dataIn,dataNameIn)
            if nargin > 0
                if size(dataIn,2)~=1; error('Scalar data dimension issue'); end
                obj.data = dataIn;
                obj.dataName = dataNameIn;
            end
        end
        function print(obj,fid)
            % print to vtk file
            for i = 1:size(obj,1)
                fprintf(fid,'SCALARS %s float\n',obj(i).dataName);
                fprintf(fid,'LOOKUP_TABLE default\n');
                fprintf(fid,'%f\n',obj(i).data);
            end
        end
    end
    methods (Static=true)
        function vtkScalar = fromSolution(vtkFile,cofe)
            % Creates vtk cell output VtkFile and Cofe objects
            nSubCases = size(cofe.solution,1);
            outputs = {'force','stress','strain','ese','eke'};
            vtkScalar = VtkScalar();
            index = 0;
            
            % Loop over subcases
            for i = 1:nSubCases
                
                % Loop over output types
                for j = 1:5
                    if ~isempty(cofe.solution(i,1).(outputs{j}))
                        vtkScalarNext = VtkScalar.fromCellOutputData(vtkFile.vtkCells,cofe.solution(i,1).(outputs{j}),cofe.model.element,i);
                        addIndex = size(vtkScalarNext,1);
                        vtkScalar(index+1:index+addIndex,:) = vtkScalarNext;
                        index = index + addIndex;
                    end
                end
                
            end
        end % fromSolution()
        
        function vtkScalar = fromCellOutputData(vtkCells,elementOutputData,elements,subcaseNumber)
            
            % EID sets
            vtkCellEids = [vtkCells.eid].';
            elementOutputEids = [elementOutputData.elementID].';
            elementEids = [elements.eid].';
            
            % counting
            nVtkCells = size(vtkCellEids,1);
            nResponseVectors = size(elementOutputData(1).values,2);
            
            % get the elements for which there is output
            hasOutput = ismember(elementEids,elementOutputEids);
            elementsWithOutput = elements(hasOutput);
            
            % get the resultType for the elementOutputData from elements
            elementsVtkResultType = [elementsWithOutput.vtk_result_type_access].';
            
            uniqueVtkResultTypes = unique(elementsVtkResultType);
            vtkScalar = VtkScalar();
            vtkScalarIndex = 0;
            % Loop through VTK result types
            for i = 1:size(uniqueVtkResultTypes,1)
                
                % model elements for this vtk result type
                elementsI = elementsWithOutput(elementsVtkResultType==uniqueVtkResultTypes(i));
                
                % output data for these model elements (for this vtk result type)
                outDataFlag = ismember(elementOutputEids,[elementsI.eid].');
                outDataI = elementOutputData(outDataFlag);
                
                % output data location in vtkCells order
                [vtkDataFlag,vtkDataLocation]=ismember([outDataI.elementID].',vtkCellEids);
                if any(~vtkDataFlag); error('Output processing issue'); end
                    
                % rearrange output values so response vector is third index
                valuesI = [outDataI.values];
                nItemsI = size(outDataI(1).values,1);
                nOutElementsI = size(outDataI,1);
                valuesMat = zeros(nOutElementsI,nItemsI,nResponseVectors);
                for j = 1:nItemsI
                    for k = 1:nResponseVectors
                        valuesMat(:,j,k) = valuesI(j,k:nResponseVectors:end).';
                    end
                end
                
%                 % vtk cells for these output data
%                 vtkCellFlag = ismember(vtkCellEids,[outDataI.elementID].');
                                
                % [1=FORCE,2=STRESS,3=STRAIN,4=STRAIN ENERGY,5=KINETIC ENERGY]
                switch outDataI(1).responseType
                    case 1
                        itemNames = elementsI(1).FORCE_ITEMS;
                        typeName = '_Force';
                    case 2
                        itemNames = elementsI(1).STRESS_ITEMS;
                        typeName = '_Stress';
                    case 3
                        itemNames = elementsI(1).STRAIN_ITEMS;
                        typeName = '_Strain';
                    case 4
                        itemNames = {'Strain_Energy','Strain_Energy_Percent','Strain_Energy_Density'};
                        typeName = '';
                    case 5
                        itemNames = {'Kinetic_Energy','Kinetic_Energy_Percent','Kinetic_Energy_Density'};
                        typeName = '';
                    otherwise
                        error('Response type not recognized')
                end
                nItems = size(itemNames,2);
                if nItems~=nItemsI; error('Output data issue'); end
                
                % store data in vtkScalar array
                for j = 1:nItemsI
                    for k = 1:nResponseVectors
                        vtkScalarIndex = vtkScalarIndex + 1;
                        vtkScalar(vtkScalarIndex,1).dataName = sprintf('Sc%d_Vec%d%s_%s',subcaseNumber,k,typeName,itemNames{j});
                        vtkScalar(vtkScalarIndex,1).data = zeros(nVtkCells,1);
                        vtkScalar(vtkScalarIndex,1).data(vtkDataLocation) = valuesMat(:,j,k);
                    end
                end
            end
        end % fromCellOutputData()
        
    end
end

