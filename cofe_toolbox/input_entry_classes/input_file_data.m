% Class for reading and storing input file data
% Anthony Ricciardi
%
classdef input_file_data
    
    properties
        fid % [scalr] File identifiers of active input file (main or INCLUDE)
        fids = [];% [n,1] File identifiers of all currently open input files (main or INCLUDE)
        pathstrs=cell(0);% {n,1} Cell of file path strings of all currently open input files
        
        exec=cell(0);% [nexec,1 cell] Excutive control data (also NASTRAN statement and File Management statements)
        casec=cell(0); % [ncasec,1 struct] Case control data
        bulk=cell(0); % [ndata,1 struct] Buld data data
    end
    
    methods
        function obj = input_file_data(filename)
            obj = open_file(obj,filename);
            
            % read the executive control section
            while 1
                [obj,A] = next_line(obj);
                if ~ischar(A)
                    warning('The input file ended before the CEND statement.')
                    return % the input file ended
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
                    return % the input file ended
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
                    return % the input file ended
                else
                    [obj,enddata] = process_bulk_line(obj,A);
                end
                if enddata
                    break
                end
            end
            
            % Add logic to check the files are closed.
            
        end
        
        function [obj,A] = next_line(obj)
            % Function to return the next uncommented, nonblank input file line while managing INCLUDE statments
            while 1
                A = fgetl(obj.fid);
                
                A
                
                if A == -1 % The file has ended
                    obj = close_file(obj);
                    % Add logic for new include file
                else
                    Acheck = strrep(A,' ','');
                    if strcmp(Acheck,'') == 1
                        % Empty line will be skipped
                    elseif strcmp(Acheck(1),'$') == 1
                        % Comment line will be skipped
                    elseif size(Acheck,2)>6
                        % Manage INCLUDE statements
                        if strcmpi(Acheck(1:7),'INCLUDE')
                            filename = Acheck(8:end);
                            if ~strcmp(filename(1),'''')
                                error('INCLUDE file names must be in ''single quotations''')
                            end
                            if ~strcmp(filename(end),'''')
                                % INCLUDE statment continues on the next line
                                A2check = strrep(fgetl(obj.fid),' ');
                                if strcmp(A2check,'') == 1; error('INCLUDE statement formating issue with: %s',A); end
                                if ~strcmp(A2check(end),'''')
                                    filename=[filename,A2check];
                                    A3check = strrep(fgetl(obj.fid),' ');
                                    if strcmp(A3check,'') == 1; error('INCLUDE statement formating issue with: %s',A); end
                                    if ~strcmp(A3check(end),'''') error('INCLUDE statement formating issue with: %s. INCLUDE continuations only supported up to 3 lines.',A); end
                                    filename=[filename,A3check];
                                end
                            end
                            obj = open_file(obj,filename(2:end-1));
                        else
                            break % return A
                        end                        
                    else
                        break % return A
                    end
                end
            end
        end
        function [obj,cend] = process_exec_line(obj,A)
            Acheck = strrep(A,' ','');
            if size(Acheck,2)>3
                if strcmpi(Acheck(1:4),'CEND')
                    cend = true; % end of executive control section
                    return
                else
                    cend = false;
                end
            else
                cend = false;
            end
            obj.exec{end+1,1} = A;
        end
        function [obj,begin_bulk] = process_cc_line(obj,A)
            Acheck = strrep(A,' ','');
            if size(Acheck,2)>8
                if strcmpi(Acheck(1:9),'BEGINBULK')
                    begin_bulk = true; % end of executive control section
                    return
                else
                    begin_bulk = false;
                end
            else
                begin_bulk = false;
            end
            obj.casec{end+1,1} = A;
        end
        function [obj,enddata] = process_bulk_line(obj,A)
            Acheck = strrep(A,' ','');
            if size(Acheck,2)>6
                if strcmpi(Acheck(1:7),'ENDDATA')
                    enddata = true; % end of executive control section
                    return
                else
                    enddata = false;
                end
            else
                enddata = false;
            end
            obj.bulk{end+1,1} = A;
        end
        function obj = open_file(obj,filename)
            % check path
            pathstr = fileparts(filename);
            if strcmp(pathstr,'')
                pathstr=pwd;
            else
                if exist(pathstr,'dir')~=7; error('An INCLUDE statement specifies a nonexistent directory.'); end
            end
            % check file
            if exist(filename,'file')~=2; error('An INCLUDE statement specifies a nonexistent file.'); end
            % open file
            obj.fid = fopen(filename);
            obj.fids(end+1,1) = obj.fid;
            % go to input file directory and save location
            cd(pathstr);
            obj.pathstrs{end+1,1} = pwd;
        end
        function obj = close_file(obj)
            st = fclose(obj.fids(end));
            if st == -1; error('There was a issue closing an INCLUDEd file.'); end
            % update properties and current directory
            if size(obj.pathstrs,1)==1
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
    end
    
end

