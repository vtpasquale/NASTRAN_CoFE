% Class for LOAD entries
% Anthony Ricciardi
%
classdef BulkEntryLoad < BulkEntry
    
    properties
        sid % [uint32] Load set identification number. ( > 0)
        s % [double] Overall scale factor. 
        si % [n,1 double] Scale factor on li.
        li % [n,1 uint32] Load set identification numbers.
    end
    
    methods
        function obj = BulkEntryLoad(entryFields)
            % Construct using entry field data input as cell array of char
            obj.sid = castInputField('LOAD','SID',entryFields{2},'uint32',NaN,1);
            obj.s = castInputField('LOAD','S',entryFields{3},'double',[]);
            
            i = 1;
            line = 1;
            col = 6;
            obj.si(i) = castInputField('LOAD','S1',entryFields{4},'double',[]);
            obj.li(i) = castInputField('LOAD','L1',entryFields{5},'uint32',[]);
            nEntryFields = size(entryFields,2);
            nLines = ceil(nEntryFields/10);
            while line <= nLines
                field = 10*(line-1)+col;
                if isempty(entryFields{field})
                    return
                end
                i = i + 1;
                obj.si(i) = castInputField('LOAD','Si',entryFields{field},'double',[]);
                obj.li(i) = castInputField('LOAD','Li',entryFields{field+1},'uint32',[]);
                col = col + 2;
                if col > 9
                    line = line + 1;
                    col = 2;
                end
            end
        end
        function model = entry2model_sub(obj,model)
        % Convert entry object to model object and store in model entity array
            loadCombination = LoadCombination;
            loadCombination.sid = obj.sid;
            loadCombination.s   = obj.s;
            loadCombination.si  = obj.si;
            loadCombination.li  = obj.li;
            if size(unique(loadCombination.li),2)~=size(loadCombination.li,2)
                error('LOAD SID=%d entry Li fields must be unique.',obj.sid)
            end
            model.load = [model.load;loadCombination];
        end
        function echo_sub(obj,fid)
            % Print the entry in NASTRAN free field format to a text file with file id fid
            fprintf(fid,'LOAD,%d,%f,%f,%d,',obj.sid,obj.s,obj.li(1),obj.si(1));
            nI = size(obj.li,2);
            
            col = 6;
            for i = 2:nI
                fprintf(fid,'%f,%d,',obj.si(i),obj.li(i));
                col = col + 2;
                if col > 9
                    col = 2;
                    fprintf(fid,'\n');
                end
            end
            if col ~= 2
                fprintf(fid,'\n');
            end
        end
    end
end

