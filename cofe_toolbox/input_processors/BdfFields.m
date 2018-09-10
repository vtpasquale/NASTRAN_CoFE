% Nastran input entry fields - delimited from input files lines.
% Constructed from BdfLines object.
%
% You must use a + or * in column 1, field 1 of a continuation entry
%
% Anthony Ricciardi
%
classdef BdfFields
    properties (SetAccess = private)
        executiveControl=cell(0);% [____ ,1 cell] Executive control fields (also NASTRAN statement and File Management fields)
        caseControl=cell(0); % [____ ,1 cell] Case control fields
        bulkData=cell(0); % [____ ,1 cell] Bulk data fields
    end
    methods
        function obj = BdfFields(bdfLines)
            % Reads fields from Nastran input lines stored in BdfLines object.
            bulkDataLines = bdfLines.bulkData;
            nBulkDataLines = size(bulkDataLines,1);
            lineNum = int32(1);
            entryNum = int32(1);
            fieldNum = int32(1);
            entryFields = cell(1,10);
            bulkDataFields=cell(0);
            while lineNum <= nBulkDataLines
                bulkDataLine = bulkDataLines{lineNum};
                % check if the line is a continuation
                isContinuation = any([strncmp(bulkDataLine,'+',1),strncmp(bulkDataLine,'*',1),strncmp(bulkDataLine,'        ',8)]);
                if lineNum > 1
                    if ~isContinuation
                        bulkDataFields{entryNum,1} = strtrim(entryFields);
                        entryNum = entryNum + 1;
                        entryFields = {'','','','','','','','','',''};
                        fieldNum = int32(1);
                    else
                        fieldNum = fieldNum + 10;
                        entryFields(fieldNum:fieldNum+9)=cell(1,10);
                    end
                end
                commas = strfind(bulkDataLine,',');
                if ~isempty(commas)
                    %% free field format
                    splitLine = strsplit(bulkDataLine,',','CollapseDelimiters',false);
                    entryFields(fieldNum:fieldNum-1+size(splitLine,2))=splitLine;
                else
                    sizeBulkDataLine = size(bulkDataLine,2);
                    if sizeBulkDataLine>7
                        asterisksFieldOne =  strfind(bulkDataLine(1:8),'*');
                    else
                        asterisksFieldOne =  strfind(bulkDataLine(1:end),'*');
                    end
                    if ~isempty(asterisksFieldOne)
                        %% large field format
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
                                lineFields = {bulkDataLine(1:8),bulkDataLine(9:24),bulkDataLine(25:40),bulkDataLine(41:56),bulkDataLine(57:72),bulkDataLine(73:80)};
                            elseif sizeBulkDataLine >= 73
                                lineFields = {bulkDataLine(1:8),bulkDataLine(9:24),bulkDataLine(25:40),bulkDataLine(41:56),bulkDataLine(57:72),''};
                            elseif sizeBulkDataLine >= 57
                                lineFields = {bulkDataLine(1:8),bulkDataLine(9:24),bulkDataLine(25:40),bulkDataLine(41:56),bulkDataLine(57:end),''};
                            elseif sizeBulkDataLine >= 41
                                lineFields = {bulkDataLine(1:8),bulkDataLine(9:24),bulkDataLine(25:40),bulkDataLine(41:end),'',''};
                            elseif sizeBulkDataLine >= 25
                                lineFields = {bulkDataLine(1:8),bulkDataLine(9:24),bulkDataLine(25:end),'','',''};
                            elseif sizeBulkDataLine >= 9
                                lineFields = {bulkDataLine(1:8),bulkDataLine(9:end),'','','',''};
                            else
                                lineFields = {bulkDataLine(1:end),'','','','',''};
                            end
                            entryFields(fieldNum+5:fieldNum+10)=lineFields;
                            % else
                            % entryFields(fieldNum+6:fieldNum+10)=cell(5,1);
                        end
                        
                    else
                        %% small field format
                        if sizeBulkDataLine >= 80
                            lineFields = {bulkDataLine(1:8),bulkDataLine(9:16),bulkDataLine(17:24),bulkDataLine(25:32),bulkDataLine(33:40),bulkDataLine(41:48),bulkDataLine(49:56),bulkDataLine(57:64),bulkDataLine(65:72),bulkDataLine(73:80)};
                        elseif sizeBulkDataLine >= 73
                            lineFields = {bulkDataLine(1:8),bulkDataLine(9:16),bulkDataLine(17:24),bulkDataLine(25:32),bulkDataLine(33:40),bulkDataLine(41:48),bulkDataLine(49:56),bulkDataLine(57:64),bulkDataLine(65:72),''};
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
            obj.bulkData=bulkDataFields;
        end
    end
end
