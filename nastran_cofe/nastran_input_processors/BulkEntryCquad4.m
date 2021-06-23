% Class for CQUAD4 entry
% Anthony Ricciardi
%
classdef BulkEntryCquad4 < BulkEntry
    
    properties
        eid % [uint32] Element identification number.
        pid % [uint32] Property identification number. (Default = eid)
        g1  % [uint32] Grid point identification number of connection point 1.
        g2  % [uint32] Grid point identification number of connection point 2.
        g3  % [uint32] Grid point identification number of connection point 3.
        g4  % [uint32] Grid point identification number of connection point 4.
        thetaORmcid % [mixed] Material property orientation angle in degrees [double] or material coordinate system identification number [uint32]
        tFlag % [logical] specifies how t is used to define thickness of element. If TFLAG=0. If TFLAG=1, thickness becomes a product of Ti and the thickness on the PSHELL card.
        t1 % [double] Thickness or thickness coefficent of element at connection point 1.
        t2 % [double] Thickness or thickness coefficent of element at connection point 2.
        t3 % [double] Thickness or thickness coefficent of element at connection point 3.
        t4 % [double] Thickness or thickness coefficent of element at connection point 4.
    end
    methods
        function obj = BulkEntryCquad4(entryFields)
            % Construct using entry field data input as cell array of char
            obj.eid = castInputField('CQUAD4','EID',entryFields{2},'uint32',NaN,1);
            obj.pid = castInputField('CQUAD4','PID',entryFields{3},'uint32',obj.eid,1);
            obj.g1 = castInputField('CQUAD4','G1',entryFields{4},'uint32',NaN,1);
            obj.g2 = castInputField('CQUAD4','G2',entryFields{5},'uint32',NaN,1);
            obj.g3 = castInputField('CQUAD4','G3',entryFields{6},'uint32',NaN,1);
            obj.g4 = castInputField('CQUAD4','G4',entryFields{7},'uint32',NaN,1);
            if size(unique([obj.g1,obj.g2,obj.g3,obj.g4]),2)~=4
                error('G1, G2, G3, and G4 fields must be unique on CQUAD4 entries.')
            end
            
            if size(entryFields,2)>10
                obj.tFlag = castInputField('CQUAD4','TFLAG',entryFields{13},'uint32',[],0,1);
                obj.t1 = castInputField('CQUAD4','T1',entryFields{14},'double',[],0.0);
                obj.t2 = castInputField('CQUAD4','T2',entryFields{15},'double',[],0.0);
                obj.t3 = castInputField('CQUAD4','T3',entryFields{16},'double',[],0.0);
                obj.t4 = castInputField('CQUAD4','T4',entryFields{17},'double',[],0.0);
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
            cquad4 = Cquad4;
            cquad4.eid = obj.eid;
            cquad4.pid = obj.pid;
            cquad4.g = [obj.g1,obj.g2,obj.g3,obj.g4];
            cquad4.tFlag = obj.tFlag;
            cquad4.t = [obj.t1,obj.t2,obj.t3,obj.t4];
            model.element(end+1,1) = cquad4;
        end
        % Print the entry in NASTRAN free field format to a text file with file id fid
        function echo_sub(obj,fid)
            error('TODO')
            fprintf(fid,'CQUAD4,%d,%d,%d,%d,%f,%f,%f\n',obj.eid,obj.pid,obj.ga,obj.gb,obj.x(1),obj.x(2),obj.x(3));
        end
    end
    
    
end
