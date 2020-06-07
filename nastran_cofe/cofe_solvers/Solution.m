% Abstract superclass for CoFE analysis solutions
% Anthony Ricciardi
%
classdef (Abstract) Solution < matlab.mixin.Heterogeneous
    properties
        caseControlIndex % [1,1 uint32]
    end
    properties (Hidden=true)
        baseHdf5DomainID % [1,1 uint32]
        vectorHdf5DomainID % [nResponseVectors,1 uint32]
    end
    methods (Abstract)
        % The class constructor must...
        
        % Run subcase analysis
        obj=solve_sub(obj,model,caseControlIndex)
        
        % Convert solution data to Hdf5 domain data and set obj.baseHdf5DomainID & obj.vectorHdf5DomainID values
        [obj,hdf5Domains] = solution2Hdf5Domains(obj,model)
        
    end
    methods (Sealed = true)
        function obj = solve(obj,model)
            % Function to solve all subcases
            %
            % INPUTS
            % obj = [nSubcases,nSuperElements Solution] Array of Solution objects
            % model = [nSuperElements,1 Model] Array of Model objects
            %
            % OUTPUT
            % obj = [nSubcases,nSuperElements Solution] Array of Solution objects
            
            for i = 1:size(obj,1)
                obj(i,:)=solve_sub(obj(i,:),model); % defined in subclass
            end
        end % solve()
        function output(obj,inputFile,model)
            % Function to ouput solution data
            [~,outputFile] = fileparts(inputFile);
            obj.printTextOutput(model,[outputFile,'.out']);
            
        end % output()
        function printTextOutput(obj,model,outputFile)
            % Function to print Solution array output to text file
            % Input Solution array can include all subcases. The Model array
            % input must be consistent with the Solution array
            fid = fopen(outputFile,'w+');
            
            % Check inputs
            [nRowsSolution,nColumnsSolution]=size(obj);
            [nRowsModel,nColumnsModel]=size(model);
            nCases = size(model(1).caseControl,1);
            if nRowsSolution~=nCases; error('The solution object array  in inconsistent with the residual structure case control array.'); end
            if nColumnsSolution~=nRowsModel; error('nColumnsSolution~=nRowsModel'); end
            if nColumnsModel~=1; error('nColumnsModel~=1'); end
            
            % Loop through subcases
            for caseIndex = 1:nCases
                
                % Output file heading
                caseControl = model(1).caseControl(caseIndex);
                caseControl.printTextOutputSubcaseHeading(fid);
                outputHeading = OutputHeading(caseControl,0);
                
                if isa(obj(caseIndex,1),'ModesSolution')
                    outputHeading.headingVector = obj(caseIndex,1).eigenvalueTable.frequency;
                    outputHeading.headingVectorText = ' FREQUENCY: %E Hz\n';
                    
                    % Print Eigenvalue table
                    obj(caseIndex,1).eigenvalueTable.printTextOutput(fid)
                end
                
                % Loop through superelements
                for superElementIndex = 1:nRowsModel
                    obj(caseIndex,superElementIndex).printTextOutput_sub(model(superElementIndex),fid,outputHeading);
                end
            end
            fclose(fid);
        end % printTextOutput()
        function hdf5 = solution2Hdf5(obj,model)
            % Convert solution data to Hdf5 data
            %
            % INPUTS
            % obj   [nSubcases,nSuperElements Solution]
            % model [nSuperElements,1 Model]        
            %
            % OUTPUTS
            % hdf5 [HDF5] HDF5 output file object
            
            % Check inputs
            [nRowsSolution,nColumnsSolution]=size(obj);
            [nModel,nColumnsModel]=size(model);
            nCases = size(model(1).caseControl,1);
            if nRowsSolution~=nCases; error('The solution object array is inconsistent with the residual structure case control array.'); end
            if nColumnsSolution~=nModel; error('nColumnsSolution~=nModel'); end
            if nColumnsModel~=1; error('nColumnsModel~=1'); end
            
            % create Hdf5 instance
            hdf5 = Hdf5();
            
            % Model superelements domain data to HDF5 subcase 0
            modelDomains = model.model2Hdf5Domains();
            hdf5.domains = Hdf5Domains(modelDomains);
                        
            % Append Hdf5 domain data for all analysis subcases
            for caseIndex = 1:nCases
                startDomainId = hdf5.domains.ID(end)+1;
                [obj(caseIndex,:),caseIndexDomains] = obj(caseIndex,:).solution2Hdf5Domains(model,startDomainId);
                hdf5.domains = hdf5.domains.appendStruct(caseIndexDomains);
            end
            
            % write HDF5 element results data for all analysis subcases
            
            
        end % solution2Hdf5()
        
    end
    methods (Sealed = true, Access = private)
        function printTextOutput_sub(obj,model,fid,outputHeading)
            % Function to print solution output to text file.
            [nRowsSolution,nColumnsSolution]=size(obj);
            [nRowsModel,nColumnsModel]=size(model);
            if any([nRowsSolution,nColumnsSolution,nRowsModel,nColumnsModel]~=1); error('Arrays Solution and/or Model inputs not allowed.'); end
            
            % Set output heading superlement ID
            outputHeading.superElementID = model.superElementID;
            
            caseControl = model.caseControl(obj.caseControlIndex);
            
            % Node Output Data
            if ~isempty(obj.displacement) && caseControl.displacement.print
                obj.displacement.printTextOutput(fid,outputHeading)
            end
            if ~isempty(obj.spcforces) && caseControl.spcforces.print
                obj.spcforces.printTextOutput(fid,outputHeading)
            end
            
            % Element Output Data
            if ~isempty(obj.force) && caseControl.force.print
                obj.force.printTextOutput(fid,model,outputHeading)
            end
            if ~isempty(obj.strain) && caseControl.strain.print
                obj.strain.printTextOutput(fid,model,outputHeading)
            end
            if ~isempty(obj.stress) && caseControl.stress.print
                obj.stress.printTextOutput(fid,model,outputHeading)
            end
            if ~isempty(obj.ese) && caseControl.ese.print
                obj.ese.printTextOutput(fid,model,outputHeading)
            end
        end % printTextOutput_sub()
    end
    methods (Sealed = true, Static = true)
        function solution = constructFromModel(model)
            % Function to intialize a solution array from a model array
            %
            % INPUTS
            % model [nSuperElements,1 Model]
            %
            % OUTPUTS
            % solution [nSubcases,nSuperElements Solution]
            
            % check input
            [nModel,mModel] = size(model);
            if nModel < 1; error('size(model,1)<1');end
            if mModel ~=1; error('size(model,2)~=1');end
            
            % construct Solution array
            for i = 1:size(model(1).caseControl,1)
                % convert field 1 to case-sensitive class name
                analysisType = lower(model(1).caseControl(i).analysis);
                if isempty(analysisType)
                    error('Analysis type not defined. Check SOL entry and/or Case Control ANALYSIS entries.')
                end        
                analysisType(1) = upper(analysisType(1));
                % check that input entry is supported
                if exist([analysisType,'Solution'],'class')==8
                    
                    % Call contructor method for each Solution
                    eval(['solution(i,1:nModel) = ',analysisType,'Solution();']);
                    
                    % Assign the case control index for each superelement
                    for j = 1:nModel
                        solution(i,j).caseControlIndex = uint32(i);
                    end
                else
                    error('Analysis type %s not supported. Check SOL entry and/or Case Control ANALYSIS entries.',upper(analysisType))
                end
            end
        end % constructFromModel()
    end
end