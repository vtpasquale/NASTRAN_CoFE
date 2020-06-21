% Class for PBEAM property entries
% Anthony Ricciardi
%
classdef BulkEntryPbeam < BulkEntry
    
    properties
        pid % [uint32] Property identification number
        mid % [uint32] Material identification number
        a % [double] Area of the cross section
        i1 % [double] Area moments of inertia
        i2 % [double] Area moments of inertia
        i12 % [double] Area moments of inertia
        j % [double] Torsional constant
        nsm % [double] Nonstructural mass per unit length
        c1ThruF2 % [1,8 double] Stress recovery locations
        k1 % [double] Area factor for shear
        k2 % [double] Area factor for shear
    end
    
    methods
        function obj = BulkEntryPbeam(entryFields)
            % Construct using entry field data input as cell array of char
            obj.pid = castInputField('PBEAM','PID',entryFields{2},'uint32',NaN,1);
            obj.mid = castInputField('PBEAM','MID',entryFields{3},'uint32',NaN,1);
            obj.a = castInputField('PBEAM','A',entryFields{4},'double',0.0,0);
            obj.i1 = castInputField('PBEAM','I1',entryFields{5},'double',0.0,0);
            obj.i2 = castInputField('PBEAM','I2',entryFields{6},'double',0.0,0);
            obj.i12 = castInputField('PBEAM','I12',entryFields{7},'double',0.0,0);
            obj.j = castInputField('PBEAM','J',entryFields{8},'double',0.0,0);
            obj.nsm = castInputField('PBEAM','NSM',entryFields{9},'double',0.0,0);
            if size(entryFields,2)>10
                obj.c1ThruF2 = zeros(1,8);
                for i = 12:19
                    obj.c1ThruF2(i-11) = castInputField('PBEAM','C1 thru D1',entryFields{i},'double',0.0);
                end
            end
            % Allow SO=YESA and X/XB=1.0, which is equivalent to omitting
            % the fields. Femap writes these fields in some situations.
            if strcmpi(entryFields{22},'YESA') && str2double(entryFields{23})==1.0
                entryFields = entryFields([1:20,31:size(entryFields,2)]);
            end
            if size(entryFields,2)>20
                obj.k1 = castInputField('PBEAM','K1',entryFields{22},'double',1.0);
                obj.k2 = castInputField('PBEAM','K2',entryFields{23},'double',1.0);
            end
            if size(entryFields,2)>30
                error('PBEAM is supported, but not the format on EID = %d',obj.eid);
            end
        end
        function model = entry2model_sub(obj,model)
            % Convert entry object to model object and store in model entity array
            pbeam = Pbeam;
            pbeam.pid = obj.pid;
            pbeam.mid = obj.mid;
            pbeam.a = obj.a;
            pbeam.i1 = obj.i1;
            pbeam.i2 = obj.i2;
            pbeam.j = obj.j;
            if isempty(obj.c1ThruF2)
                pbeam.c1ThruF2 = zeros(1,8);
            else
                pbeam.c1ThruF2 = obj.c1ThruF2;
            end
            pbeam.nsm = obj.nsm;
            if isempty(obj.k1)
                pbeam.k1 = 1.0;
            else
                pbeam.k1 = obj.k1;
            end
            if isempty(obj.k2)
                pbeam.k2 = 1.0;
            else
                pbeam.k2 = obj.k2;
            end
            if ~isempty(obj.i12)
                if obj.i12~=0
                    error('Nonzero I12 not supported')
                end
            end
            model.property = [model.property;pbeam];
        end
        function echo_sub(obj,fid)
            % Print the entry in NASTRAN free field format to a text file with file id fid
            fprintf(fid,'PBEAM,%d,%d,%f,%f,%f,%f,%f,%f\n',obj.pid,obj.mid,obj.a,obj.i1,obj.i2,obj.i12,obj.j,obj.nsm);
            if any([~isempty(obj.c1ThruF2),~isempty(obj.k1),~isempty(obj.k2)])
                if isempty(obj.c1ThruF2)
                    obj.c1ThruF2 = zeros(1,8);
                end
                fprintf(fid,',%f,%f,%f,%f,%f,%f,%f,%f\n',obj.c1ThruF2);
            end
            if any([~isempty(obj.k1),~isempty(obj.k2)])
                fprintf(fid,',%f,%f\n',obj.k1,obj.k2);
            end
        end
    end
end

