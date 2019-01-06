% Class for FORCE entries
% Anthony Ricciardi
%
classdef BulkEntryForce < BulkEntry
    
    properties
        sid % Load set identification number. (Integer > 0)
        g % Grid point identification number. (Integer > 0)
        cid % Coordinate system identification number. (Integer > 0; Default = 0)
        f % Scale factor. (Real)
        n1 % Components of a vector measured in coordinate system defined by CID. (Real; at least one Ni ~= 0.0. unless f is zero)
        n2
        n3
    end
    
    methods
        function obj = BulkEntryForce(entryFields)
            % Construct using entry field data input as cell array of char
            obj.sid = castInputField('FORCE','SID',entryFields{2},'uint32',NaN,1);
            obj.g = castInputField('FORCE','G',entryFields{3},'uint32',NaN,1);
            obj.cid = castInputField('FORCE','CID',entryFields{4},'uint32',0);            
            obj.f = castInputField('FORCE','F',entryFields{5},'double',NaN);
            obj.n1 = castInputField('FORCE','N1',entryFields{6},'double',0.0);
            obj.n2 = castInputField('FORCE','N2',entryFields{7},'double',0.0);
            obj.n3 = castInputField('FORCE','N3',entryFields{8},'double',0.0);
            if obj.f ~= 0 && all([obj.n1,obj.n2,obj.n3]==0)
                error('Error with FORCE CID=%d: at least one Ni ~= 0.0. Unless F is zero.',obj.sid)
            end
        end
        function model = entry2model_sub(obj,model)
        % Convert entry object to model object and store in model entity array
            force = Force;
            force.sid = obj.sid;
            force.g = obj.g;
            force.cid = obj.cid;
            force.f = obj.f*[obj.n1;obj.n2;obj.n3];
            model.load = [model.load;force];
        end
        function echo_sub(obj,fid)
            % Print the entry in NASTRAN free field format to a text file with file id fid
            fprintf(fid,'FORCE,%d,%d,%d,%f,%f,%f,%f\n',obj.sid,obj.g,obj.cid,obj.f,obj.n1,obj.n2,obj.n3);
        end
    end
end

