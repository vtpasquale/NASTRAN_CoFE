% Reads Nastran-formatted input file lines. Handles INCLUDE statements.
% Removes comments. Partitions executive, case control, and bulk data 
% sections. Partitions the bulk data section into part superelements.
%
% Anthony Ricciardi
%
classdef BdfLines
    
    properties (SetAccess = private)
        executiveControl=cell(0);% {nExecutiveControlLines,1 char} Executive control lines (also NASTRAN statement and File Management lines)
        caseControl=cell(0); % {nCaseControlLines,1 char} Case control lines
        bulkData=cell(0); % {nSuperElements,1 {nBulkDataLines,1 char}} Bulk data lines
        superElementID = uint32(0); % [nSuperElements, 1 uint32] Part superelement ID number
    end
    properties (Access = private)
        fid % [scaler] File identifiers of active input file (main or INCLUDE)
        openFids = [];% [n,1] File identifiers of all currently open input files (main or INCLUDE)
        openFidPaths=cell(0);% {n,1} Cell of file path strings of all currently open input files
        startPath % [char] Path string of the directory which is current when BdfLines constructor is called
    end
    
    methods
        function obj = BdfLines(filename)
            % Reads lines from specified Nastran-formatted input file. Creates BdfLines object.
            %
            % Inputs
            % filename = [char] Nastran-formatted input file name.
            obj = obj.readBdfLines(filename);
            obj = obj.partitionBulkDataSuperelements();
        end
    end
    methods (Access = private)
        function obj = readBdfLines(obj,filename)
            % Reads lines from specified Nastran-formatted input file. Creates BdfLines object.
            % Bulk data superelements are not partitioned in this function
            %
            % Inputs
            % filename = [char] Nastran-formatted input file name.
            obj.startPath = pwd;
            obj = openFile(obj,filename);
            
            % read the executive control section
            while 1
                [obj,inputLine] = readNextLine(obj);
                if ~ischar(inputLine)
                    warning('The input file ended before the CEND statement.')
                    checkFilesClosed(obj)
                    return % input file ended
                else
                    [obj,cend] = processExecutiveControlLine(obj,inputLine);
                end
                if cend
                    break
                end
            end
            
            % read the case control section
            while 1
                [obj,inputLine] = readNextLine(obj);
                if ~ischar(inputLine)
                    warning('The input file ended before the BEGIN BULK statement.')
                    checkFilesClosed(obj)
                    return % input file ended
                else
                    [obj,beginBulk] = processCaseControlLine(obj,inputLine);
                end
                if beginBulk
                    break
                end
            end
            
            % read the bulk data section
            while 1
                [obj,inputLine] = readNextLine(obj);
                if ~ischar(inputLine)
                    warning('The input file ended before the ENDDATA statement.')
                    checkFilesClosed(obj)
                    return % input file ended
                else
                    [obj,enddata] = processBulkDataLine(obj,inputLine);
                end
                if enddata
                    break
                end
            end
            
            % Close the current input file (will be the main file if inputs follow convention)
            obj = closeFile(obj);
            
            % Check that input files are closed - warn the user otherwise
            checkFilesClosed(obj)
        end
        function obj = partitionBulkDataSuperelements(obj)
            % Partition the bulk data section into superelements
            startsWithBegin = strncmpi(obj.bulkData,'BEGIN',5);
            if any(startsWithBegin)
                % part superelement model
                bulkDataLines = obj.bulkData;
                beginIndex = find(startsWithBegin);
                startIndex = [1;beginIndex+1];
                endIndex = [beginIndex-1;size(bulkDataLines,1)];
                nSuperElements = size(startIndex,1);
                obj.superElementID = zeros(nSuperElements,1,'uint32');
                
                obj.bulkData=cell(0);
                
                % Residual structure
                obj.superElementID(1) = uint32(0);
                obj.bulkData{1,1} = bulkDataLines(startIndex(1):endIndex(1),1);
                
                % Partition Part Bulk Data
                for i = 2:nSuperElements
                    % Super element ID
                    beginLine = bulkDataLines{beginIndex(i-1),1};
                    findEqual = strfind(beginLine,'=');
                    findSuper = strfind(upper(beginLine),'SUPER');
                    if isempty(findEqual) || isempty(findSuper)
                        error('There is a format error with bulk data line: %s',beginLine)
                    end
                    splitBeginLine = strsplit(beginLine,'=','CollapseDelimiters',false);
                    if size(splitBeginLine,2)~=2; error('There is a format error with bulk data line: %s',beginLine); end
                    obj.superElementID(i) = castInputField('BEGIN SUPER','ID',splitBeginLine{2},'uint32',NaN,1);
                    
                    % Part bulk data
                    obj.bulkData{i,1} = bulkDataLines(startIndex(i):endIndex(i),1);
                end
            else
                dummy = cell(0);
                dummy{1,1}=obj.bulkData;
                obj.bulkData=dummy;
            end
        end
        function [obj,inputLine] = readNextLine(obj)
            % Returns the next uncommented, nonblank input file line while managing INCLUDE statements
            while 1
                inputLine = fgetl(obj.fid);
                if inputLine == -1 % The file has ended
                    obj = closeFile(obj);
                    if isempty(obj.fid) % the main file has ended
                        break
                    end
                else
                    trimLine = strtrim(inputLine);
                    if strcmp(trimLine,'')
                        % Empty line will be skipped
                    elseif strcmp(trimLine(1),'$')
                        % Comment line will be skipped
                    elseif strncmpi(trimLine,'INCLUDE',7)
                        % Manage INCLUDE statements
                        filename = strtrim(trimLine(8:end));
                        if ~strcmp(filename(1),'''')
                            error('INCLUDE file names must be in ''single quotations''')
                        end
                        if ~strcmp(filename(end),'''')
                            % INCLUDE statment continues on the next line
                            trimLine2 = strtrim(fgetl(obj.fid));
                            if strcmp(trimLine2,''); error('INCLUDE statement formating issue with: %s',inputLine); end
                            filename=[filename,trimLine2];
                            if ~strcmp(trimLine2(end),'''')
                                trimLine3 = strtrim(fgetl(obj.fid));
                                if strcmp(trimLine3,''); error('INCLUDE statement formating issue with: %s',inputLine); end
                                if ~strcmp(trimLine3(end),'''') error('INCLUDE statement formating issue with: %s. INCLUDE continuations only supported up to 3 lines.',inputLine); end
                                filename=[filename,trimLine3];
                            end
                        end
                        obj = openFile(obj,filename(2:end-1));
                    else
                        % check for trailing comments and remove if present
                        comment = strfind(inputLine,'$');
                        if ~isempty(comment)
                            inputLine = inputLine(1:comment(1)-1);
                        end
                        % Return A
                        break
                    end
                end
            end
        end
        function [obj,cend] = processExecutiveControlLine(obj,inputLine)
            % Processes an executive control line. Checks for CEND statement.
            trimLine = strtrim(inputLine);
            if strncmpi(trimLine,'CEND',4)
                cend = true; % end of executive control section
                return
            else
                cend = false;
            end
            obj.executiveControl{end+1,1} = inputLine;
        end
        function [obj,beginBulk] = processCaseControlLine(obj,inputLine)
            % Processes a case control line. Checks for BEGIN BULK statement.
            trimLine = strtrim(inputLine);
            if strncmpi(trimLine,'BEGIN BULK',10)
                beginBulk = true; % end of executive control section
                return
            else
                beginBulk = false;
            end
            obj.caseControl{end+1,1} = inputLine;
        end
        function [obj,endData] = processBulkDataLine(obj,inputLine)
            % Processes a bulk data line. Checks for ENDDATA statement.
            trimLine = strtrim(inputLine);
            if strncmpi(trimLine,'ENDDATA',7)
                endData = true; % end of executive control section
                return
            else
                endData = false;
            end
            obj.bulkData{end+1,1} = inputLine;
        end
        function obj = openFile(obj,filename)
            % Opens a new main input file or new INCLUDE file.
            
            % get file short name and file path
            [pathstr,name,ext] = fileparts(filename);
            fname = [name,ext];
            % check the directory path
            if strcmp(pathstr,'')
                pathstr=pwd;
            end
            % go to input file directory and save location
            cd(pathstr);
            obj.openFidPaths{end+1,1} = pwd;
            % check file
            if exist(fname,'file')~=2; error('The main input filename or an INCLUDE statement specifies a nonexistent file: %s',filename); end
            % open file
            obj.fid = fopen(fname);
            obj.openFids(end+1,1) = obj.fid;
        end
        function obj = closeFile(obj)
            % Closes the current main input file or current INCLUDE file.
            st = fclose(obj.openFids(end));
            if st == -1; error('There was a issue closing an INCLUDEd file.'); end
            % update properties and current directory
            if size(obj.openFidPaths,1)==1
                cd(obj.openFidPaths{1})
                obj.openFidPaths = cell(0);
                obj.openFids = [];
                obj.fid = [];
            else
                cd(obj.openFidPaths{end-1});
                obj.openFidPaths = obj.openFidPaths(1:end-1);
                obj.openFids = obj.openFids(1:end-1);
                obj.fid = obj.openFids(end);
            end
        end
        function checkFilesClosed(obj)
            % Checks that main and INCLUDEd input files are closed.
            % Warns the user if files were still open. Closes open input files.
            % Sets the current directory back to the directory that was current when the BdfLines constructor was called
            if ~isempty(obj.fid)
                fclose('all');
                warning('The input file reader may have stopped prematurely. Check that your model is complete. Check for unintentional ENDDATA statements, especially in INCLUDEd files.')
            end
            cd(obj.startPath)
        end
    end
end