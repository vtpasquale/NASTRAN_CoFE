% Class for CTRIA3 entry
% Anthony Ricciardi
%
classdef BulkEntryCtria3 < BulkEntry
    
    properties
        eid % [uint32] Element identification number.
        pid % [uint32] Property identification number. (Default = eid)
        g1  % [uint32] Grid point identification number of connection point 1.
        g2  % [uint32] Grid point identification number of connection point 2.
        g3  % [uint32] Grid point identification number of connection point 3.
        thetaORmcid % [mixed] Material property orientation angle in degrees [double] or material coordinate system identification number [uint32]
        tFlag % [logical] specifies how t is used to define thickness of element. If TFLAG=0. If TFLAG=1, thickness becomes a product of Ti and the thickness on the PSHELL card.
        t1 % [double] Thickness or thickness coefficent of element at connection point 1.
        t2 % [double] Thickness or thickness coefficent of element at connection point 2.
        t3 % [double] Thickness or thickness coefficent of element at connection point 3.
    end
    methods
        function obj = BulkEntryCtria3(entryFields)
            % Construct using entry field data input as cell array of char
            obj.eid = castInputField('CTRIA3','EID',entryFields{2},'uint32',NaN,1);
            obj.pid = castInputField('CTRIA3','PID',entryFields{3},'uint32',obj.eid,1);
            obj.g1 = castInputField('CTRIA3','G1',entryFields{4},'uint32',NaN,1);
            obj.g2 = castInputField('CTRIA3','G2',entryFields{5},'uint32',NaN,1);
            obj.g3 = castInputField('CTRIA3','G3',entryFields{6},'uint32',NaN,1);
            if size(unique([obj.g1,obj.g2,obj.g3]),2)~=3
                error('G1, G2, and G3 fields must be unique on CTRIA3 entries.')
            end
            
            if size(entryFields,2)>10
                obj.tFlag = castInputField('CTRIA3','TFLAG',entryFields{13},'uint32',[],0,1);
                obj.t1 = castInputField('CTRIA3','T1',entryFields{14},'double',[],0.0);
                obj.t2 = castInputField('CTRIA3','T2',entryFields{15},'double',[],0.0);
                obj.t3 = castInputField('CTRIA3','T3',entryFields{16},'double',[],0.0);
            end
            % set tFlag to logical
            if isempty(obj.tFlag)
                obj.tFlag = false;
            elseif obj.tFlag==0
                obj.tFlag = false;
            else
                obj.tFlag = true;
            end
        end
        function model = entry2model_sub(obj,model)
            % Convert entry object to model object and store in model entity array
            ctria3 = Ctria3;
            ctria3.eid = obj.eid;
            ctria3.pid = obj.pid;
            ctria3.g = [obj.g1,obj.g2,obj.g3];
            ctria3.tFlag = obj.tFlag;
            ctria3.t = [obj.t1,obj.t2,obj.t3];
            model.element = [model.element;ctria3];
        end
        % Print the entry in NASTRAN free field format to a text file with file id fid
        function echo_sub(obj,fid)
            error('TODO')
            fprintf(fid,'CTRIA3,%d,%d,%d,%d,%f,%f,%f\n',obj.eid,obj.pid,obj.ga,obj.gb,obj.x(1),obj.x(2),obj.x(3));
        end
    end
    
    
end
