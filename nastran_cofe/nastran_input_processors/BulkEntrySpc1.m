% Class for SPC1 entries
% Anthony Ricciardi
%
classdef BulkEntrySpc1 < BulkEntry
    properties
        sid % [uint32] Identification number of single-point constraint set.
        c % [:,1 uint32] Component numbers. Zero OR a sequential combination of integers 1 thru 6.
        g % [1,: uint32] Node identification numbers.
        d % [double] Value of enforced displacement for components C.
    end
    
    methods
        function obj = BulkEntrySpc1(entryFields)
            % Construct using entry field data input as cell array of char
            obj.sid = castInputField('SPC1','sid',entryFields{2},'uint32',NaN,0);
            obj.c = castInputField('SPC1','C',entryFields{3},'uint32',NaN,0,123456);
            obj.c = expandComponents(obj.c,'SPC1 C',true);

            obj.g(1) = castInputField('SPC1','G',entryFields{4},'uint32',NaN);
            n=size(entryFields,2);
            col = 5;
            thru=false;
            while col<=n
                if strcmp(entryFields{col},'')
                    break
                elseif strcmpi(entryFields{col},'THRU')
                    thru=true;
                    gstart = obj.g(end);
                else
                    if thru
                        gfinish = castInputField('SPC1','G',entryFields{col},'uint32',NaN);
                        obj.g=[obj.g(1:end-1),gstart:gfinish];
                        thru=false;
                    else
                        obj.g=[obj.g,castInputField('SPC1','G',entryFields{col},'uint32',NaN)];
                    end
                end
                col = col + 1;
                if isempty(entryFields{col})
                    col=col+2;
                end
            end
            if size(unique(obj.g),2)~=size(obj.g,2);
                error('GRID IDs specified in SPC1 SID = %d should be unique.',obj.sid)
            end
        end
        function model = entry2model_sub(obj,model)
            % Convert entry object to model object and store in model entity array
            spcon = Spcon;
            spcon.sid = obj.sid;
            spcon.c = obj.c;
            spcon.g = obj.g;
            % spcon.d=0.0;
            model.spcs=[model.spcs;spcon];
        end
        % Print the entry in NASTRAN free field format to a text file with file id fid
        function echo_sub(obj,fid)
            ng=size(obj.g,2);
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
            objc = str2num(num2str(obj.c)');
            fprintf(fid,echostr,obj.sid,objc,obj.g);
        end
    end
end

