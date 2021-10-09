% Class for RBE3 entries
% Anthony Ricciardi
%
classdef BulkEntryRbe3 < BulkEntry
    properties
        eid % [uint32] Element identification number.
        refgrid  % [uint32] Reference grid point identification number.
        refc  % [nComponents,1 uint32] Component numbers at the reference grid point. (Integers 1 through 6 with no embedded blanks.)
        wt1 % [double] Relative weighting factor for components of motion on the following entry at grid points G1,j. This value does not affect the solution because the user is limited to a single relative weighting factor.
        c1  % [nComponents,1 uint32] Component numbers with weighting factor WT1 at grid points G1,j. (Integers 1 through 6 with no embedded blanks.)
        g1  % [1,nIndependentNodes uint32] Grid points with components C1 that have weighting factor WT1 in the averaging equations.
    end
    
    methods
        function obj = BulkEntryRbe3(entryFields)
            if nargin > 0
                % Construct using entry field data input as cell array of char
                obj.eid = castInputField('RBE3','EID',entryFields{2},'uint32',NaN,1);
                obj.refgrid = castInputField('RBE3','REFGRID',entryFields{4},'uint32',NaN,1);
                obj.refc = castInputField('RBE3','REFC',entryFields{5},'uint32',NaN,1,123456);
                obj.refc = expandComponents(obj.refc,'RBE3 REFC',false);
                obj.wt1 = castInputField('RBE3','WT1',entryFields{6},'double',NaN);
                obj.c1 = castInputField('RBE3','C1',entryFields{7},'uint32',NaN,1,123456);
                obj.c1 = expandComponents(obj.c1,'RBE3 C1',false);
                obj.g1(1) = castInputField('RBE3','G1,j',entryFields{8},'uint32',NaN,1);
                
                n=size(entryFields,2);
                col = 9;
                while col<=n
                    if strcmp(entryFields{col},'')
                        break
                    else
                        obj.g1(1,end+1)=castInputField('RBE3','G1,j',entryFields{col},'uint32',NaN,1);
                    end
                    col = col + 1;
                    if mod(col,10)==0
                        col=col+2;
                    end
                end
                if size(unique(obj.g1),2)~=size(obj.g1,2)
                    error('G1,j IDs specified in RBE3 EID = %d should be unique.',obj.eid)
                end
            end
        end
        function model = entry2model_sub(obj,model)
            % Convert entry object to model object and store in model entity array
            rbe3 = Rbe3;
            rbe3.eid     = obj.eid;
            rbe3.refgrid = obj.refgrid;
            rbe3.refc    = obj.refc;
            rbe3.c1      = obj.c1;
            rbe3.g1      = obj.g1;
            model.mpcs(end+1,1)=rbe3;
        end
        % Print the entry in Nastran free field format to a text file with file id fid
        function echo_sub(obj,fid)
            nN=size(obj.g1,2);
            echostr = ['RBE3,%d,,%d,%d,%f,%d',repmat(',%d',[1,min([2,nN])]),'\n'];
            if nN > 2
                col=2;
                for i = 3:nN
                    echostr=[echostr,',%d'];
                    col=col+1;
                    if col == 10
                        echostr=[echostr,'\n'];
                        col = 2;
                    end
                end
            end
            if ~strcmpi(echostr(end-1:end),'\n')
                echostr=[echostr,'\n'];
            end
            objRefc = str2num(num2str(obj.refc)');
            objC1 = str2num(num2str(obj.c1)');
            fprintf(fid,echostr,obj.eid,obj.refgrid,objRefc,obj.wt1,objC1,obj.g1);
        end
    end
end

