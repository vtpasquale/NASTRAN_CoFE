% Abstract superclass for CoFE analysis solvers
% Anthony Ricciardi
%
classdef (Abstract) Solver < matlab.mixin.Heterogeneous
    methods (Abstract)
        % The class constructor must...
        
        % Run subcase analysis
        obj=solve_sub(obj,caseControl,model)
        
        % Output subcase results
        obj = output_sub(obj,caseControl,fid)
    end
    methods (Sealed = true)
        function obj = solve(obj,caseControl,model)
            for i = 1:size(obj,1)
                obj(i)=solve_sub(obj(i),caseControl(i),model);
            end
        end % solver()
        function obj = output(obj,caseControl,modelParam,fid)
            % Check check for PARAM,POST,-1
            if any(strcmp(modelParam(:,1),'POST') & strcmp(modelParam(:,2),'-1'))
                writeFemapFlag = true;
            else
                writeFemapFlag = false;
            end
            
            % Write text output and construct Femap data blocks
            fileText = fileread('outputFileText.txt');
            fprintf(fid,fileText);
            fprintf(fid,'  This case was run %s \n',datestr(now));
            for i = 1:size(obj,1)
                caseControl(i).output(fid)
                obj(i) = output_sub(obj(i),caseControl(i),writeFemapFlag,fid);
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
    methods (Sealed = true, Static = true)
        function solver = constructFromCaseControl(caseControl)
            % construct Solver object array from CaseControl object array
            for i = 1:size(caseControl,1)
                % convert field 1 to case-sensitive class name
                analysisType = lower(caseControl(i).analysis);
                if isempty(analysisType)
                    error('Analysis type not defined. Check SOL entry and/or Case Control ANALYSIS entries.')
                end        
                analysisType(1) = upper(analysisType(1));
                % check that input entry is supported
                if exist([analysisType,'Solver'],'class')==8
                    % Call contructor method for each Solver
                    eval(['solver(i,1) = ',analysisType,'Solver();']);
                else
                    error('Analysis type %s not supported. Check SOL entry and/or Case Control ANALYSIS entries.',upper(analysisType))
                end
            end
        end % constructFromCaseControl()
    end
end