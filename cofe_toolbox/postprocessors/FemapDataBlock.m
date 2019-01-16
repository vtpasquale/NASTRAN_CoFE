% Abstract superclass for FEMAP data blocks
% Anthony Ricciardi
%
classdef (Abstract) FemapDataBlock < matlab.mixin.Heterogeneous
    methods (Abstract)
        writeNeutral_sub(obj,fid) % Writes single data block to FEMAP Neutral File
    end
    methods (Sealed=true)
        function writeNeutral(obj,fid) 
            % Writes all data blocks in array to FEMAP Neutral File
            [nFemapDataBlock,m] = size(obj);
            if m > 1; error('FemapDataBlock.writeNeutral() can only handel nx1 arrays of FemapDataBlock objects. The second dimension exceeds 1.'); end
            
            
            % Neutral File Header
            fprintf(fid,'   -1\n');
            fprintf(fid,'   100\n');
            fprintf(fid,'<NULL>\n');
            fprintf(fid,'11.4,\n');
            fprintf(fid,'   -1\n');
            
            % partioned data blocks
            typeFemapDataBlock = zeros(nFemapDataBlock,1);
            for i = 1:nFemapDataBlock
                switch class(obj(i))
                    case 'FemapDataBlock450'
                        typeFemapDataBlock(i) = 450;
                    case 'FemapDataBlock1051'
                        typeFemapDataBlock(i) = 1051;
                    case 'FemapDataBlock1056'
                        typeFemapDataBlock(i) = 1056;
                end
            end
                        
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
            
        end
    end
    
end

