%BDF_LINES reads Nastran-formatted input file lines. Handles INCLUDE statements.
% Removes comments. Partitions executive, case control, and bulk data sections.
%
% Anthony Ricciardi
%
classdef bdf_lines
    
    properties (SetAccess = private)
        exec=cell(0);% [nexec,1 cell] Executive control lines (also NASTRAN statement and File Management lines)
        casec=cell(0); % [ncasec,1 cell] Case control lines
        bulk=cell(0); % [ndata,1 cell] Bulk data lines
    end
    properties (Access = private)
        fid % [scaler] File identifiers of active input file (main or INCLUDE)
        fids = [];% [n,1] File identifiers of all currently open input files (main or INCLUDE)
        pathstrs=cell(0);% {n,1} Cell of file path strings of all currently open input files
        start_dir % [char] Path string of the directory which is current when bdf_lines constructor is called
    end
        
    methods
        function obj = bdf_lines(filename)
            % Reads lines from specified Nastran-formatted input file. Creates bdf_lines object. 
            %
            % Inputs
            % filename = [char] Nastran-formatted input file name.
            obj.start_dir = pwd;
            obj = open_file(obj,filename);
            
            % read the executive control section
            while 1
                [obj,A] = next_line(obj);
                if ~ischar(A)
                    warning('The input file ended before the CEND statement.')
                    check_files_closed(obj)
                    return % input file ended
                else
                    [obj,cend] = process_exec_line(obj,A);
                end
                if cend
                    break
                end
            end
            
            % read the case control section
            while 1
                [obj,A] = next_line(obj);
                if ~ischar(A)
                    warning('The input file ended before the BEGIN BULK statement.')
                    check_files_closed(obj)
                    return % input file ended
                else
                    [obj,begin_bulk] = process_cc_line(obj,A);
                end
                if begin_bulk
                    break
                end
            end
            
            % read the bulk data section
            while 1
                [obj,A] = next_line(obj);
                if ~ischar(A)
                    warning('The input file ended before the ENDDATA statement.')
                    check_files_closed(obj)
                    return % input file ended
                else
                    [obj,enddata] = process_bulk_line(obj,A);
                end
                if enddata
                    break
                end
            end
            
            % Close the current input file (will be the main file if inputs follow convention)
            obj = close_file(obj);
            
            % Check that input files are closed - warn the user otherwise
            check_files_closed(obj)
        end
    end
    methods (Access = private)
        function [obj,A] = next_line(obj)
            % Returns the next uncommented, nonblank input file line while managing INCLUDE statements
            while 1
                A = fgetl(obj.fid);
                if A == -1 % The file has ended
                    obj = close_file(obj);
                    if isempty(obj.fid) % the main file has ended
                        break
                    end
                else
                    Acheck = strtrim(A);
                    if strcmp(Acheck,'')
                        % Empty line will be skipped
                    elseif strcmp(Acheck(1),'$')
                        % Comment line will be skipped
                    elseif strncmpi(Acheck,'INCLUDE',7)
                        % Manage INCLUDE statements
                        filename = strtrim(Acheck(8:end));
                        if ~strcmp(filename(1),'''')
                            error('INCLUDE file names must be in ''single quotations''')
                        end
                        if ~strcmp(filename(end),'''')
                            % INCLUDE statment continues on the next line
                            A2check = strtrim(fgetl(obj.fid));
                            if strcmp(A2check,''); error('INCLUDE statement formating issue with: %s',A); end
                            filename=[filename,A2check];
                            if ~strcmp(A2check(end),'''')
                                A3check = strtrim(fgetl(obj.fid));
                                if strcmp(A3check,''); error('INCLUDE statement formating issue with: %s',A); end
                                if ~strcmp(A3check(end),'''') error('INCLUDE statement formating issue with: %s. INCLUDE continuations only supported up to 3 lines.',A); end
                                filename=[filename,A3check];
                            end
                        end
                        obj = open_file(obj,filename(2:end-1));
                    else
                        % check for trailing comments and remove if present
                        cmts = strfind(A,'$');
                        if ~isempty(cmts)
                            A = A(1:cmts(1)-1);
                        end
                        % Return A
                        break 
                    end
                end
            end
        end
        function [obj,cend] = process_exec_line(obj,A)
            % Processes an executive control line. Checks for CEND statement.
            Acheck = strtrim(A);
            if strncmpi(Acheck,'CEND',4)
                cend = true; % end of executive control section
                return
            else
                cend = false;
            end
            obj.exec{end+1,1} = A;
        end
        function [obj,begin_bulk] = process_cc_line(obj,A)
            % Processes a case control line. Checks for BEGIN BULK statement.
            Acheck = strtrim(A);
            if strncmpi(Acheck,'BEGIN BULK',10)
                    begin_bulk = true; % end of executive control section
                    return
            else
                begin_bulk = false;
            end
            obj.casec{end+1,1} = A;
        end
        function [obj,enddata] = process_bulk_line(obj,A)
            % Processes a bulk data line. Checks for ENDDATA statement.
            Acheck = strtrim(A);
            if strncmpi(Acheck,'ENDDATA',7)
                    enddata = true; % end of executive control section
                    return
            else
                enddata = false;
            end
            obj.bulk{end+1,1} = A;
        end
        function obj = open_file(obj,filename)
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
            obj.pathstrs{end+1,1} = pwd;
            % check file
            if exist(fname,'file')~=2; error('The main input filename or an INCLUDE statement specifies a nonexistent file: %s',filename); end
            % open file
            obj.fid = fopen(fname);
            obj.fids(end+1,1) = obj.fid;
        end
        function obj = close_file(obj)
            % Closes the current main input file or current INCLUDE file.
            st = fclose(obj.fids(end));
            if st == -1; error('There was a issue closing an INCLUDEd file.'); end
            % update properties and current directory
            if size(obj.pathstrs,1)==1
                cd(obj.pathstrs{1})
                obj.pathstrs = cell(0);
                obj.fids = [];
                obj.fid = [];
            else
                cd(obj.pathstrs{end-1});
                obj.pathstrs = obj.pathstrs(1:end-1);
                obj.fids = obj.fids(1:end-1);
                obj.fid = obj.fids(end);
            end
        end
        function check_files_closed(obj)
            % Checks that main and INCLUDEd input files are closed.
            % Warns the user if files were still open. Closes open input files.
            % Sets the current directory back to the directory that was current when the bdf_lines constructor was called
            if ~isempty(obj.fid)
                fclose('all');
                warning('The input file reader may have stopped prematurely. Check that your model is complete. Check for unintentional ENDDATA statements, especially in INCLUDEd files.')
            end
            cd(obj.start_dir)
        end
    end
    
end