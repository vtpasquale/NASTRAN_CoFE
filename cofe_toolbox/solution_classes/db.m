% Abstract superclass for FEMAP Neutral File format data blocks
% Anthony Ricciardi
%
classdef db < matlab.mixin.Heterogeneous
       
    methods (Sealed=true)
        function writeNeu_all(obj,fid) 
            % Writes all data blocks in array to FEMAP Neutral File
            [ndb,m] = size(obj);
            if m > 1; error('db.writeNeu_all() can only handel nx1 arrays of db objects. The second dimension exceeds 1.'); end
            
            for i=1:ndb
                writeNeu(obj(i),fid)
            end
        end
    end
    methods (Abstract)
        writeNeu(obj,fid) % Writes single data block to FEMAP Neutral File
    end
    
end

