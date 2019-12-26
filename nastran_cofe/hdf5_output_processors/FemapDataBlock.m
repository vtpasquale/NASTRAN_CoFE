% Abstract superclass for Femap data blocks
% Anthony Ricciardi
%
classdef (Abstract) FemapDataBlock < matlab.mixin.Heterogeneous
    properties (Abstract = true, Constant = true, Hidden = true)
        DATA_BLOCK_ID
    end
    methods (Abstract)
        writeNeutral_sub(obj,fid) % Writes single data block to FEMAP Neutral File
    end
    methods (Sealed=true)
        function writeNeutral(obj,outputFile)
            
            fid = fopen(outputFile,'w+');
            
            % Writes all data blocks in array to FEMAP Neutral File
            [nFemapDataBlock,m] = size(obj);
            if m > 1; error('FemapDataBlock.writeNeutral() can only handel nx1 arrays of FemapDataBlock objects. The second dimension exceeds 1.'); end
            typeFemapDataBlock = [obj.DATA_BLOCK_ID]';

            % Check/Write data block 100
            i = find(typeFemapDataBlock==100);
            if size(i,1)~=1; error('There should be one and only one Femap data block 100 in the Femap data block array'); end
            writeNeutral_sub(obj(i),fid)
                        
            % Write Format 450 Datablocks
            for i = find(typeFemapDataBlock==450)'
                writeNeutral_sub(obj(i),fid)
            end
            
            % Write Format 1051 Datablocks
            fprintf(fid,'   -1\n');
            fprintf(fid,'  1051\n');
            for i = find(typeFemapDataBlock==1051)'
                writeNeutral_sub(obj(i),fid)
            end
            fprintf(fid,'   -1\n');
            % Write Format 1056 Datablocks
            for i = find(typeFemapDataBlock==1056)'
                writeNeutral_sub(obj(i),fid)
            end
            
            fclose(fid);
        end
    end
    
end

