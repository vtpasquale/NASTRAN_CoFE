% Class for RBE2 entries
% Anthony Ricciardi
%
classdef BulkEntryRbe2 < BulkEntry
    properties
        eid % [uint32] Element identification number.
        gn  % [uint32] Identification number of grid point to which all six independent degrees-of freedom for the element are assigned.
        cm  % [nComponents,1 uint32] Component numbers of the dependent degrees-of-freedom in the global coordinate system at grid points GMi. (Integers 1 through 6 with no embedded blanks.)
        gm  % [nDependentNodes,1 uint32] Grid point identification numbers at which dependent degrees-of-freedom are assigned.
    end
    
    methods
        function obj = BulkEntryRbe2(entryFields)
            % Construct using entry field data input as cell array of char
            obj.eid = castInputField('RBE2','EID',entryFields{2},'uint32',NaN,1);
            obj.gn = castInputField('RBE2','GN',entryFields{3},'uint32',NaN,1);
            obj.cm = castInputField('RBE2','CM',entryFields{4},'uint32',NaN,1,123456);
            obj.cm = expandComponents(obj.cm,'RBE2 CM',false);

            obj.gm(1) = castInputField('RBE2','GM1',entryFields{5},'uint32',NaN);
            n=size(entryFields,2);
            col = 6;
            while col<=n
                if strcmp(entryFields{col},'')
                    break
                else
                    obj.gm=[obj.gm,castInputField('RBE2','GMi',entryFields{col},'uint32',NaN)];
                end
                col = col + 1;
                if mod(col,10)==0
                    col=col+2;
                end
            end
            if size(unique(obj.gm),2)~=size(obj.gm,2)
                error('GRID IDs specified in RBE2 EID = %d should be unique.',obj.eid)
            end
        end
        function model = entry2model_sub(obj,model)
            % Convert entry object to model object and store in model entity array
            rbe2 = Rbe2;
            rbe2.eid = obj.eid;
            rbe2.gn = obj.gn;
            rbe2.cm = obj.cm;
            rbe2.gm = obj.gm;
            model.mpcs(end+1,1)=rbe2;
        end
        % Print the entry in Nastran free field format to a text file with file id fid
        function echo_sub(obj,fid)
            nM=size(obj.gm,2);
            echostr = ['RBE2,%d,%d,%d',repmat(',%d',[1,min([5,nM])]),'\n'];
            if nM > 5
                col=2;
                for i = 6:nM
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
            objcm = str2num(num2str(obj.cm)');
            fprintf(fid,echostr,obj.eid,obj.gn,objcm,obj.gm);
        end
    end
end

