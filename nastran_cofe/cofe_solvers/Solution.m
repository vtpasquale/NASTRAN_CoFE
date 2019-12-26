% Abstract superclass for CoFE analysis solutions
% Anthony Ricciardi
%
classdef (Abstract) Solution < matlab.mixin.Heterogeneous
    properties
        caseControlIndex % uint32
    end
    methods (Abstract)
        % The class constructor must...
        
        % Run subcase analysis
        obj=solve_sub(obj,model,caseControlIndex)
        
        % Output subcase results
        femapDataBlock = constructFemapAnalysisSet(obj,femapDataBlock,caseControl)
        femapDataBlock = constructFemapOutputSets(obj,femapDataBlock,caseControl,outputHeading)
    end
    methods (Sealed = true)
        function obj = solve(obj,model)
            % Function to solve all subcases
            for i = 1:size(obj,1)
                obj(i,:)=solve_sub(obj(i,:),model);
            end
        end % solve()
        function output(obj,inputFile,model)
            % Function to ouput solution data
            [~,outputFile] = fileparts(inputFile);
            obj.printTextOutput(model,[outputFile,'.out']);
            
            femapDataBlock = obj.constructFemapDataBlocks(model);
            femapDataBlock.writeNeutral([outputFile,'.neu']);
        end % output
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
        function femapDataBlock = constructFemapDataBlocks(obj,model)
            % Function to write Solution array output to a Femap Neutral file data blocks
            % Input Solution array can include all subcases. The Model array
            % input must be consistent with the Solution array
            
            % Check inputs
            [nRowsSolution,nColumnsSolution]=size(obj);
            [nRowsModel,nColumnsModel]=size(model);
            nCases = size(model(1).caseControl,1);
            if nRowsSolution~=nCases; error('The solution object array  in inconsistent with the residual structure case control array.'); end
            if nColumnsSolution~=nRowsModel; error('nColumnsSolution~=nRowsModel'); end
            if nColumnsModel~=1; error('nColumnsModel~=1'); end
            
            % File Heading 
            femapDataBlock = FemapDataBlock100();          
            
            % Loop through subcases
            for caseIndex = 1:nCases
                
                % Use OutputHeading object to store subcase data
                caseControl = model(1).caseControl(caseIndex);
                outputHeading = OutputHeading(caseControl,0);
                if isa(obj(caseIndex,1),'ModesSolution')
                    outputHeading.headingVector = obj(caseIndex,1).eigenvalueTable.frequency;
                    outputHeading.headingVectorText = ' FREQUENCY: %E Hz\n';
                end
                
                % Create analysis study for each subcase (Not typical, but done here because CoFE allows different analysis types in the same run)
                femapDataBlock = obj(caseIndex,1).constructFemapAnalysisSet(femapDataBlock,caseControl);

                % Loop through superelements to create output sets and output vectors
                for superElementIndex = 1:nRowsModel
                    
                    % Create output set data blocks for each subcase mode using a subclass method
                    femapDataBlock = obj(caseIndex,1).constructFemapOutputSets(femapDataBlock,caseControl,outputHeading);
                    
                    % Create output vector data blocks for each subcase mode using a subclass method
                    femapDataBlock = obj(caseIndex,superElementIndex).constructFemapDataBlocks_sub(femapDataBlock,model(superElementIndex),outputHeading);
                    
                    % Advance staring index
                    % Update so that this only runs if output is created for this
                    % superelement
                    if isa(obj,'ModesSolution')
                        femapDataBlock(1) = femapDataBlock(1).advanceOutputSet(size(outputHeading.headingVector,1));
                    else
                        femapDataBlock(1) = femapDataBlock(1).advanceOutputSet(1);
                    end
            
                end
            end           
        end % writeFemapNeutral()
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
            if ~isempty(obj.displacement_g) && caseControl.displacement.print
                obj.displacement_g.printTextOutput(fid,outputHeading)
            end
            if ~isempty(obj.spcforces_g) && caseControl.spcforces.print
                obj.spcforces_g.printTextOutput(fid,outputHeading)
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
            if ~isempty(obj.strainEnergy) && caseControl.ese.print
                obj.strainEnergy.printTextOutput(fid,model,outputHeading)
            end
        end % printTextOutput_sub()
        function femapDataBlock = constructFemapDataBlocks_sub(obj,femapDataBlock,model,outputHeading)
            % Function to print solution output to text file.
            [nRowsSolution,nColumnsSolution]=size(obj);
            [nRowsModel,nColumnsModel]=size(model);
            if any([nRowsSolution,nColumnsSolution,nRowsModel,nColumnsModel]~=1); error('Arrays Solution and/or Model inputs not allowed.'); end
            
            % Set output heading superlement ID
            outputHeading.superElementID = model.superElementID;
            % caseControl = model.caseControl(obj.caseControlIndex);
            
            startID = femapDataBlock(1).currentOutputSet;

            % Node Output Data
            if ~isempty(obj.displacement_0) % && ~caseControl.displacement.print
                femapDataBlock = [femapDataBlock;obj.displacement_0.convert_2_FemapDataBlock1051(startID)];
            end            
            if ~isempty(obj.spcforces_0) % && ~caseControl.spcforces.print
                femapDataBlock = [femapDataBlock;obj.spcforces_0.convert_2_FemapDataBlock1051(startID)];
            end
            
%             % Element Output Data
%             if ~isempty(obj.stress) && caseControl.stress.print
%                 obj.stress.printTextOutput(fid,model,outputHeading)
%             end
        end % writeFemapNeutral_sub()
    end
    methods (Sealed = true, Static = true)
        function solution = constructFromModel(model)
            % check input
            [nModel,mModel] = size(model);
            if nModel < 1; error('size(model,1)<1');end
            if mModel ~=1; error('size(model,2)~=1');end
            % construct Solution object array from CaseControl object array
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