% Class for PLOAD4 entries
% Anthony Ricciardi
%
classdef BulkEntryPload4 < BulkEntry
    properties
        sid % [uint32] Load set identification number.
        eid % [uint32] Element identification number.
        p1 % [double] Face pressure load at element corner 1.
        p2 % [double] Face pressure load at element corner 2.
        p3 % [double] Face pressure load at element corner 3.
        p4 % [double] Face pressure load at element corner 4.
    end
    methods
        function obj = BulkEntryPload4(entryFields)
            % Construct using entry field data input as cell array of char
            obj.sid = castInputField('PLOAD4','SID',entryFields{2},'uint32',NaN,1);
            obj.eid = castInputField('PLOAD4','EID',entryFields{3},'uint32',NaN,1);
            obj.p1 = castInputField('PLOAD4','P1',entryFields{4},'double',NaN);
            obj.p2 = castInputField('PLOAD4','P2',entryFields{5},'double',obj.p1);
            obj.p3 = castInputField('PLOAD4','P3',entryFields{6},'double',obj.p1);
            obj.p4 = castInputField('PLOAD4','P4',entryFields{7},'double',obj.p1);
            if ~isempty(entryFields{8})
                error('PLOAD4 field 8 not supported.')
            end
            if ~isempty(entryFields{9})
                error('PLOAD4 field 9 not supported.')
            end
            if size(entryFields,2)>10
                error('PLOAD4 continuation lines are not supported.')
            end
        end
        function model = entry2model_sub(obj,model)
            % Convert entry object to model object and store in model entity array
            pload4 = Pload4;
            pload4.sid = obj.sid;
            pload4.eid = obj.eid;
            pload4.p = [obj.p1;obj.p2;obj.p3;obj.p4];
            model.load(end+1,1) = pload4;
        end
        function echo_sub(obj,fid)
            % Print the entry in NASTRAN free field format to a text file with file id fid
            fprintf(fid,'PLOAD4,%d,%d,%f,%f,%f,%f\n',obj.sid,obj.eid,obj.p1,obj.p2,obj.p3,obj.p4);
        end
    end
end

