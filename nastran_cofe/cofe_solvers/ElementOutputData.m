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
            obj.elementID = elementID;
            obj.elementType = elementType;
            obj.responseType = responseType;
            obj.values = values;
        end
        function obj = set.elementType(obj,in)
            if isnumeric(in)==0; error('ElementOutputData.elementType must be a number'); end
            if mod(in,1) ~= 0; error('ElementOutputData.elementType must be an integer'); end
            if in < 1 || in > 255; error('ElementOutputData.responseType must be greater than zero and less than 255.'); end
            obj.elementType=uint8(in);
        end
        function obj = set.responseType(obj,in)
            if isnumeric(in)==0; error('ElementOutputData.responseType must be a number'); end
            if mod(in,1) ~= 0; error('ElementOutputData.responseType must be an integer'); end
            if in < 1 || in > 5; error('ElementOutputData.responseType must be greater than zero and less than 6.'); end
            obj.responseType=uint8(in);
        end
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
                elementTypeObj = model.element(elementIndex);
                elementTypeObj.printTextOutput(fid,elementOutputDataI,outputHeading)
            end
        end
        function femapDataBlock = convert_2_FemapDataBlock1051(obj,model,startSetID)
            femapDataBlock = [];
            elementTypes = [obj.elementType];
            uniqueElementTypes = unique(elementTypes);
            for i = 1:size(uniqueElementTypes,2)
                index = elementTypes==uniqueElementTypes(i);
                oi = obj(index);
                elementIDs = [oi.elementID].';
                modelIndex = ismember(elementIDs,model.elementEIDs);
                rType=unique([oi.responseType]);
                if size(rType,2)~=1; error('There is more than one response type in the call to convert_2_db1051. Data processing should have prevented this.'); end
                switch rType
                    case 1
                        femapDataBlock = [femapDataBlock;model.element(modelIndex).force_2_FemapDataBlock1051(oi,startSetID)];
                    case 2
                        femapDataBlock = [femapDataBlock;model.element(modelIndex).stress_2_FemapDataBlock1051(oi,startSetID)];
                end
            end
        end
    end
end
