% Class for text file output headings
% Anthony Ricciardi
%
classdef OutputHeading
    properties
        fixedHeading % [char] Fixed heading output
        vectorHeading % [char] heading output with formating for sprintf(vectorHeading,vector(modeNumber))
        vector % [nModes,1 double]
    end
    methods
        function obj = OutputHeading(fixedHeadingIn,vectorHeadingIn,vectorIn)
            if nargin == 0 
            elseif nargin == 1
                obj.fixedHeading = fixedHeadingIn;
            else
                obj.fixedHeading=fixedHeadingIn;
                obj.vectorHeading=vectorHeadingIn;
                obj.vector=vectorIn;
            end
        end
        function printTextOutput(obj,fid,modeNumber)
            fprintf(fid,obj.fixedHeading);
            if ~isempty(obj.vector) && nargin > 2
                fprintf(fid,'      MODE: %d\n',modeNumber);
                fprintf(fid,obj.vectorHeading,obj.vector(modeNumber));
            end
        end
    end
end
