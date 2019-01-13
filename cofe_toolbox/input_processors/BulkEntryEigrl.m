% Class for EIGRL entries
% Anthony Ricciardi
%
classdef BulkEntryEigrl < BulkEntry
    
    properties
        sid % Set identification number. (Unique Integer > 0)
%         v1 % For vibration analysis: min frequency of interest. For buckling analysis: min eigenvalue of interest. (Real or blank)
%         v2 % For vibration analysis: max frequency of interest. For buckling analysis: max eigenvalue of interest. (Real or blank)
        nd % Number of roots desired. (Integer > 0 or blank)
%         msglvl % Diagnostic level. (0 < Integer < 4; Default = 0)
%         maxset % Number of vectors in block or set. Default is machine dependent. See Remark 14.
%         shfscl % Estimate of the first flexible mode natural frequency. See Remark 10. (Real or blank)
%         norm % Method for normalizing eigenvectors (Character: "MASS" or "MAX")
    end
        methods (Static = true)
            function obj = BulkEntryEigrl(entryFields)
            % Construct using entry field data input as cell array of char
                obj.sid = castInputField('EIGRL','SID',entryFields{2},'uint32',NaN,1);
%                 obj.v1 = castInputField('EIGRL','V1',entryFields{3},'double',[]);
%                 obj.v2 = castInputField('EIGRL','V2',entryFields{4},'double',[]);
                obj.nd = castInputField('EIGRL','ND',entryFields{5},'uint32',[],1);
%                 obj.msglvl = castInputField('EIGRL','MSGLVL',entryFields{6},'uint32',0,0,4);
%                 obj.maxset = castInputField('EIGRL','MAXSET',entryFields{7},'uint32',[],1);
%                 obj.shfscl = castInputField('EIGRL','SHFSCL',entryFields{8},'double',[],1);
%                 obj.norm = castInputField('EIGRL','NORM',entryFields{9},'char','MASS');                
            end
        end
        methods
            function model = entry2model_sub(obj,model)
                % Convert entry object to model object and store in model entity array
                if isempty(obj.nd)
                    error('ND is blank for EIGRL SID = %s. A nonblank integer is required.',obj.sid)
                end
                model.eigTab = [model.eigTab;obj.sid,obj.nd];
            end
            function echo_sub(obj,fid)
                % Print the entry in NASTRAN free field format to a text file with file id fid
                fprintf(fid,'EIGRL,%d,,,%d\n',obj.sid,obj.nd);
            end
            
        end
end