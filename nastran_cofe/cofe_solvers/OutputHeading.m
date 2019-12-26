% Class for text file output headings
% Anthony Ricciardi
%
classdef OutputHeading
    properties
        subcase % [uint32] Subcase identification number.
        superElementID %  [uint32] Superelement identification numbers
        analysis % [char] Specifies the type of analysis being performed for the current subcase
        title % [char] Defines a title to appear on the first heading line of each page
        subtitle % [char] Defines a subtitle to appear on the second heading line of each page
        label % [char] Defines a label to appear on the third heading line of each page
        
        fixedHeading % [char] Fixed heading output
        headingVector % [nModes,1 double]
        headingVectorText % [char] heading output with formating for sprintf(vectorHeading,vector(modeNumber))

    end
    methods
        function obj = OutputHeading(caseControl,superElementIDIn)
            obj.title = caseControl.title;
            obj.subtitle = caseControl.subtitle;
            obj.label = caseControl.label;
            obj.subcase = caseControl.subcase;
            obj.analysis = caseControl.analysis;
            obj.superElementID = superElementIDIn;
            obj.fixedHeading = sprintf('\n\n     TITLE: %-60s     SUBCASE: %d\n  SUBTITLE: %-60s    ANALYSIS: %s\n     LABEL: %-60sSUPERELEMENT: %d\n',...
                    obj.title,obj.subcase,obj.subtitle,obj.analysis,obj.label,obj.superElementID);
        end
        function obj = set.superElementID(obj,superElementIDIn)
            obj.superElementID = superElementIDIn;
            obj.fixedHeading = sprintf('\n\n     TITLE: %-60s     SUBCASE: %d\n  SUBTITLE: %-60s    ANALYSIS: %s\n     LABEL: %-60sSUPERELEMENT: %d\n',...
                    obj.title,obj.subcase,obj.subtitle,obj.analysis,obj.label,obj.superElementID);
        end
        function printTextOutput(obj,fid,modeNumber)
            fprintf(fid,obj.fixedHeading);
            if ~isempty(obj.headingVector) && nargin > 2
                fprintf(fid,'      MODE: %d\n',modeNumber);
                fprintf(fid,obj.headingVectorText,obj.headingVector(modeNumber));
            end
        end
    end
end
