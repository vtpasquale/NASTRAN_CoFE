% Class for CBAR entry
% Anthony Ricciardi
%
classdef BulkEntryCbar < BulkEntry
    
    properties
        eid % [uint32] Element identification number.
        pid % [uint32] Property identification number of a PBEAM entry. (Default = eid)
        ga  % [uint32] Grid point identification number of connection point 1.
        gb  % [uint32] Grid point identification number of connection point 2.
        x   % [3,1 double] Components of orientation vector NU, from GA, in the displacement coordinate system at GA.
%         pa  % [:,1 uint32] Pin flags for beam end A. Up to five of the unique integers 1 through 6 with no embedded blanks.
%         pb  % [:,1 uint32] Pin flags for beam end B. Up to five of the unique integers 1 through 6 with no embedded blanks.
        
    end
    methods
        function obj = BulkEntryCbar(entryFields)
            % Construct using entry field data input as cell array of char
            obj.eid = castInputField('CBAR','EID',entryFields{2},'uint32',NaN,1);
            obj.pid = castInputField('CBAR','PID',entryFields{3},'uint32',obj.eid,1);
            obj.ga = castInputField('CBAR','GA',entryFields{4},'uint32',NaN,1);
            obj.gb = castInputField('CBAR','GA',entryFields{5},'uint32',NaN,1);
            if obj.ga == obj.gb
                error('GA and GB fields must be unique on CBAR entries.')
            end
            if isempty(entryFields{7})
                error('CBAR format error. The alternate method to supply the beam orientation vector NU using grid point G0 is not supported.');
            end
            x1 = castInputField('CBAR','X1',entryFields{6},'double',NaN);
            x2 = castInputField('CBAR','X2',entryFields{7},'double',NaN);
            x3 = castInputField('CBAR','X3',entryFields{8},'double',NaN);
            obj.x = [x1;x2;x3];
            if size(entryFields,2)>10
                error('CBAR continuation lines are not supported.')
            end
        end
        function model = entry2model_sub(obj,model)
            % Convert entry object to model object and store in model entity array
            cbeam = Cbeam;
            cbeam.eid = obj.eid;
            cbeam.pid = obj.pid;
            cbeam.g = [obj.g1,obj.g2];
            cbeam.nu_g = obj.x;
            model.element = [model.element;crod];
        end
        % Print the entry in NASTRAN free field format to a text file with file id fid
        function echo_sub(obj,fid)
            fprintf(fid,'CBAR,%d,%d,%d,%d,%f,%f,%f\n',obj.eid,obj.pid,obj.ga,obj.gb,obj.x(1),obj.x(2),obj.x(3));
        end
    end
    
    
end
