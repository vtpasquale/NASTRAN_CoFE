% Class for PROD property entries
% Anthony Ricciardi
%
classdef BulkEntryProd < BulkEntry
    
    properties
        pid % Property identification number. (Integer > 0)
        mid % Material identification number. (Integer > 0)
        a % Area of the rod. (Real)
        j % Torsional constant. (Real)
        c % Coefficient to determine torsional stress. (Real; Default = 0.0)
        nsm % Nonstructural mass per unit length. (Real)
    end
    
    methods
        function obj = BulkEntryProd(entryFields)
            % Construct using entry field data input as cell array of char
            obj.pid = castInputField('PROD','PID',entryFields{2},'uint32',NaN,1);
            obj.mid = castInputField('PROD','MID',entryFields{3},'uint32',NaN,1);
            obj.a = castInputField('PROD','A',entryFields{4},'double',NaN);
            obj.j = castInputField('PROD','J',entryFields{5},'double',NaN);
            obj.c = castInputField('PROD','C',entryFields{6},'double',[],0.0);
            obj.nsm = castInputField('PROD','NSM',entryFields{7},'double',0.0);
        end
        function model = entry2model_sub(obj,model)
            % Convert entry object to model object and store in model entity array
            prod = Prod;
            prod.pid = obj.pid;
            prod.mid = obj.mid;
            prod.a = obj.a;
            prod.j = obj.j;
            prod.c = obj.c;
            prod.nsm = obj.nsm;
            model.property = [model.property;prod];
        end
        % Print the entry in NASTRAN free field format to a text file with file id fid
        function echo_sub(obj,fid)
            fprintf(fid,'PROD,%d,%d,%f,%f,,%f\n',obj.pid,obj.mid,obj.a,obj.j,obj.nsm);
        end
    end
end

