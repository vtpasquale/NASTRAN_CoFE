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
    end
    methods (Sealed = true)
        function obj = printTextOutput(obj,model,fid)
            % Function to print solver array output to text file
            % Input Solver array can include all subcases. The Model array
            % input must be consistent
            
            % Check inputs
            [nRowsSolver,nColumnsSolver]=size(obj);
            [nRowsModel,nColumnsModel]=size(model);
            nCases = size(model(1).caseControl,1);
            if nRowsSolver~=nCases; error('The solver object array  in inconsistent with the residual structure case control array.'); end
            if nColumnsSolver~=nRowsModel; error('nColumnsSolver~=nRowsModel'); end
            if nColumnsModel~=1; error('nColumnsModel~=1'); end
            
            % Loop through subcases and superelements
            for caseIndex = 1:nCases
                
                % Subcase heading
                model(1).caseControl(caseIndex).printTextOutputSubcaseHeading(fid)
                
                if isa(obj,'ModesSolver')
                    headingVector = obj(1).eigenvalueTable.frequency;
                    
                    % Eigenvalue table
                    obj(1).eigenvalueTable.printTextOutput(fid)
                else
                    headingVector = [];
                end
                
                for superElementIndex = 1:nRowsModel
                    obj(caseIndex,superElementIndex).printTextOutput_sub(model(superElementIndex),fid,headingVector);
                end
            end           
        end
    end
    methods (Sealed = true, Access = private)
        function obj = printTextOutput_sub(obj,model,fid,headingVector)
            % Function to print solver output to text file.
            [nRowsSolver,nColumnsSolver]=size(obj);
            [nRowsModel,nColumnsModel]=size(model);
            if any([nRowsSolver,nColumnsSolver,nRowsModel,nColumnsModel]~=1); error('Arrays Solver and/or Model inputs not allowed.'); end
                 
            % Heading data
            caseControl = model.caseControl(obj.caseControlIndex);
            fixedHeading = sprintf('\n\n     TITLE: %-60s    ANALYSIS: %s\n  SUBTITLE: %-60sSUPERELEMENT: %d\n     LABEL: %-60s     SUBCASE: %d\n',...
                caseControl.title,caseControl.analysis,caseControl.subtitle,model.superElementID,caseControl.label,caseControl.subcase);
            if isa(obj,'ModesSolver')
                vectorHeadingString = ' FREQUENCY: %E Hz\n';
                outputHeading = OutputHeading(fixedHeading,vectorHeadingString,headingVector);
            else
                outputHeading = OutputHeading(fixedHeading);
            end
            
            % Node Output Data
            if ~isempty(obj.displacement_g)
                obj.displacement_g.printTextOutput(fid,outputHeading)
            end
            if ~isempty(obj.spcforces_g)
                obj.spcforces_g.printTextOutput(fid,outputHeading)
            end
            
            % Element Output Data
            if ~isempty(obj.stress)
                obj.stress.printTextOutput(fid,model,outputHeading)
            end
            
        end 
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