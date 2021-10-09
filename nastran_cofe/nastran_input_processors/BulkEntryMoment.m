% Class for MOMENT entries
% Anthony Ricciardi
%
classdef BulkEntryMoment < BulkEntry
    
    properties
        sid % Load set identification number. (Integer > 0)
        g % Grid point identification number. (Integer > 0)
        cid % Coordinate system identification number. (Integer > 0; Default = 0)
        m % Scale factor. (Real)
        n1 % Components of the vector measured in coordinate system defined by CID. (Real; at least one Ni ~= 0.0. unless f is zero)
        n2
        n3
    end
    
    methods
        function obj = BulkEntryMoment(entryFields)
            % Construct using entry field data input as cell array of char
            obj.sid = castInputField('MOMENT','SID',entryFields{2},'uint32',NaN,1);
            obj.g = castInputField('MOMENT','G',entryFields{3},'uint32',NaN,1);
            obj.cid = castInputField('MOMENT','CID',entryFields{4},'uint32',uint32(0));            
            obj.m = castInputField('MOMENT','M',entryFields{5},'double',NaN);
            obj.n1 = castInputField('MOMENT','N1',entryFields{6},'double',0.0);
            obj.n2 = castInputField('MOMENT','N2',entryFields{7},'double',0.0);
            obj.n3 = castInputField('MOMENT','N3',entryFields{8},'double',0.0);
            if obj.m ~= 0 && all([obj.n1,obj.n2,obj.n3]==0)
                error('Error with MOMENT CID=%d: at least one Ni ~= 0.0. Unless M is zero.',obj.sid)
            end
        end
        function model = entry2model_sub(obj,model)
        % Convert entry object to model object and store in model entity array
            moment = Moment;
            moment.sid = obj.sid;
            moment.g = obj.g;
            moment.cid = obj.cid;
            moment.m = obj.f*[obj.n1;obj.n2;obj.n3];
            model.load = [model.load;moment];
        end
        function echo_sub(obj,fid)
            % Print the entry in Nastran free field format to a text file with file id fid
            fprintf(fid,'MOMENT,%d,%d,%d,%f,%f,%f,%f\n',obj.sid,obj.g,obj.cid,obj.m,obj.n1,obj.n2,obj.n3);
        end
    end
end

