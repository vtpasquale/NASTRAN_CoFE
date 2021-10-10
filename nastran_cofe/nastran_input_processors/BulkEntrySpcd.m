% Class for SPCD entries
% Anthony Ricciardi
%
classdef BulkEntrySpcd < BulkEntry
    properties
        sid % [uint32] Identification number of single-point constraint set.
        g1 % [1,: uint32] Node 1 identification number.
        c1 % [:,1 uint32] Node 1 component numbers. Zero OR a sequential combination of integers 1 thru 6.
        d1 % [double] Value of enforced displacement for node 1 components c.
        g2 % [1,: uint32] Node 2 identification number.
        c2 % [:,1 uint32] Node 2 component numbers. Zero OR a sequential combination of integers 1 thru 6.
        d2 % [double] Value of enforced displacement for node 2 components c.
    end
    
    methods
        function obj = BulkEntrySpcd(entryFields)
            if nargin > 0
                % Construct using entry field data input as cell array of char
                obj.sid = castInputField('SPCD','SID',entryFields{2},'uint32',NaN,1);
                obj.g1 = castInputField('SPCD','G1',entryFields{3},'uint32',NaN,0);
                obj.c1 = castInputField('SPCD','C1',entryFields{4},'uint32',NaN,0,123456);
                obj.c1 = expandComponents(obj.c1,'SPCD C1',true);
                obj.d1 = castInputField('SPCD','D1',entryFields{5},'double',NaN);
                
                obj.g2 = castInputField('SPCD','G2',entryFields{6},'uint32',[],0);
                obj.c2 = castInputField('SPCD','C2',entryFields{7},'uint32',[],0,123456);
                if ~isempty(obj.c2)
                    obj.c2 = expandComponents(obj.c2,'SPCD C2',true);
                end
                obj.d2 = castInputField('SPCD','D2',entryFields{8},'double',[]);
                if ~isempty(obj.g2) && any([isempty(obj.c2),isempty(obj.d2)])
                    error('When the SPCD entry G2 field is nonblank, C2 and D2 fields are required.')
                end
            end
        end
        function model = entry2model_sub(obj,model)
            % Convert entry object to model object and store in model entity array
            spcon1 = Spcd;
            spcon1.sid = obj.sid;
            spcon1.c = obj.c1;
            spcon1.g = obj.g1;
            spcon1.d = obj.d1;
            model.load(end+1,1)=spcon1;
            if ~isempty(obj.g2)
                spcon2 = Spcd;
                spcon2.sid = obj.sid;
                spcon2.c = obj.c2;
                spcon2.g = obj.g2;
                spcon2.d = obj.d2;
                model.load(end+1,1)=spcon2;
            end
        end
        function echo_sub(obj,fid)
            % Print the entry in NASTRAN free field format to a text file with file id fid
            if isempty(obj.g2)
                fprintf(fid,'SPCD,%d,%d,%s,%f\n',obj.sid,obj.g1,num2str(obj.c1),obj.d1);
            else
                fprintf(fid,'SPCD,%d,%d,%s,%f,%d,%s,%f\n',obj.sid,obj.g1,num2str(obj.c1),obj.d1,obj.g2,num2str(obj.c2),obj.d2);
            end
        end
    end
end

