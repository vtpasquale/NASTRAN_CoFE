% Abstract superclass for CoFE analysis solvers
% Anthony Ricciardi
%
classdef (Abstract) Solver < matlab.mixin.Heterogeneous
    properties
        caseControlIndex % uint32
    end
    methods (Abstract)
        % The class constructor must...
        
        % Run subcase analysis
        obj=solve_sub(obj,model,caseControlIndex)
        
        % Output subcase results
        obj = output_sub(obj,caseControl,fid)
    end
    methods (Sealed = true)
        function obj = solve(obj,model)
            for i = 1:size(obj,1)
                obj(i,:)=solve_sub(obj(i,:),model);
            end
        end % solver()
        function obj = output(obj,model,fid)
            [nSolver,mSolver]=size(obj);
            if nSolver > 1; error('Solver.output() does not handle arrays of Solver objects'); end
            if mSolver > 1; error('Solver.output() does not handle arrays of Solver objects'); end
            [nModel,mModel]=size(model);
            if nModel > 1; error('Solver.output() does not handle arrays of Model objects'); end
            if mModel > 1; error('Solver.output() does not handle arrays of Model objects'); end
            
            % Write solver output
            paramPost = model.parameter.getParameter('POST');
            % Check check for PARAM,POST,-1
            if strcmp(paramPost,'-1')
                writeFemapFlag = true;
            else
                writeFemapFlag = false;
            end
            
            % Write text output and construct Femap data blocks
            fileText = fileread('outputFileText.txt');
            fprintf(fid,fileText);
            fprintf(fid,'  This case was run %s \n',datestr(now));
            for i = 1:size(obj,1)
                model.caseControl(i).output(fid)
                obj(i) = obj(i).output_sub(model.caseControl(i),writeFemapFlag,fid);
            end
            
            % Write Femap neutral file
            if writeFemapFlag
                allFemapDataBlocks = [];
                for i = 1:size(obj,1)
                    allFemapDataBlocks = [allFemapDataBlocks;obj(i).femapDataBlock];
                end
                allFemapDataBlocks.writeNeutral(fid)
            end
        end % output()
        function printTextOutput(obj,model,fid)
            % Function to print Solver array output to text file
            % Input Solver array can include all subcases. The Model array
            % input must be consistent with the Solver array
            
            % Check inputs
            [nRowsSolver,nColumnsSolver]=size(obj);
            [nRowsModel,nColumnsModel]=size(model);
            nCases = size(model(1).caseControl,1);
            if nRowsSolver~=nCases; error('The solver object array  in inconsistent with the residual structure case control array.'); end
            if nColumnsSolver~=nRowsModel; error('nColumnsSolver~=nRowsModel'); end
            if nColumnsModel~=1; error('nColumnsModel~=1'); end
            
            % Loop through subcases
            for caseIndex = 1:nCases
                
                % Output file heading
                caseControl = model(1).caseControl(caseIndex);
                caseControl.printTextOutputSubcaseHeading(fid);
                outputHeading = OutputHeading(caseControl,0);
                
                if isa(obj(caseIndex,1),'ModesSolver')
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
        end % printTextOutput()
        function femapDataBlock = writeFemapNeutral(obj,model)
            % Function to write Solver array output to a Femap Neutral file data blocks
            % Input Solver array can include all subcases. The Model array
            % input must be consistent with the Solver array
            
            % Check inputs
            [nRowsSolver,nColumnsSolver]=size(obj);
            [nRowsModel,nColumnsModel]=size(model);
            nCases = size(model(1).caseControl,1);
            if nRowsSolver~=nCases; error('The solver object array  in inconsistent with the residual structure case control array.'); end
            if nColumnsSolver~=nRowsModel; error('nColumnsSolver~=nRowsModel'); end
            if nColumnsModel~=1; error('nColumnsModel~=1'); end
            
            % File Heading 
            femapDataBlock = FemapDataBlock100();          
            
            % Loop through subcases
            for caseIndex = 1:nCases
                
                % Use OutputHeading object to store subcase data
                caseControl = model(1).caseControl(caseIndex);
                outputHeading = OutputHeading(caseControl,0);
                if isa(obj(caseIndex,1),'ModesSolver')
                    outputHeading.headingVector = obj(caseIndex,1).eigenvalueTable.frequency;
                    outputHeading.headingVectorText = ' FREQUENCY: %E Hz\n';
                end
                
                % Create analysis study for each subcase (Not typical, but done here because CoFE allows different analysis types in the same run)
                femapDataBlock = obj(caseIndex,1).writeFemapAnalysisSet(femapDataBlock,caseControl);

                % Loop through superelements to create output sets and output vectors
                for superElementIndex = 1:nRowsModel
                    
                    % Create output set data blocks for each subcase mode using a subclass method
                    femapDataBlock = obj(caseIndex,1).writeFemapOutputSets(femapDataBlock,caseControl,outputHeading);
                    
                    % Create output vector data blocks for each subcase mode using a subclass method
                    femapDataBlock = obj(caseIndex,superElementIndex).writeFemapNeutral_sub(femapDataBlock,model(superElementIndex),outputHeading);
                    
                    % Advance staring index
                    % Update so that this only runs if output is created for this
                    % superelement
                    if isa(obj,'ModesSolver')
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
            % Function to print solver output to text file.
            [nRowsSolver,nColumnsSolver]=size(obj);
            [nRowsModel,nColumnsModel]=size(model);
            if any([nRowsSolver,nColumnsSolver,nRowsModel,nColumnsModel]~=1); error('Arrays Solver and/or Model inputs not allowed.'); end
            
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
            if ~isempty(obj.stress) && caseControl.stress.print
                obj.stress.printTextOutput(fid,model,outputHeading)
            end
            
        end % printTextOutput_sub()
        function femapDataBlock = writeFemapNeutral_sub(obj,femapDataBlock,model,outputHeading)
            % Function to print solver output to text file.
            [nRowsSolver,nColumnsSolver]=size(obj);
            [nRowsModel,nColumnsModel]=size(model);
            if any([nRowsSolver,nColumnsSolver,nRowsModel,nColumnsModel]~=1); error('Arrays Solver and/or Model inputs not allowed.'); end
            
            % Set output heading superlement ID
            outputHeading.superElementID = model.superElementID;
            caseControl = model.caseControl(obj.caseControlIndex);
            
            startID = femapDataBlock(1).currentOutputSet;

            % Node Output Data
            if ~isempty(obj.displacement_0) && caseControl.displacement.print
                femapDataBlock = [femapDataBlock;obj.displacement_0.convert_2_FemapDataBlock1051(startID)];
            end            
            if ~isempty(obj.spcforces_0) && caseControl.spcforces.print
                femapDataBlock = [femapDataBlock;obj.spcforces_0.convert_2_FemapDataBlock1051(startID)];
            end
            
%             % Element Output Data
%             if ~isempty(obj.stress) && caseControl.stress.print
%                 obj.stress.printTextOutput(fid,model,outputHeading)
%             end
        end % writeFemapNeutral_sub()
    end
    methods (Sealed = true, Static = true)
        function solver = constructFromModel(model)
            % check input
            [nModel,mModel] = size(model);
            if nModel < 1; error('size(model,1)<1');end
            if mModel ~=1; error('size(model,2)~=1');end
            % construct Solver object array from CaseControl object array
            for i = 1:size(model(1).caseControl,1)
                % convert field 1 to case-sensitive class name
                analysisType = lower(model(1).caseControl(i).analysis);
                if isempty(analysisType)
                    error('Analysis type not defined. Check SOL entry and/or Case Control ANALYSIS entries.')
                end        
                analysisType(1) = upper(analysisType(1));
                % check that input entry is supported
                if exist([analysisType,'Solver'],'class')==8
                    % Call contructor method for each Solver
                    eval(['solver(i,1:nModel) = ',analysisType,'Solver();']);
                    for j = 1:nModel
                        solver(i,j).caseControlIndex = uint32(i);
                    end
                else
                    error('Analysis type %s not supported. Check SOL entry and/or Case Control ANALYSIS entries.',upper(analysisType))
                end
            end
        end % constructFromModel()
    end
end