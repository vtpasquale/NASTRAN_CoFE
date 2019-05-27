% Class for FEMAP Neutral File Data Block 1056 – Analysis Study
% Anthony Ricciardi
%
classdef FemapDataBlock1056 < FemapDataBlock
    
    properties
        ID % [int] ID of Study
        Title % [1xN char] Title of Analysis Study
        Analysis_Type % ID of analysis type (refer to output sets)
        File_Time % [int] Time of last modification of results file (Unix 10-digit formt = 86400.*(now - datenum(1970,1,1,0,0,0)); ) 
        Analysis_Set % [int] ID of Femap Analysis Set used for solution
        Study_Notes % [1xN char] text
    end
    properties (Constant = true, Hidden = true)
        DATA_BLOCK_ID = int32(1056);
        Analysis_Program = 0; % Analysis program where output came from
    end
    methods
        function writeNeutral_sub(obj,fid)
            % Writes single data block to FEMAP Neutral File
            fprintf(fid,'   -1\n');
            fprintf(fid,'   1056\n');
            fprintf(fid,'%d\n',obj.ID);
            fprintf(fid,'%s\n',obj.Title);
            fprintf(fid,'%d,%d\n',obj.Analysis_Program,obj.Analysis_Type);
            if isempty(obj.File_Time); obj.File_Time = 86400.*(now - datenum(1970,1,1,0,0,0)); end
            fprintf(fid,'%d,%d\n',int32(obj.File_Time),obj.Analysis_Set);
            fprintf(fid,'%s\n',obj.Study_Notes);
            fprintf(fid,'   -1\n');
        end
        function obj = FemapDataBlock1056(ID,Title,Analysis_Type,Analysis_Set,Study_Notes)
            % db1056 class constructor method
            if nargin ~= 0
                obj.ID=ID; % [int] ID of Study
                obj.Title=Title; % [1xN char] Title of Analysis Study
                obj.Analysis_Type=Analysis_Type; % ID of analysis type (refer to output sets)
                obj.File_Time = int32(86400.*(now - datenum(1970,1,1,0,0,0)));
                obj.Analysis_Set=Analysis_Set; % [int] ID of Analysis Set used for solution
                obj.Study_Notes=Study_Notes; % [1xN char] text
            end
        end
    end
end

