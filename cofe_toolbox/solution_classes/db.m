% Abstract superclass for FEMAP Neutral File format data blocks
% Anthony Ricciardi
%
classdef db < matlab.mixin.Heterogeneous
       
    methods (Sealed=true)
        function writeNeu_all(obj,fid) 
            % Writes all data blocks in array to FEMAP Neutral File
            ndb = size(obj,1);
            for i=1:ndb
                writeNeu(obj(i),fid)
            end
        end
    end
    methods (Abstract)
        writeNeu(obj,fid) % Writes single data block to FEMAP Neutral File
    end
    
end

