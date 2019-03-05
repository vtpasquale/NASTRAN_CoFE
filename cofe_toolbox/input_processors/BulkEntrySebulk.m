% Class for SEBULK entries
% Anthony Ricciardi
%
classdef BulkEntrySebulk < BulkEntry
    
    properties
        seid % [uint32] Partitioned superelement identification number.
        type % [char] Superelement type: PRIMARY, REPEAT, MIRROR, COLLCTR, EXTERNAL, EXTOP2, EXTOP4, FRFOP2
        rseid % [uint32] Identification number of the reference superelement, used if TYPE='REPEAT' and 'MIRROR'. (Default=0)
        method % [char] Method to be used when searching for boundary grid points: AUTO or MANUAL; Default=AUTO)
        tol % [double] Location tolerance to be used when searching for boundary grid points. (Default=10E-5)
        loc % [char] Coincident location check option for manual connection option: 'YES' or 'NO' (Default='YES')
        unitno % [uint32] Fortran unit number for the OUTPUT2 or OP4 file, meaningful only when TYPE = 'EXTOP2', 'EXTOP4', or 'FRFOP2')
    end
    methods
        function obj = BulkEntrySebulk(entryFields)
            % Construct using entry field data input as cell array of char
            obj.seid = castInputField('SEBULK','SEID',entryFields{2},'uint32',NaN,1);
            obj.type = castInputField('SEBULK','TYPE',entryFields{3},'char',[]);
            obj.rseid = castInputField('SEBULK','RSEID',entryFields{4},'uint32',uint32(0));
            obj.method = castInputField('SEBULK','METHOD',entryFields{5},'char','AUTO');
            obj.tol = castInputField('SEBULK','TOL',entryFields{6},'double',1E-4);
            obj.loc = castInputField('SEBULK','LOC',entryFields{7},'char',[],'YES');
            obj.unitno = castInputField('SEBULK','UNITNO',entryFields{8},'uint32',[]);
        end
        function model = entry2model_sub(obj,model)
            % Convert entry object to model object and store in model entity array
            % Check options are supported
            if ~(strcmpi(obj.type,'PRIMARY') || strcmpi(obj.type,'EXTOP4'))
                error('Only SEBULK TYPEs=PRIMARY or EXTOP4 are supported')
            end
            if ~strcmpi(obj.method,'MANUAL')
                error('Only SEBULK METHOD=MANUAL is supported')
            end
            
            model.superElement=model.superElement.setSebulk(obj.seid,obj.type);
        end
        function echo_sub(obj,fid)
            % Print the entry in NASTRAN free field format to a text file with file id fid
            fprintf(fid,'SEBULK,%d,%s,%d,%s,%E,%s,%d\n',obj.seid,obj.type,obj.rseid,obj.method,obj.tol,obj.loc,obj.unitno);
        end
        
    end
end

