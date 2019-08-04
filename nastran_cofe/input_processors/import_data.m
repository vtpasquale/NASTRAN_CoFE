% Read NASTRAN input file and convert it to a struct array
% Anthony Ricciardi
%
% Inputs
% filename = [string] name of text input file in NASTRAN format
%
% Output
% data [1xnumber of fields, struct array] input file data
%
%
function data = import_data(filename)

fid = fopen(filename);

%% initialize counter
entry = 1;

%% Process input
C = nextLine(fid);
if iscell(C) == 0
    if C == -1
        error('The input file is empty')
    end
end

while 1
    row = 1; % continuation line number
    
    while 1
        % save data line
        data(entry).fields((1:9)+10*(row-1)) = C;
        
        % read next line
        C = nextLine(fid);     
        
        % check for end of file
        if iscell(C) == 0 % end of file 
            fclose('all');
            return %%%%%%%%%%%%%%%%%%%% EXIT  WHILE and FUNCTION %%%%%%%%%%
        end
        
        % read first field
        one = C{1};

        % check continuation
        if ischar(one)
            oneCheck = strrep(one,' ','');
            if strcmp(oneCheck,'') == 1
                one = [];
            elseif oneCheck(1) == '+';
                one = [];
            end
        end
        
        if isempty(one)
            % continuation line
            row = row + 1;
        else
            entry = entry + 1;
            break %%%%%%%%%%%%%%%%%%%% EXIT  WHILE  endEntry %%%%%%%%%%%%%%
        end
    end
end
fclose('all');
end

%%
function C = nextLine(fid)
C = [];

A = fgetl(fid);
if A == -1
    % break % The file has ended
    C = -1;
else
    Acheck = strrep(A,' ','');
    
    if strcmp(Acheck,'') == 1
        % Empty line will be skipped
    elseif strcmp(Acheck(1),'$') == 1
        % Comment line will be skipped
    else
        % process line
        
        % check for large field format
        if isempty(strfind(A,'*'))~=1 % Large field format
            
            filePosition = ftell(fid);
            AL2 = fgetl(fid);
            if AL2(1) ~= '*' % not continued
                % rewind one line
                fseek(fid,filePosition,'bof');
                AL2 = [];
            end
            
            C = processInputLine(A,AL2);
            
        else % small field for free field format
            % read line
            C = processInputLine(A);
        end
        
    end
end

if isempty(C)
    C = nextLine(fid);
end

end


%%
% Function to process input file line
% Anthony Ricciardi
%
% Inputs
% A = [string] line from input file
% continuation = [dummy] input used to identify that line is a continuation
%                        line.  Additional checks are performed.
%
% Outputs
% B = Cell structured input line
%
function B = processInputLine(A,AL2)

if nargin > 1
    % Large Field Format
    sa = size(A,2);
    if sa >= 73
        B1 = {A(1:8),A(9:24),A(25:40),A(41:56),A(57:72)};
    elseif sa >= 57
        B1 = {A(1:8),A(9:24),A(25:40),A(41:56),A(57:end)};
    elseif sa >= 41
        B1 = {A(1:8),A(9:24),A(25:40),A(41:end),''};
    elseif sa >= 25
        B1 = {A(1:8),A(9:24),A(25:end),'',''};
    elseif sa >= 9
        B1 = {A(1:8),A(9:end),'','',''};
    else
        B1 = {A(1:end),'','','',''};
    end
    
    if isempty(AL2) == 0
        sb = size(AL2,2);
        if sb >= 73
            B2 = {AL2(1:8),AL2(9:24),AL2(25:40),AL2(41:56),AL2(57:72)};
        elseif sb >= 57
            B2 = {AL2(1:8),AL2(9:24),AL2(25:40),AL2(41:56),AL2(57:end)};
        elseif sb >= 41
            B2 = {AL2(1:8),AL2(9:24),AL2(25:40),AL2(41:end),''};
        elseif sb >= 25
            B2 = {AL2(1:8),AL2(9:24),AL2(25:end),'',''};
        elseif sb >= 9
            B2 = {AL2(1:8),AL2(9:end),'','',''};
        else
            B2 = {AL2(1:end),'','','',''};
        end
    else
        B2 = {'','','','',''};
    end
    B = {strrep(B1{1},'*',' '),B1{2},B1{3},B1{4},B1{5},B2{2},B2{3},B2{4},B2{5}};
    
else % free field or small field format
    
    commas=strfind(A,',');
    if isempty(commas) ~= 1
        % Free Field Format - Input data fields are separated by commas.
        B = textscan(A,'%s','Delimiter',',','CommentStyle','$');
        B = B{1}';
        sb = size(B,2);
        if sb < 9
            B2 = {'','','','','','','','',''};
            B2(1:sb) = B;
            B = B2;
        end
    else
        % Small Field Format - 10 fields of eight characters each (9 are used).
        sa = size(A,2);
        %     if sa > 80
        %         error(['Line too long: ',A,])
        if sa >= 73
            B = {A(1:8),A(9:16),A(17:24),A(25:32),A(33:40),A(41:48),A(49:56),A(57:64),A(65:72)};
        elseif sa >= 65
            B = {A(1:8),A(9:16),A(17:24),A(25:32),A(33:40),A(41:48),A(49:56),A(57:64),A(65:end)};
        elseif sa >= 57
            B = {A(1:8),A(9:16),A(17:24),A(25:32),A(33:40),A(41:48),A(49:56),A(57:end),''};
        elseif sa >= 49
            B = {A(1:8),A(9:16),A(17:24),A(25:32),A(33:40),A(41:48),A(49:end),'',''};
        elseif sa >= 41
            B = {A(1:8),A(9:16),A(17:24),A(25:32),A(33:40),A(41:end),'','',''};
        elseif sa >= 32
            B = {A(1:8),A(9:16),A(17:24),A(25:32),A(33:end),'','','',''};
        elseif sa >= 25
            B = {A(1:8),A(9:16),A(17:24),A(25:end),'','','','',''};
        elseif sa >= 17
            B = {A(1:8),A(9:16),A(17:end),'','','','','',''};
        elseif sa >= 9
            B = {A(1:8),A(9:end),'','','','','','',''};
        else
            B = {A(1:end),'','','','','','','',''};
        end
    end
end
B = strrep(B,' ',''); % remove spaces
end