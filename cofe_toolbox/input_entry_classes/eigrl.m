% Class for EIGRL entries
% Anthony Ricciardi
%
classdef eigrl < entry
    
    properties
        SID % Set identification number. (Unique Integer > 0)
%         V1 % For vibration analysis: min frequency of interest. For buckling analysis: min eigenvalue of interest. (Real or blank)
%         V2 % For vibration analysis: max frequency of interest. For buckling analysis: max eigenvalue of interest. (Real or blank)
        ND % Number of roots desired. (Integer > 0 or blank)
%         MSGLVL % Diagnostic level. (0 < Integer < 4; Default = 0)
%         MAXSET % Number of vectors in block or set. Default is machine dependent. See Remark 14.
%         SHFSCL % Estimate of the first flexible mode natural frequency. See Remark 10. (Real or blank)
        NORM % Method for normalizing eigenvectors (Character: "MASS" or "MAX")
    end
        methods (Static = true)
            % Initialize entry properties based on input file entry data in cell format
            function EIGRL = initialize(data)
                EIGRL = eigrl;
                EIGRL.SID = set_data('EIGRL','SID',data{2},'int',NaN,1);
%                 EIGRL.V1 = set_data('EIGRL','V1',data{3},'dec',[]);
%                 EIGRL.V2 = set_data('EIGRL','V2',data{4},'dec',[]);
                EIGRL.ND = set_data('EIGRL','ND',data{5},'int',[],1);
%                 EIGRL.MSGLVL = set_data('EIGRL','MSGLVL',data{6},'int',0,0,4);
%                 EIGRL.MAXSET = set_data('EIGRL','MAXSET',data{7},'int',[],1);
%                 EIGRL.SHFSCL = set_data('EIGRL','SHFSCL',data{8},'dec',[],1);
%                 EIGRL.NORM = set_data('EIGRL','NORM',data{9},'str','MASS');                
            end
        end
        methods
            % Write appropriate model object(s) based on entry data
            function node = entry2model(obj)
                node = [];
            end
            % Print the entry in NASTRAN free field format to a text file with file id fid
            function echo(obj,fid)
                fprintf(fid,'EIGRL,%d,,,%d\n',obj.SID,obj.ND);
            end
            
        end
end