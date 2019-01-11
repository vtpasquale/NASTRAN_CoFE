% Class for GRID entries
% Anthony Ricciardi
%
classdef BulkEntryGrid < BulkEntry
    
    properties
        id % Grid point identification number. (0 < Integer < 100,000,000)
        cp % Identification number of coordinate system in which the location of the grid point is defined. (Integer >= 0 or blank*)
        x1 % Location of the grid point in coordinate system CP. (Real; Default = 0.0)
        x2 % Location of the grid point in coordinate system CP. (Real; Default = 0.0)
        x3 % Location of the grid point in coordinate system CP. (Real; Default = 0.0)
        cd % Identification number of coordinate system in which the displacements, degrees-offreedom, constraints, and solution vectors are defined at the grid point. (Integer > 0 or blank*)
        ps % Permanent single-point constraints associated with the grid point. (Any of the Integers 1 through 6 with no embedded blanks, or blank*.)
        seid % Superelement identification number. (Integer > 0; Default = 0)
        % *See the GRDSET entry for default options for the CP, CD, PS, and SEID fields.
    end
    methods
        function obj = BulkEntryGrid(entryFields)
            % Construct using entry field data input as cell array of char
            obj.id = castInputField('GRID','ID',entryFields{2},'uint32',NaN,1);
            obj.cp = castInputField('GRID','CP',entryFields{3},'uint32',[] ,0);
            obj.x1 = castInputField('GRID','X1',entryFields{4},'double',0.0);
            obj.x2 = castInputField('GRID','X2',entryFields{5},'double',0.0);
            obj.x3 = castInputField('GRID','X3',entryFields{6},'double',0.0);
            obj.cd = castInputField('GRID','CD',entryFields{7},'uint32',[] ,0);
            obj.ps = castInputField('GRID','PS',entryFields{8},'uint32',[]);
            obj.seid = castInputField('GRID','SEID',entryFields{9},'uint32',[]);
        end
        function model = entry2model_sub(obj,model)
            % Convert entry object to model object and store in model entity array
            if ~(obj.seid == 0 | isempty(obj.seid)); error('GRID ID = %d has a nonzero SEID, which is not supported.',obj.id); end
            node = Node;
            node.id=uint32(obj.id);
            node.cp=obj.cp;
            node.x_p = [obj.x1; obj.x2; obj.x3];
            node.cd=obj.cd;
            ps = [false;false;false;false;false;false;false];
            if ~isempty(obj.ps)
                ps(7)=true; % explicitly define perminate single point constraints (overides defaults)
                if obj.ps ~= 0
                    ind = str2num(num2str(obj.ps)');
                    if any(ind>6) || any(ind<1)
                        error('There is a formatting problem with the PS field in GRID ID = %d.',obj.id)
                    end
                    ps(ind)=true;
                end
            end
            node.ps=ps;
            model.node=[model.node;node];
        end
        function echo_sub(obj,fid)
            % Print the entry in NASTRAN free field format to a text file with file id fid
            if obj.ps == -999
                fprintf(fid,'GRID,%d,%d,%f,%f,%f,%d\n',obj.id,obj.cp,obj.x1,obj.x2,obj.x3,obj.cd);
            else
                fprintf(fid,'GRID,%d,%d,%f,%f,%f,%d,%d\n',obj.id,obj.cp,obj.x1,obj.x2,obj.x3,obj.cd,obj.ps);
            end
        end
        
    end
end

