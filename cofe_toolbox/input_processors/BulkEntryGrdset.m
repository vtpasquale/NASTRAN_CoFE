% Class for GRDSET entry, which defines default options for fields 3, 7, 8, and 9 of all GRID entries.
% Anthony Ricciardi
%
classdef BulkEntryGrdset < BulkEntry
    
    properties
        cp % [uint32] Identification number of coordinate system in which the location of the grid points are defined.
        cd % [uint32] Identification number of coordinate system in which the displacements, degrees of freedom, constraints, and solution vectors of the grid point are defined. 
        ps % [uint32] Permanent single-point constraints on the grid point. (Any combination of Integers 1 through 6 with no embedded blanks, or blank.)
        seid % [uint32] Superelement identification number.
    end
    
    methods
        function obj = BulkEntryGrdset(entryFields)
            % Construct using entry field data input as cell array of char           
            obj.cp = castInputField('GRDSET','CP',entryFields{3},'uint32',[],0);
            obj.cd = castInputField('GRDSET','CD',entryFields{7},'uint32',[],0);
            obj.ps = castInputField('GRDSET','PS',entryFields{8},'uint32',[],1,123456);
            obj.seid = castInputField('GRDSET','SEID',entryFields{9},'uint32',[]);
        end
    end
    methods
        function model = entry2model_sub(obj,model)
            % Convert entry object to model object and store in model entity array
            ps = false(6,1);
            if ~isempty(obj.ps)
                ind = expandComponents(obj.ps,'GRDSET PS',false);
                ps(ind)=true;
            end
            model.cpDefault=obj.cp;
            model.cdDefault=obj.cd;
            model.psDefault=ps;
        end % entry2model_sub()
        function echo_sub(obj,fid)
            % Print the entry in NASTRAN free field format to a text file with file id fid
            fprintf(fid,'GRDSET,,%d,,,,%d,%d\n',obj.cp,obj.cd,obj.ps);
        end % echo_sub()
        
    end
end
