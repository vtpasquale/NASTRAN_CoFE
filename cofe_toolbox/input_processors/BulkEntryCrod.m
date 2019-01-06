% Class for CROD entry, a tension-compression-torsion element.
% Anthony Ricciardi
%
classdef BulkEntryCrod < BulkEntry
    
    properties
        eid % Element identification number. (0 < Integer < 100,000,000)
        pid % Property identification number of a PROD entry. (Integer > 0; Default = EID)
        g1 % Grid point identification numbers of connection points. (Integer > 0; G1 ~= G2 )
        g2
    end
    methods
        function obj = BulkEntryCrod(entryFields)
            % Construct using entry field data input as cell array of char
            obj.eid = castInputField('CROD','EID',entryFields{2},'uint32',NaN,1);
            obj.pid = castInputField('CROD','PID',entryFields{3},'uint32',obj.eid,1);
            obj.g1 = castInputField('CROD','G1',entryFields{4},'double',NaN,1);
            obj.g2 = castInputField('CROD','G2',entryFields{5},'double',NaN,1);
            if obj.g1 == obj.g2
                error('G1 and G2 fields must be unique on CROD entries.')
            end
        end
        function model = entry2model_sub(obj,model)
            % Convert entry object to model object and store in model entity array
            crod = Crod;
            crod.eid = obj.eid;
            crod.pid = obj.pid;
            crod.g = [obj.g1,obj.g2];
            model.element = [model.element;crod];
        end
        % Print the entry in NASTRAN free field format to a text file with file id fid
        function echo_sub(obj,fid)
            fprintf(fid,'CROD,%d,%d,%d,%d\n',obj.eid,obj.pid,obj.g1,obj.g2);
        end
    end
    
    
end
