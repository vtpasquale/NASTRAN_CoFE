% Class for SPC1 entries
% Anthony Ricciardi
%
classdef spc1 < entry
    properties
        SID % Identification number of single-point constraint set. (Integer > 0)
        C % Component numbers. (Any unique combination of the Integers 1 through 6 with no embedded blanks for grid points.)
        G % [1,: int] Node identification numbers.
    end
    
    methods (Static = true)
        % Initialize entry properties based on input file entry data in cell format
        function SPC1 = initialize(data)
            SPC1 = spc1;
            SPC1.SID = set_data('SPC1','SID',data{2},'int',NaN);
            SPC1.C = set_data('SPC1','C',data{3},'int',NaN,1,123456);
            check_int1thru6(SPC1.C,'SPC1','SID',SPC1.SID,'C');

            SPC1.G(1) = set_data('SPC1','G',data{4},'int',NaN);
            n=size(data,2);
            col = 5;
            thru=false;
            while col<=n
                if strcmp(data{col},'')
                    break
                elseif strcmpi(data{col},'THRU')
                    thru=true;
                    gstart = SPC1.G(end);
                else
                    if thru
                        gfinish = set_data('SPC1','G',data{col},'int',NaN);
                        SPC1.G=[SPC1.G(1:end-1),gstart:gfinish];
                        thru=false;
                    else
                        SPC1.G=[SPC1.G,set_data('SPC1','G',data{col},'int',NaN)];
                    end
                end
                col = col + 1;
                if isempty(data{col})
                    col=col+2;
                end
            end
            if size(unique(SPC1.G),2)~=size(SPC1.G,2);
                error('GRID IDs specified in SPC1 SID = %d should be unique.',SPC1.SID)
            end
        end
    end
    methods
        % Write appropriate model object(s) based on entry data
        function MODEL = entry2model(obj,MODEL)
            SPCON = spcon;
            SPCON.SID = obj.SID;
            SPCON.C = int32(str2num(num2str(obj.C)'))';
            SPCON.G = obj.G;
            SPCON.D=0.0;
            MODEL.SPCS=[MODEL.SPCS;SPCON];
        end
        % Print the entry in NASTRAN free field format to a text file with file id fid
        function echo(obj,fid)
            ng=size(obj.G,2);
            echostr = ['SPC1,%d,%d,%d',repmat(',%d',[1,min([5,ng-1])]),'\n'];
            if ng > 6
                col=2;
                for i = 7:ng
                    echostr=[echostr,',%d'];
                    col=col+1;
                    if col == 10
                        echostr=[echostr,'\n'];
                        col = 2;
                    end
                end
            end
            if ~strcmpi(echostr(end-1:end),'\n')
                echostr=[echostr,'\n'];
            end
            fprintf(fid,echostr,obj.SID,obj.C,obj.G);
        end
    end
end

