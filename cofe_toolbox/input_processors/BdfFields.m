% BdfFields converts Nastran input lines to distinct entries and fields 
% stored as [char] variables in cell/struct arrays. 
% 
% The upstream BdfLines class manages INCLUDE statements, commented 
% lines, inline comments, and partitioning of the inputs to Executive 
% (includes NASTRAN statement and File Management lines) Control, Case 
% Control, and Bulk Data sections. A BdfFields object is constructed from
% a BdfLines object.
% 
% BdfFields Specification
% =======================
% 
% Executive Control Section
% -------------------------
% Reads and stores the first SOL entry and ignores everything else.
% 
% Case Control Section
% --------------------
% The first line of all case control entries is stored. Continuations lines 
% are stored only for SET entries. Nastran input fields are delimited and 
% stored in a cell array of MATLAB structure variables with [char] fields. 
% The [char] fields store the entry name, left hand side describers, and 
% right hand side describers. Left hand side describers are optional.
% 
% EXAMPLE
%   Nastran Case Control Line: 
%      FORCE(PRINT,CORNER) = ALL
% 
%   BdfFields caseControl property:
%      BdfFields.caseControl{i}.entryName = 'FORCE'
%      BdfFields.caseControl{i}. leftHandDescribers = 'PRINT,CORNER'
%      BdfFields.caseControl{i}. rightHandDescribers = 'ALL'
%
% SPECIAL CASES
%   * SUBCASE entry lines can omit the equal sign (if left hand side 
%     describers are omitted, as they should be for SUBCASE entries).
%   * SET continuation lines are read and stored. SET entry lines are 
%     continued when the last nonwhitespace character is a comma. All SET 
%     continuation lines are appended to the SET entry rightHandDescribers 
%     variable.
% 
% Bulk Data Section
% -----------------
% Free field, small field, and large field format bulk data lines are 
% delimited into entries and fields. A cell array (BdfFields.bulkData) is 
% created which contains one cell for each bulk data entry. Each bulk data 
% entry cell contains another cell array with [char] variable data for each
% input field. 
% 
% All continuation lines are read and stored. A line is determined to be a 
% continuation line if the first field is blank, or if a "+" or "*" is in 
% column 1, field 1. Continuation lines must directly follow the parent 
% entry line. The format of continuations can be mixed, but this is not 
% recommended. 
% 
% EXAMPLE
%   Nastran Bulk Data Entry: 
%      PBEAML,101,501,,BAR
%      ,0.031291,0.181177,0.002854
%  
%   BdfFields bulkData property:
%      BdfFields.bulkData{i}=
%         Columns 1 through 10
%           'PBEAML'	'101'	'501'	''	'BAR'	''	''	''	''	''
%         Columns 11 through 20
%           ''	'0.031291'	'0.181177'	'0.002854'	''	''	''	''	''	''
%
%
% Anthony Ricciardi
%
classdef BdfFields
    properties (SetAccess = private)
        sol; % [char] Describer of the first SOL entry in the executive control section

        % caseControl [Num Case Control Entries,1 cell] containing [struct] with case control data
        %            {:}.entryName: [char] Name of the Case Control Entry
        %            {:}.leftHandDescribers: [char] Left hand side describers
        %            {:}.rightHandDescribers: [char] Right hand side describers
        caseControl;

        % bulkData [Num Bulk Data Entries,1 cell] containing [cell] with bulk data fields
        %         {:} = [1,number of entry fields] Bulk data entry fields as [char]
        bulkData;
    end
    methods
        function obj = BdfFields(bdfLines)
            % Creates BdfFields object with distinct input entries and fields 
            obj.sol=obj.processExecutiveControl(bdfLines.executiveControl);
            obj.caseControl=obj.processCaseControl(bdfLines.caseControl);
            
            nSuperElements = size(bdfLines.bulkData,1);
            for i = 1:nSuperElements
                obj.bulkData{i,1}=obj.processBulkDataLines(bdfLines.bulkData{i});
            end
        end
    end
    methods (Static = true)
        function sol = processExecutiveControl(executiveControlLines)
            executiveControlFields = regexpi(executiveControlLines,...
                '\s*SOL\s+(?<rightHandDescribers>.+)','names');            
            notSolExecutiveControlFields = cellfun('isempty',executiveControlFields);
            solEntries = find(notSolExecutiveControlFields==false);
            if isempty(solEntries)
                sol = [];
            else
                firstSolEntryFields = executiveControlFields(solEntries(1));
                sol = firstSolEntryFields{1}.rightHandDescribers;
            end
        end
        function caseControlFields = processCaseControl(caseControlLines)
            nCaseControlLines = size(caseControlLines,1);
            if nCaseControlLines == 0
                caseControlFields = [];
            else
                
                % process lines other than set continuations
                caseControlRegularLines = regexpi(caseControlLines,...
                    ['\s*(?<entryName>SET)\s*(?<leftHandDescribers>\d+)\s*=\s*(?<rightHandDescribers>.+)','|',...
                    '\s*(?<entryName>\w+)\s*\((?<leftHandDescribers>.+)\)\s*=\s*(?<rightHandDescribers>.+)','|',...
                    '\s*(?<entryName>\w+)\s*=\s*(?<rightHandDescribers>.+)','|',...
                    '\s*(?<entryName>SUBCASE)\s+(?<rightHandDescribers>.+)','|'],'names');
                
                % check first line
                if isempty(caseControlRegularLines{1})
                    error('Format issue with Case Control Line: %s',caseControlLines{1})
                end
                
                % find set continuations and confirm formatting of other lines
                isSetContinuation = false(nCaseControlLines,1);
                for i  = 2:nCaseControlLines
                    if isempty(caseControlRegularLines{i})
                        previousLine = strtrim(caseControlLines{i-1});
                        if strcmp(previousLine(end),',')
                            isSetContinuation(i)=true;
                        else
                            error('Format issue with Case Control Line: %s',caseControlLines{i})
                        end
                    end
                end
                
                % Define what line continuation lines are adding to
                lineIsContinuationOf = zeros(nCaseControlLines,1,'uint32');
                continuationOfTemp = uint32(1);
                for i = 2:nCaseControlLines
                    if isSetContinuation(i)
                        lineIsContinuationOf(i) = continuationOfTemp;
                    else
                        continuationOfTemp = continuationOfTemp + 1;
                    end
                end
                clear continuationOfTemp
                
                % remove continuation lines from caseControlRegularLines
                caseControlFields = caseControlRegularLines(~isSetContinuation);
                
                % add set continuations to set entries
                fieldsLine = int32(1);
                for i = 2:nCaseControlLines
                    if isSetContinuation(i)
                        caseControlFields{fieldsLine}.rightHandDescribers=...
                            [caseControlFields{fieldsLine}.rightHandDescribers,...
                             strtrim(caseControlLines{i})];
                    else
                        fieldsLine = fieldsLine + 1;
                    end
                end
            end
        end % processCaseControl
        
        function bulkDataFields = processBulkDataLines(bulkDataLines)
            nBulkDataLines = size(bulkDataLines,1);
            lineNum = int32(1);
            entryNum = int32(1);
            fieldNum = int32(1);
            entryFields = {'','','','','','','','','',''};
            bulkDataFields=cell(0);
            while lineNum <= nBulkDataLines
                bulkDataLine = bulkDataLines{lineNum};
                % check if the line is a continuation
                isContinuation = any([strncmp(bulkDataLine,'+',1),...
                    strncmp(bulkDataLine,'*',1),...
                    strncmp(strtrim(bulkDataLine),',',1),...
                    strncmp(bulkDataLine,'        ',8)]);
                if lineNum > 1
                    if ~isContinuation
                        bulkDataFields{entryNum,1} = strtrim(entryFields);
                        entryNum = entryNum + 1;
                        entryFields = {'','','','','','','','','',''};
                        fieldNum = int32(1);
                    else
                        fieldNum = fieldNum + 10;
                        entryFields(fieldNum:fieldNum+9)={'','','','','','','','','',''};
                    end
                end
                commas = strfind(bulkDataLine,',');
                if ~isempty(commas)
                    % free field format
                    splitLine = strsplit(bulkDataLine,',','CollapseDelimiters',false);
                    entryFields(fieldNum:fieldNum-1+size(splitLine,2))=splitLine;
                else
                    sizeBulkDataLine = size(bulkDataLine,2);
                    if sizeBulkDataLine > 7
                        asterisksFieldOne =  strfind(bulkDataLine(1:8),'*');
                    else
                        asterisksFieldOne =  strfind(bulkDataLine(1:end),'*');
                    end
                    if ~isempty(asterisksFieldOne)
                        % large field format
                        if sizeBulkDataLine >= 73
                            lineFields = {bulkDataLine(1:8),bulkDataLine(9:24),bulkDataLine(25:40),bulkDataLine(41:56),bulkDataLine(57:72)};
                        elseif sizeBulkDataLine >= 57
                            lineFields = {bulkDataLine(1:8),bulkDataLine(9:24),bulkDataLine(25:40),bulkDataLine(41:56),bulkDataLine(57:end)};
                        elseif sizeBulkDataLine >= 41
                            lineFields = {bulkDataLine(1:8),bulkDataLine(9:24),bulkDataLine(25:40),bulkDataLine(41:end),''};
                        elseif sizeBulkDataLine >= 25
                            lineFields = {bulkDataLine(1:8),bulkDataLine(9:24),bulkDataLine(25:end),'',''};
                        elseif sizeBulkDataLine >= 9
                            lineFields = {bulkDataLine(1:8),bulkDataLine(9:end),'','',''};
                        else
                            lineFields = {bulkDataLine(1:end),'','','',''};
                        end
                        entryFields(fieldNum:fieldNum+4)=lineFields;
                        
                        % check large field continuation
                        if strncmp(bulkDataLines{lineNum+1},'*',1)
                            lineNum = lineNum + 1;
                            if lineNum > nBulkDataLines
                                bulkDataFields{entryNum,1} = entryFields;
                                break
                            end
                            bulkDataLine = bulkDataLines{lineNum};
                            sizeBulkDataLine = size(bulkDataLine,2);
                            if sizeBulkDataLine >= 80
                                lineFields = {bulkDataLine(9:24),bulkDataLine(25:40),bulkDataLine(41:56),bulkDataLine(57:72),bulkDataLine(73:80)};
                            elseif sizeBulkDataLine >= 73
                                lineFields = {bulkDataLine(9:24),bulkDataLine(25:40),bulkDataLine(41:56),bulkDataLine(57:72),bulkDataLine(73:end)};
                            elseif sizeBulkDataLine >= 57
                                lineFields = {bulkDataLine(9:24),bulkDataLine(25:40),bulkDataLine(41:56),bulkDataLine(57:end),''};
                            elseif sizeBulkDataLine >= 41
                                lineFields = {bulkDataLine(9:24),bulkDataLine(25:40),bulkDataLine(41:end),'',''};
                            elseif sizeBulkDataLine >= 25
                                lineFields = {bulkDataLine(9:24),bulkDataLine(25:end),'','',''};
                            elseif sizeBulkDataLine >= 9
                                lineFields = {bulkDataLine(9:end),'','','',''};
                            else
                                lineFields = {'','','','',''};
                            end
                            entryFields(fieldNum+5:fieldNum+9)=lineFields;
                            % else
                            % entryFields(fieldNum+6:fieldNum+10)=cell(5,1);
                        end
                    else
                        % small field format
                        if sizeBulkDataLine >= 80
                            lineFields = {bulkDataLine(1:8),bulkDataLine(9:16),bulkDataLine(17:24),bulkDataLine(25:32),bulkDataLine(33:40),bulkDataLine(41:48),bulkDataLine(49:56),bulkDataLine(57:64),bulkDataLine(65:72),bulkDataLine(73:80)};
                        elseif sizeBulkDataLine >= 73
                            lineFields = {bulkDataLine(1:8),bulkDataLine(9:16),bulkDataLine(17:24),bulkDataLine(25:32),bulkDataLine(33:40),bulkDataLine(41:48),bulkDataLine(49:56),bulkDataLine(57:64),bulkDataLine(65:72),bulkDataLine(73:end)};
                        elseif sizeBulkDataLine >= 65
                            lineFields = {bulkDataLine(1:8),bulkDataLine(9:16),bulkDataLine(17:24),bulkDataLine(25:32),bulkDataLine(33:40),bulkDataLine(41:48),bulkDataLine(49:56),bulkDataLine(57:64),bulkDataLine(65:end),''};
                        elseif sizeBulkDataLine >= 57
                            lineFields = {bulkDataLine(1:8),bulkDataLine(9:16),bulkDataLine(17:24),bulkDataLine(25:32),bulkDataLine(33:40),bulkDataLine(41:48),bulkDataLine(49:56),bulkDataLine(57:end),'',''};
                        elseif sizeBulkDataLine >= 49
                            lineFields = {bulkDataLine(1:8),bulkDataLine(9:16),bulkDataLine(17:24),bulkDataLine(25:32),bulkDataLine(33:40),bulkDataLine(41:48),bulkDataLine(49:end),'','',''};
                        elseif sizeBulkDataLine >= 41
                            lineFields = {bulkDataLine(1:8),bulkDataLine(9:16),bulkDataLine(17:24),bulkDataLine(25:32),bulkDataLine(33:40),bulkDataLine(41:end),'','','',''};
                        elseif sizeBulkDataLine >= 32
                            lineFields = {bulkDataLine(1:8),bulkDataLine(9:16),bulkDataLine(17:24),bulkDataLine(25:32),bulkDataLine(33:end),'','','','',''};
                        elseif sizeBulkDataLine >= 25
                            lineFields = {bulkDataLine(1:8),bulkDataLine(9:16),bulkDataLine(17:24),bulkDataLine(25:end),'','','','','',''};
                        elseif sizeBulkDataLine >= 17
                            lineFields = {bulkDataLine(1:8),bulkDataLine(9:16),bulkDataLine(17:end),'','','','','','',''};
                        elseif sizeBulkDataLine >= 9
                            lineFields = {bulkDataLine(1:8),bulkDataLine(9:end),'','','','','','','',''};
                        else
                            lineFields = {bulkDataLine(1:end),'','','','','','','','',''};
                        end
                        entryFields(fieldNum:fieldNum+9)=lineFields;
                    end
                end
                lineNum = lineNum + 1;
            end
            % one last bulk data fields
            bulkDataFields{entryNum,1} = strtrim(entryFields);
        end % function processBulkDataLines
        
    end
end
