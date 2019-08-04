% Class for PMASS property entries
% Anthony Ricciardi
%
classdef BulkEntryPmass < BulkEntry
    
    properties
        pid1 % Property identification number. (Integer > 0)
        m1 % Value of scalar mass. (Real)
        pid2
        m2
        pid3
        m3
        pid4
        m4
    end
    
    methods
        function obj = BulkEntryPmass(entryFields)
            % Construct using entry field data input as cell array of char
            obj.pid1 = castInputField('PMASS','PID1',entryFields{2},'uint32',NaN,1);
            obj.m1 = castInputField('PMASS','M1',entryFields{3},'double',NaN,0);
            obj.pid2 = castInputField('PMASS','PID2',entryFields{4},'uint32',[],1);
            obj.m2 = castInputField('PMASS','M2',entryFields{5},'double',[],0);
            obj.pid3 = castInputField('PMASS','PID3',entryFields{6},'uint32',[],1);
            obj.m3 = castInputField('PMASS','M3',entryFields{7},'double',[],0);
            obj.pid4 = castInputField('PMASS','PID4',entryFields{8},'uint32',[],1);
            obj.m4 = castInputField('PMASS','M4',entryFields{9},'double',[],0);
        end
        % Write appropriate model object(s) based on entry data
        function model = entry2model_sub(obj,model)
            pmass = Pmass;
            pmass.pid = obj.pid1;
            pmass.m = obj.m1;
            if ~isempty(obj.pid2)
                pmass(2,1).pid = obj.pid2;
                pmass(2,1).m = obj.m2;
                if ~isempty(obj.pid3)
                    pmass(3,1).pid = obj.pid3;
                    pmass(3,1).m = obj.m3;
                    if ~isempty(obj.pid4)
                        pmass(4,1).pid = obj.pid4;
                        pmass(4,1).m = obj.m4;
                    end
                end
            end
            model.property = [model.property;pmass];
        end
        % Print the entry in NASTRAN free field format to a text file with file id fid
        function echo_sub(obj,fid)
            fprintf(fid,'PMASS,%d,%f,%d,%f,%d,%f,%d,%f\n',obj.pid1,obj.m1,obj.pid2,obj.m2,obj.pid3,obj.m3,obj.pid4,obj.m4);
        end
        
    end
end
