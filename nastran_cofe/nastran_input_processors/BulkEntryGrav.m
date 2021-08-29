% Class for GRAV entries
% Anthony Ricciardi
%
classdef BulkEntryGrav < BulkEntry
    
    properties
        sid % [uint32] Load set identification number. ( > 0)
        cid % [uint32] Coordinate system identification number. ( >= 0; Default = 0)
        a % [double] Scale factor.
        n1 % Components of a vector expressed in coordinate system defined by CID. (Real; at least one ni ~= 0.0. unless a is zero)
        n2
        n3
    end
    
    methods
        function obj = BulkEntryGrav(entryFields)
            % Construct using entry field data input as cell array of char
            obj.sid = castInputField('GRAV','SID',entryFields{2},'uint32',NaN,1);
            obj.cid = castInputField('GRAV','CID',entryFields{3},'uint32',uint32(0),uint32(0));            
            obj.a = castInputField('GRAV','A',entryFields{4},'double',NaN);
            obj.n1 = castInputField('GRAV','N1',entryFields{5},'double',0.0);
            obj.n2 = castInputField('GRAV','N2',entryFields{6},'double',0.0);
            obj.n3 = castInputField('GRAV','N3',entryFields{7},'double',0.0);
            if obj.a ~= 0 && all([obj.n1,obj.n2,obj.n3]==0)
                error('Error with GRAV CID=%d: at least one Ni ~= 0.0. Unless A is zero.',obj.sid)
            end
            if ~isempty(entryFields{8})
                warning('MB field on GRAV CID=%d entry is ignored.',obj.sid)
            end
        end
        function model = entry2model_sub(obj,model)
        % Convert entry object to model object and store in model entity array
            grav = Grav;
            grav.sid = obj.sid;
            grav.cid = obj.cid;
            grav.a = obj.a*[obj.n1;obj.n2;obj.n3];
            model.load = [model.load;grav];
        end
        function echo_sub(obj,fid)
            % Print the entry in NASTRAN free field format to a text file with file id fid
            fprintf(fid,'GRAV,%d,%d,%f,%f,%f,%f\n',obj.sid,obj.cid,obj.a,obj.n1,obj.n2,obj.n3);
        end
    end
end

