% Class used to create Femap Neutral File header and store iterator values
% for subsequent data blocks.
% Anthony Ricciardi
%
classdef FemapDataBlock100 < FemapDataBlock
    
    properties
        currentAnalysisStudy
        currentOutputSet
    end
    properties (Constant = true, Hidden = true)
        FEMAP_VERSION_FORMAT = 11.4;
        DATA_BLOCK_ID = int32(100);
    end
    methods
        function writeNeutral_sub(obj,fid)
            % Neutral File Header
            fprintf(fid,'   -1\n');
            fprintf(fid,'   100\n');
            fprintf(fid,'<NULL>\n');
            fprintf(fid,'%g,\n',obj.FEMAP_VERSION_FORMAT);
            fprintf(fid,'   -1\n');
        end
        function obj = FemapDataBlock100(startAnalysisStudy,startOutputSet)
            % Class constructor method
            if nargin == 0
                obj.currentAnalysisStudy = 1;
                obj.currentAnalysisStudy = 1;
            else
                obj.currentAnalysisStudy = startAnalysisStudy;
                obj.currentAnalysisStudy = startOutputSet;
            end
        end
        function obj=advanceOutputSet(obj,value)
            if nargin < 2
                obj.currentOutputSet = obj.currentOutputSet + 1;
            else
                obj.currentOutputSet = obj.currentOutputSet + value;
            end
        end
        function obj=advanceAnalysisStudy(obj)
            obj.currentAnalysisStudy = obj.currentAnalysisStudy + 1;
        end
    end
end

