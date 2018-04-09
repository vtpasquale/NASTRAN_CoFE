% Abstract superclass for FEMAP Neutral File format data blocks
% Anthony Ricciardi
%
classdef db < matlab.mixin.Heterogeneous
       
    methods (Sealed=true)
        function writeNeu_all(obj,fid) 
            % Writes all data blocks in array to FEMAP Neutral File
            [ndb,m] = size(obj);
            if m > 1; error('db.writeNeu_all() can only handel nx1 arrays of db objects. The second dimension exceeds 1.'); end
            
            
            % Neutral File Header
            fprintf(fid,'   -1\n');
            fprintf(fid,'   100\n');
            fprintf(fid,'<NULL>\n');
            fprintf(fid,'11.4,\n');
            fprintf(fid,'   -1\n');
            
            % partioned data blocks
            typedb = zeros(ndb,1);
            for i = 1:ndb
                switch class(obj(i))
                    case 'db450'
                        typedb(i) = 450;
                    case 'db1051'
                        typedb(i) = 1051;
                    case 'db1056'
                        typedb(i) = 1056;
                end
            end
                        
            % Write Format 450 Datablocks
            for i = find(typedb==450)
                writeNeu(obj(i),fid)
            end
            % Write Format 1051 Datablocks
            fprintf(fid,'   -1\n');
            fprintf(fid,'  1051\n');
            for i = find(typedb==1051)'
                writeNeu(obj(i),fid)
            end
            fprintf(fid,'   -1\n');
            % Write Format 1056 Datablocks
            for i = find(typedb==1056)
                writeNeu(obj(i),fid)
            end
            
        end
    end
    methods (Abstract)
        writeNeu(obj,fid) % Writes single data block to FEMAP Neutral File
    end
    
end

