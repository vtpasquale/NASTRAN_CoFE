% Class for output data at elements
% Anthony Ricciardi
%
classdef ElementOutputData
    
    properties
        elementID % [uint32] Output element identification number
        elementType % [uint8] NASTRAN element code corresponding to NASTRAN item codes documentation
        responseType % [uint8] CoFE code specifying response type [1=FORCE,2=STRESS,3=STRAIN,4=STRAIN ENERGY,5=KINETIC ENERGY]
        values % [nItems,nResponseVectors double] Element output data
        %         stress % [nElementStressItemCodes,nResponseVectors] Stress values according to NASTRAN item codes documentation
        %         strain % [nElementStrainItemCodes,nResponseVectors] Strain values according to NASTRAN item codes documentation
        %         force % [nElementForceItemCodes,nResponseVectors] Element force values according to NASTRAN item codes documentation
        %         ese % [1,nResponseVectors] Element strain energy
        %         eke % [1,nResponseVectors] Element kinetic energy
    end
    methods
        function obj = ElementOutputData(elementID,elementType,responseType,values)
            if nargin > 0
                obj.elementID = elementID;
                obj.elementType = elementType;
                obj.responseType = responseType;
                obj.values = values;
            end
        end
        
% set methods slowing things down way too much        
%         function obj = set.elementType(obj,in)
%             if isnumeric(in)==0; error('ElementOutputData.elementType must be a number'); end
%             if mod(in,1) ~= 0; error('ElementOutputData.elementType must be an integer'); end
%             if in < 1 || in > 255; error('ElementOutputData.responseType must be greater than zero and less than 255.'); end
%             obj.elementType=uint8(in);
%         end
%         function obj = set.responseType(obj,in)
%             if isnumeric(in)==0; error('ElementOutputData.responseType must be a number'); end
%             if mod(in,1) ~= 0; error('ElementOutputData.responseType must be an integer'); end
%             if in < 1 || in > 5; error('ElementOutputData.responseType must be greater than zero and less than 6.'); end
%             obj.responseType=uint8(in);
%         end

        function printTextOutput(obj,fid,model,outputHeading)
            % Prints an array of ElementOutputData objects of a single
            % responseType (e.g., stress) for a single superelement and single subcase
            if size(unique([obj.responseType]),1)~=1; error('Input array elementOutputData should have uniform responseType properties.'); end
            elementTypes = [obj.elementType];
            uniqueElementTypes = unique(elementTypes);
            % Loop through element types
            for i = 1:size(uniqueElementTypes,1)
                elementOutputDataI = obj(elementTypes==uniqueElementTypes(i));
                elementIndex = ismember(model.elementEIDs,[elementOutputDataI.elementID]);
                firstElementIndex = find(elementIndex,1);
                
                nElementsI = size(elementOutputDataI,1);
                [nItemsI,nResponseVectors] = size(elementOutputDataI(1).values);
                
                idI = double([elementOutputDataI.elementID]);
                valuesI = [elementOutputDataI.values];
                
                % rearrange data so response vector is third index
                valuesMat = zeros(nElementsI,nItemsI,nResponseVectors);
                for j = 1:nItemsI
                    for k = 1:nResponseVectors
                        valuesMat(:,j,k) = valuesI(j,k:nResponseVectors:end).';
                    end
                end
                
                switch elementOutputDataI(1).responseType
                    case 1 % FORCE
                        items = model.element(firstElementIndex).FORCE_ITEMS;
                        titleText = 'F O R C E S   I N   ';
                    case 2 % STRESS
                        items = model.element(firstElementIndex).STRESS_ITEMS;
                        titleText = 'S T R E S S E S   I N   ';
                    case 3 % STRAIN
                        items = model.element(firstElementIndex).STRAIN_ITEMS;
                        titleText = 'S T R A I N S   I N   ';
                    case 4 % STRAIN ENERGY
                        items = {'STRAIN ENERGY','S.E. PERCENT','S.E. DENSITY'};
                        titleText = ' S T R A I N   E N E R G Y   I N   ';
                    case 5 % KINETIC ENERGY
                        items = {'STRAIN ENERGY','K.E. PERCENT','K.E. DENSITY'};
                        titleText = 'K I N E T I C   E N E R G Y   I N   ';
                    otherwise
                        error('Element responseType=%d not supported.',elementOutputDataI(1).responseType)
                end
                
                for j = 1:nResponseVectors
                    outputHeading.printTextOutput(fid,j)
                    fprintf(fid, '\n\n        %s%s\n',titleText,model.element(firstElementIndex).PAGE_TITLE);
                    fprintf(fid,['%14s',repmat('%15s',[1,nItemsI]),'\n'],'ELEM ID',items{:});
                    fprintf(fid,['%14d',repmat('%15E',[1,nItemsI]),'\n'],[idI;valuesMat(:,:,j).']);
                end
            end
        end % printTextOutput()
        
    end
end
