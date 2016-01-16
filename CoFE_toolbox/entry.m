% Abstract superclass for input file entry classes
% Anthony Ricciardi
%
classdef (Abstract) entry
    
    properties
    end
    
    methods (Abstract)
        
        % The initialize method initializes the object input properties   
        % based on input file entry data in cell format 
        initialize(obj,data)
        
        % The echo method prints the object entry properties in NASTRAN
        % free field format to a text file with file id fid
        echo(obj,fid)
    end
    
end

